# Workflow Template Format (Phase 0)

## Required fields
- api_version, kind, metadata.name, metadata.version
- dag.steps[*].id, tool.name, tool.version, tool.io_schema_ref
- steps[*].inputs / outputs (can be empty arrays)

## Dependencies
- depends_on is an array of step IDs
- DAG must be acyclic
- Steps must reference existing step outputs or request inputs

## Compilation
A compiler creates a RunManifest by:
- hashing the normalized DAG (dag_digest)
- resolving artifact_root (from artifact_root_pattern)
- converting references (from_request_input / from_step_output) into concrete ArtifactRef entries as StepResults are produced
