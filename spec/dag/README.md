# Workflow DAG Template Format (Phase 0)

Workflow templates are **declarative** YAML files describing a DAG of steps.
They are validated before execution and compiled into a `RunManifest`.

## Goals
- Deterministic execution order and dependencies
- Clear tool ownership per step
- Stable step identifiers for retries/replay
- Minimal surface area (Phase 0)

## Template Structure (v1)
A template contains:

- `schema_version`: must be `v1`
- `template_id`: stable identifier
- `description`: human description
- `inputs.required`: required logical inputs (e.g., `primary_artifacts`)
- `steps[]`: ordered list of nodes; dependencies define DAG edges
- `outputs`: mapping from steps to final outputs (e.g., dossier)

## Step Fields
Each `step` includes:
- `id`: unique within template
- `type`: `generator | structure | scoring | verifier | optimizer | custom`
- `tool`: logical tool name used by tool broker (e.g., `generator`)
- `depends_on`: list of upstream step ids
- `input_mapping`: lightweight pointers into prior outputs / request inputs

## Compilation
The Orchestrator compiles a template into:
- adjacency list (DAG)
- resolved tool bindings (from policy + environment config)
- a normalized per-step input spec

## Constraints
- No cycles (DAG must be acyclic)
- All `depends_on` must reference valid step ids
- Verifier step is recommended as the terminal step (Phase 0 expectation)

See `workflow_template.yaml` for the canonical example.
