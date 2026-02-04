#!/usr/bin/env python3
"""
Spec validator for multimodal-scientific-ai-runtime

Checks:
- JSON schema files parse as JSON
- Example instances validate against JSON Schemas (Draft 2020-12)
- DAG template YAML invariants: required fields, unique step ids, valid deps, acyclic graph

Usage:
  python3 tools/validate_spec.py --spec-dir spec
  python3 tools/validate_spec.py --spec-dir spec --strict
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List, Set, Tuple

import yaml
from jsonschema import Draft202012Validator
from jsonschema.exceptions import ValidationError


@dataclass
class Issue:
    level: str  # "ERROR" | "WARN"
    path: str
    message: str

    def __str__(self) -> str:
        return f"[{self.level}] {self.path}: {self.message}"


def load_json(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def load_yaml(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def find_files(root: Path, suffix: str) -> List[Path]:
    return sorted([p for p in root.rglob(f"*{suffix}") if p.is_file()])


def validate_json_schemas(schema_dir: Path) -> List[Issue]:
    issues: List[Issue] = []
    schema_files = find_files(schema_dir, ".json")
    for sf in schema_files:
        try:
            data = load_json(sf)
            # Just compiling catches many schema-level problems.
            Draft202012Validator.check_schema(data)
        except json.JSONDecodeError as e:
            issues.append(Issue("ERROR", str(sf), f"Invalid JSON: {e}"))
        except Exception as e:
            issues.append(Issue("ERROR", str(sf), f"Invalid schema: {e}"))
    return issues


def validate_instance(instance_path: Path, schema_path: Path) -> List[Issue]:
    issues: List[Issue] = []
    try:
        schema = load_json(schema_path)
    except Exception as e:
        return [Issue("ERROR", str(schema_path), f"Failed to load schema: {e}")]

    try:
        instance = load_json(instance_path)
    except Exception as e:
        return [Issue("ERROR", str(instance_path), f"Failed to load instance: {e}")]

    try:
        v = Draft202012Validator(schema)
        errors = sorted(v.iter_errors(instance), key=lambda err: list(err.absolute_path))
        for err in errors:
            pointer = "/" + "/".join(str(p) for p in err.absolute_path)
            issues.append(Issue("ERROR", str(instance_path), f"{pointer}: {err.message}"))
    except ValidationError as e:
        issues.append(Issue("ERROR", str(instance_path), f"Validation error: {e.message}"))
    except Exception as e:
        issues.append(Issue("ERROR", str(instance_path), f"Validator failure: {e}"))
    return issues


def dag_invariants(template: Dict[str, Any], template_path: Path) -> List[Issue]:
    issues: List[Issue] = []
    p = str(template_path)

    # Required top-level fields
    for key in ["schema_version", "template_id", "steps"]:
        if key not in template:
            issues.append(Issue("ERROR", p, f"Missing required top-level field '{key}'"))

    if "schema_version" in template and template["schema_version"] != "v1":
        issues.append(Issue("WARN", p, f"schema_version is '{template['schema_version']}', expected 'v1'"))

    steps = template.get("steps", [])
    if not isinstance(steps, list) or len(steps) == 0:
        issues.append(Issue("ERROR", p, "steps must be a non-empty list"))
        return issues

    # Step id uniqueness
    step_ids: List[str] = []
    for i, s in enumerate(steps):
        if not isinstance(s, dict):
            issues.append(Issue("ERROR", p, f"steps[{i}] must be an object"))
            continue
        sid = s.get("id")
        if not sid or not isinstance(sid, str):
            issues.append(Issue("ERROR", p, f"steps[{i}].id must be a non-empty string"))
            continue
        step_ids.append(sid)

        # Basic per-step fields
        for req in ["type", "tool", "depends_on"]:
            if req not in s:
                issues.append(Issue("ERROR", p, f"step '{sid}' missing required field '{req}'"))

        # depends_on must be list
        deps = s.get("depends_on", [])
        if not isinstance(deps, list):
            issues.append(Issue("ERROR", p, f"step '{sid}': depends_on must be a list"))
        else:
            for d in deps:
                if not isinstance(d, str) or not d:
                    issues.append(Issue("ERROR", p, f"step '{sid}': depends_on contains invalid id '{d}'"))

    dupes = {x for x in step_ids if step_ids.count(x) > 1}
    for d in sorted(dupes):
        issues.append(Issue("ERROR", p, f"Duplicate step id '{d}'"))

    step_id_set = set(step_ids)

    # depends_on references must exist
    for s in steps:
        sid = s.get("id")
        deps = s.get("depends_on", [])
        if isinstance(deps, list):
            for d in deps:
                if isinstance(d, str) and d and d not in step_id_set:
                    issues.append(Issue("ERROR", p, f"step '{sid}': depends_on references unknown step '{d}'"))

    # Cycle detection (DFS)
    graph: Dict[str, List[str]] = {sid: [] for sid in step_id_set}
    for s in steps:
        sid = s.get("id")
        deps = s.get("depends_on", [])
        if isinstance(sid, str) and isinstance(deps, list):
            for d in deps:
                if isinstance(d, str) and d in step_id_set:
                    graph[sid].append(d)  # edge sid -> dependency

    visiting: Set[str] = set()
    visited: Set[str] = set()

    def dfs(node: str, stack: List[str]) -> None:
        if node in visiting:
            cycle = " -> ".join(stack + [node])
            issues.append(Issue("ERROR", p, f"DAG cycle detected: {cycle}"))
            return
        if node in visited:
            return
        visiting.add(node)
        for dep in graph.get(node, []):
            dfs(dep, stack + [node])
        visiting.remove(node)
        visited.add(node)

    for sid in step_id_set:
        dfs(sid, [])

    # Output mapping (optional but recommended)
    outputs = template.get("outputs")
    if outputs is None:
        issues.append(Issue("WARN", p, "No 'outputs' section found (recommended to define final output mapping)."))

    return issues


def validate_dag_templates(dag_dir: Path) -> List[Issue]:
    issues: List[Issue] = []
    yaml_files = sorted([p for p in dag_dir.rglob("*.yaml") if p.is_file()] + [p for p in dag_dir.rglob("*.yml") if p.is_file()])
    for yf in yaml_files:
        try:
            doc = load_yaml(yf)
            if not isinstance(doc, dict):
                issues.append(Issue("ERROR", str(yf), "YAML root must be a mapping/object"))
                continue
            issues.extend(dag_invariants(doc, yf))
        except Exception as e:
            issues.append(Issue("ERROR", str(yf), f"Invalid YAML: {e}"))
    return issues

def validate_sample_instances(spec_dir: Path) -> List[Issue]:
    issues: List[Issue] = []

    samples = [
        (
            spec_dir / "schemas" / "control-plane" / "ExperimentRequest.sample.json",
            spec_dir / "schemas" / "control-plane" / "ExperimentRequest.schema.json",
        ),
        (
            spec_dir / "schemas" / "control-plane" / "Dossier.sample.json",
            spec_dir / "schemas" / "control-plane" / "Dossier.schema.json",
        ),

    ]

    for instance_path, schema_path in samples:
        if not instance_path.exists():
            issues.append(Issue("WARN", str(instance_path), "Sample instance not found"))
            continue
        if not schema_path.exists():
            issues.append(Issue("ERROR", str(schema_path), "Schema not found for sample"))
            continue
        issues.extend(validate_instance(instance_path, schema_path))

    return issues


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--spec-dir", default="spec", help="Path to spec/ directory")
    ap.add_argument("--strict", action="store_true", help="Treat warnings as errors")
    args = ap.parse_args()

    spec_dir = Path(args.spec_dir).resolve()
    if not spec_dir.exists():
        print(f"[ERROR] spec dir not found: {spec_dir}")
        return 2

    issues: List[Issue] = []

    # 1) Schemas parse & compile
    control_plane_dir = spec_dir / "schemas" / "control-plane"
    tool_io_dir = spec_dir / "schemas" / "tool-io"
    if control_plane_dir.exists():
        issues.extend(validate_json_schemas(control_plane_dir))
    else:
        issues.append(Issue("ERROR", str(control_plane_dir), "Missing control-plane schema dir"))

    if tool_io_dir.exists():
        issues.extend(validate_json_schemas(tool_io_dir))
    else:
        issues.append(Issue("ERROR", str(tool_io_dir), "Missing tool-io schema dir"))

    # 2) Validate examples if present (optional)
        issues.extend(validate_sample_instances(spec_dir))

    # 3) DAG templates
    dag_dir = spec_dir / "dag"
    if dag_dir.exists():
        issues.extend(validate_dag_templates(dag_dir))
    else:
        issues.append(Issue("ERROR", str(dag_dir), "Missing dag/ directory"))

    # Print results
    errors = 0
    warnings = 0
    for it in issues:
        print(str(it))
        if it.level == "ERROR":
            errors += 1
        else:
            warnings += 1

    if args.strict and warnings > 0:
        errors += warnings

    if errors > 0:
        print(f"\nFAILED: {errors} error(s), {warnings} warning(s)")
        return 1

    print(f"\nOK: 0 error(s), {warnings} warning(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
