<!--
Sync Impact Report
- Version change: template -> 1.0.0
- Added principles: Canonical Governance; Resting-Only Transport; Swift-Native Async API;
  Contract Fidelity and Verification; Simplicity
- Added sections: Platform Constraints; Development Workflow
- Removed sections: none
- Follow-up TODOs: none
-->

# OpenWeatherMapSwift Constitution

## Core Principles

### I. Canonical Governance

`AGENTS.md` is the single source of project governance. Every Spec Kit planning,
task-generation, implementation, and review command MUST read and follow it. Constitution
amendments MUST update `AGENTS.md` first; this adapter then receives only matching metadata
and reference updates. This prevents two rule sets from drifting.

### II. Resting-Only Transport

All HTTP work MUST use the Resting package already declared in `Package.swift`. New transport
abstractions or networking dependencies require a demonstrated need that Resting cannot meet.

### III. Swift-Native Async API

Public network operations MUST use `async throws`, preserve cancellation, and remain safe under
Swift 6.3 concurrency checking. Response values crossing concurrency boundaries MUST be
`Sendable`. UI actor isolation and unstructured concurrency are prohibited without a specific
UI or lifecycle requirement.

### IV. Contract Fidelity and Verification

Public models and requests MUST match `docs/md-docs/`, including optional fields, units, bounds,
and response ordering. Each endpoint MUST have deterministic request, decoding, validation, and
failure tests that require no live credential or network access.

### V. Simplicity

Implement only approved scope with the fewest clear types and files. Reuse shared types only
where endpoint semantics truly match. Caching, retry policies, compatibility APIs, protocols,
and additional targets are forbidden until a concrete requirement needs them.

## Platform Constraints

The package MUST remain on Swift 6.3 and its declared Apple deployment targets. Phase 1 is
limited to current weather, 5-day/3-hour forecast, 16-day daily forecast, and geocoding. Full
constraints, source priorities, security rules, and exclusions live in `AGENTS.md` and are
normative.

## Development Workflow

Number specs sequentially under `docs/spec-kit/`. Workflows MUST have no gates and MUST not stop
for user choices; agents make reasonable defaults and document assumptions. Implement specs in
number order, update public documentation with API changes, then verify builds and tests through
XcodeBuildMCP as directed by `AGENTS.md`.

## Governance

`AGENTS.md` supersedes this adapter when wording differs. Amendments require an explicit change
to `AGENTS.md`, a semantic version update here, an ISO amendment date, and a refreshed Sync Impact
Report. MAJOR versions remove or redefine governance, MINOR versions add or materially expand
rules, and PATCH versions clarify wording without changing obligations. Reviews MUST verify both
feature acceptance criteria and governance compliance.

**Version**: 1.0.0 | **Ratified**: 2026-08-15 | **Last Amended**: 2026-08-15

