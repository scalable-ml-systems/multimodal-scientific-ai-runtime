# Core Entities (Phase 0)

## ExperimentRequest
User intent + input references + constraints.
- Immutable once submitted
- Contains *what to do*, not *how it is executed*

## RunManifest
The compiled, fully-resolved plan for a specific run.
- Includes workflow version, tool bindings, container/image versions (when applicable)
- Includes artifact locations and provenance metadata
- The source of truth for replay

## StepResult
Immutable record emitted per step execution.
- Inputs + outputs are references (URIs), not blobs
- Captures timings, status, metrics, and error details
- Must be idempotency-friendly (same step/run key yields same logical record)

## Dossier
Final assembled output bundle for a run.
- Evidence index: pointers to StepResults + artifacts
- Summary + key findings (if produced)
- Suitable for downstream review and auditing
