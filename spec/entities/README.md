# Core Entities (Phase 0)

This folder defines the canonical domain entities for the Multimodal Scientific AI Runtime.
All entities are **schema-first**: the JSON Schemas in `spec/schemas/**` are the source of truth.

## Entity List

### 1) ExperimentRequest
**What it is:** The user-facing request to run a workflow.
**Purpose:** Establish intent, inputs, constraints, and which DAG template to execute.
**Key properties:**
- `request_id`, `correlation_id`
- `research_only: true` (hard constraint)
- `workflow_template` reference
- input artifact pointers + optional free text context
- constraints (budget/runtime/deterministic mode)

### 2) RunManifest
**What it is:** The immutable, normalized execution plan derived from an `ExperimentRequest`.
**Purpose:** Make runs deterministic and replayable by freezing:
- compiled DAG
- resolved tool bindings (tool IDs/endpoints)
- normalized parameters

### 3) StepResult
**What it is:** The durable record for one step in the DAG.
**Purpose:** Provide typed tool I/O, provenance, artifacts, timings, and verification status.

### 4) Dossier
**What it is:** The immutable final bundle of a run.
**Purpose:** Provide a research-only summary and provenance pointers to all artifacts and step outputs.

## Invariants (must always hold)
- **Research-only:** all requests and dossiers must carry research-only posture.
- **Traceability:** every entity must include `correlation_id`.
- **Replayability:** a `RunManifest` is sufficient to replay (given artifacts exist).
- **Immutability:** `RunManifest`, `StepResult`, and `Dossier` are append-only records.

## Mapping to Schemas
- Control-plane schemas: `spec/schemas/control-plane/*.schema.json`
- Tool I/O schemas: `spec/schemas/tool-io/*.schema.json`
