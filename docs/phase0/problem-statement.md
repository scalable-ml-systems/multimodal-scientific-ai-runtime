# Multimodal Scientific AI Runtime — Problem Statement (Phase 0)

## Context
Scientific teams increasingly rely on heterogeneous computation (classical statistics, simulation, ML/LLMs/vision, domain tools) to turn raw inputs into defensible conclusions. Today this work is often stitched together via notebooks, ad-hoc scripts, and manual handoffs. The result is slow iteration, low reproducibility, fragile provenance, and weak auditability—especially when AI components are involved.

## Problem
We need a runtime that can execute scientific “investigations” (experiments/analyses) as:
- **Deterministic workflows** with explicit step boundaries
- **Strong contracts** (schemas) between steps and tools
- **Reproducible runs** with immutable artifacts and manifests
- **Auditable provenance** (what ran, with which inputs/models/tools, and what was produced)
- **Safe-by-design** constraints that prevent clinical/therapeutic misuse

Current pain points:
1. **Reproducibility gaps:** inputs, params, tool versions, and model versions are not consistently captured.
2. **Provenance ambiguity:** it’s hard to trace which step produced which output and why.
3. **Non-deterministic AI usage:** LLM/vision calls can be uncontrolled and not governed by clear I/O contracts.
4. **Operational fragility:** pipelines fail mid-run with unclear state; resuming/replaying is hard.
5. **Inconsistent artifacts:** outputs are scattered across machines; no canonical run dossier.

## Goal (Phase 0)
Define the minimal, production-grade “contracts layer” that enables future implementation:
- Canonical entities:
  - ExperimentRequest (user intent + inputs)
  - RunManifest (what will run; versions; provenance plan)
  - StepResult (immutable record of each executed step)
  - Dossier (assembled end-product + evidence index)
- JSON Schemas for control-plane and tool I/O
- Workflow DAG template format (step graph + tools + contracts)
- Terraform bootstrap primitives to store artifacts & manifests safely and cheaply (no GPUs yet)

## Success Criteria
A run can be described *without code* via:
1. A valid ExperimentRequest JSON (schema validated)
2. A valid workflow template (DAG validated)
3. A RunManifest derived from the request + workflow
4. StepResults that reference immutable artifact URIs
5. A final Dossier that indexes evidence and metadata end-to-end

## Users / Personas
- **Research engineer:** wants repeatable experiments, quick re-runs, and clear provenance.
- **Platform engineer:** wants strict contracts, stable interfaces, and deployable infrastructure.
- **Reviewer/auditor:** wants traceability, inputs→outputs lineage, and evidence indexing.

## Out of Scope (Phase 0)
- Actual model execution and orchestration engine implementation
- GPU scheduling / multi-GPU inference
- Interactive UI, notebooks, or data labeling tools
- Clinical decision support or medical advice

## Key Risks & Mitigations
- **Scope creep into “agentic hype”:** mitigate via contracts-first, deterministic DAG, and immutable artifacts.
- **Regulatory misuse (clinical):** mitigate via explicit non-goals + policy gates later.
- **Run nondeterminism:** mitigate by forcing version pinning + seeded execution metadata in manifests.

## Deliverables
- docs/phase0/problem-statement.md (this)
- docs/phase0/non-goals.md
- spec/schemas/** (control-plane + tool I/O)
- spec/dag/workflow_template.yaml
- Terraform: DynamoDB state locking + tagging standard + VPC/subnets if chosen for Phase 0 baseline
