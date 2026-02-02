# MultiModal Scientific AI Runtime (MSAIR)

A cloud-native runtime for orchestrating reproducible, multi-model scientific AI workflows.

### What is this project about?

MSAIR is an infrastructure platform that executes heterogeneous AI models within structured scientific workflows.

It provides the runtime layer that enables:

- model orchestration
- GPU/CPU inference coordination
- experiment reproducibility
- step-level provenance
- governance and safety controls

This project focuses on scientific compute infrastructure, not scientific claims.

### Problem

Modern scientific AI workflows often rely on:
- ad-hoc scripts
- notebooks
- manual model chaining
- weak lineage tracking

This leads to:
- poor reproducibility
- hidden model drift
- fragile integrations
- limited observability

MSAIR introduces a runtime fabric similar to Kubernetes for containers — but designed for multi-model scientific AI workflows.

### What MSAIR Does

MSAIR orchestrates workflows that may include:

Model Type	Example Role
Generative models	candidate generation
Structure models	structural inference
Scoring models	computational evaluation
Optimization models	iterative refinement

Each model runs as an isolated inference service.
The runtime coordinates execution via a graph-based workflow engine.

##  Architecture Overview

MSAIR is built around two clearly separated planes:

### Control Plane

Responsible for orchestration, governance, and reproducibility.

- API gateway
- workflow/DAG engine
- event bus
- policy engine
- verifier
- run manifest & dossier builder

### Model Plane

Responsible only for AI model execution.

- Triton inference servers
- vLLM LLM service (structured orchestration/reporting)
- specialist tool services

### Reproducibility by Design

Every workflow execution produces an immutable Run Manifest containing:

# input hashes
# model versions
# container digests
# step parameters
# artifact references

Workflows can be replayed from a manifest to verify deterministic behavior.

### Safety & Scope

MSAIR is designed as research compute infrastructure.

It does not:

- make clinical or therapeutic claims
- provide medical decision support
- process patient data
- generate laboratory synthesis instructions

All outputs are computational artifacts within experimental workflows.

### Key Capabilities

- Event-driven workflow orchestration
- Multi-model DAG execution
- CPU-first → GPU-scalable design
- Schema-validated tool contracts
- Step-level observability
- Failure handling and degraded modes
- Policy-based execution control

### Observability

MSAIR integrates:

- OpenTelemetry tracing
- Prometheus metrics
- Grafana dashboards
- to provide visibility into:
- workflow latency
- step success rates
- retries
- GPU utilization

### Roadmap
V1

Core control plane

CPU stub models

End-to-end workflow execution

Replay + manifest

V2

GPU model plane

Triton integration

vLLM supervisor

performance optimization

📂 Repository Structure

See:

services/       → control plane services  
model-plane/    → inference services  
spec/           → schemas + workflow templates  
infra/          → infrastructure code  
observability/  → monitoring stack  

🏁 Vision

MSAIR aims to bring scientific rigor and systems engineering discipline to AI workflows by treating model execution as a governed, observable runtime — not a collection of scripts.
