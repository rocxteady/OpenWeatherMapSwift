@RTK.md

# OpenWeatherMapSwift Governance

This file is the canonical project constitution. `.specify/memory/constitution.md` is the
Spec Kit adapter and MUST point here. A request to update the constitution means:

1. Update this file first.
2. Update the adapter's version, amendment date, and sync report without copying these rules.

## Product Scope

- Build a Swift Package client for OpenWeather APIs.
- Phase 1 includes current weather, 5-day/3-hour forecast, 16-day daily forecast, and
  direct, ZIP, and reverse geocoding.
- JSON responses and coordinate-based weather requests are in scope. XML, HTML,
  deprecated city-name/city-ID weather lookup, caching, retries, persistence, UI, and
  credential storage are out of scope unless a later spec adds them.
- `docs/md-docs/` is the readable API contract. `docs/openapi.json` is supporting detail.
- Number feature specs sequentially under `docs/spec-kit/`.

## Platform and Dependency Rules

- Use Swift 6.3 language mode and preserve package deployment targets.
- Use Resting as the only HTTP transport. Reuse `RestClient`, `RestClientConfiguration`,
  `RequestDefinition`, and `RestingError`; do not wrap them behind a one-implementation
  transport protocol.
- Use Foundation and already-installed dependencies before adding code or packages.
- Keep one library target unless a measured need requires another target.

## Source Organization

- Keep client state and shared request utilities in `Client/OpenWeatherClient.swift`; group
  endpoint methods in focused `OpenWeatherClient+...` files under `Client/`.
- Keep response types under `Models/`. Cohesive feature response graphs may share one file;
  move only genuinely cross-feature weather values to `SharedWeather.swift`. Do not create one
  file per type merely for symmetry.
- Keep endpoint-family tests in separate files and reusable deterministic HTTP support in
  `TestSupport.swift`.

## Public API Rules

- Design call sites first and follow Swift API Design Guidelines.
- Public declarations need concise documentation comments.
- Prefer immutable value types conforming to `Sendable` and `Decodable` for response data.
  Add other conformances only when they provide current value.
- Model documented optional fields as optional and preserve upstream array ordering.
- Share genuinely common weather value types; do not force endpoints with different wire
  shapes into one abstraction.
- Validate bounded inputs before network work. Use Resting's existing error model unless a
  distinct public domain error is required.
- Never log, interpolate into descriptions, or expose API keys through package-owned values.

## Concurrency and Networking

- Public network operations use `async throws` and cooperate with task cancellation.
- Do not add Combine APIs, actors, tasks, locks, or queues without behavior that needs them.
- Do not isolate this non-UI package to `MainActor`.
- Reuse a configured `RestClient`; allow test configuration through Resting/Foundation
  facilities instead of inventing a transport layer.
- Do not hide upstream failures, response bytes, or cancellation information already carried
  by `RestingError`.

## Quality and Workflow

- Every endpoint requires fixture-based decoding tests, request construction tests, boundary
  validation tests, and representative failure tests.
- Tests MUST not require a live API key or public network access.
- Run `xcodebuildmcp swift-package build` and `xcodebuildmcp swift-package test` for
  implementation verification.
- Keep public API docs and README usage examples current when implementation changes them.
- Prefer the smallest readable implementation. No speculative layers, factories, protocols,
  configuration, or compatibility surfaces.
- Spec Kit workflows MUST contain no gates and request no user input. Agents choose the
  smallest reasonable default, record material assumptions, and continue.
- Implement numbered phase specs in order unless the user explicitly selects another one.
