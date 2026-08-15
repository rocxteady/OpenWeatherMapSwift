# Implementation Plan: Current Weather

**Branch**: `001-current-weather` | **Date**: 2026-08-15 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `docs/spec-kit/001-current-weather/spec.md`

## Summary

Add a reusable `OpenWeatherClient` that validates coordinates, creates one Resting
`RequestDefinition` for OpenWeather's JSON current-weather endpoint, and decodes the result into
immutable `Sendable` public values. The implementation passes Resting failures through unchanged,
uses its configurable `URLSessionConfiguration` for deterministic tests, and adds no transport
abstraction or dependency.

## Technical Context

**Language/Version**: Swift 6.3 language mode  
**Primary Dependencies**: Foundation and Resting 1.0.0  
**Storage**: N/A  
**Testing**: Swift Testing with JSON fixtures and a custom `URLProtocol` installed through
`RestClientConfiguration.sessionConfiguration`  
**Target Platform**: iOS 15+, macOS 12+, watchOS 8+, tvOS 15+, visionOS 1+  
**Project Type**: Swift Package library  
**Performance Goals**: One outbound request and one decode per call; no package-added retry,
caching, or persistence work  
**Constraints**: JSON and coordinate lookup only; validate latitude and longitude before network
work; preserve cancellation, response bytes, and typed Resting errors; never expose the API key
through package-owned descriptions  
**Scale/Scope**: One public client operation, one response graph, one unit preference enum, and
deterministic tests for the first numbered feature

## Constitution Check

*GATE: Passed before Phase 0 and passed again after Phase 1 design.*

| Rule | Design evidence | Result |
| --- | --- | --- |
| Canonical governance | Plan follows `AGENTS.md`; the adapter adds no competing rule. | Pass |
| Resting-only transport | `OpenWeatherClient` owns one configured `RestClient` and uses `RequestDefinition.query`; no transport protocol or dependency is added. | Pass |
| Swift-native async API | `currentWeather(latitude:longitude:units:language:)` is `async throws`; response values are immutable and `Sendable`; no actor, task, queue, or Combine API is introduced. | Pass |
| Contract fidelity | Models cover every field and optionality in `docs/md-docs/current-weather.md`; fixtures, request inspection, boundaries, and failures are planned. | Pass |
| Simplicity | The existing target remains; request construction stays beside the single client operation; only wire-shape value types are introduced. | Pass |
| Platform and scope | Swift 6.3 and existing deployment targets remain; only JSON coordinate-based current weather is designed. | Pass |
| Credential safety | The API key is private and appears only in the outbound `appid` query item. | Pass |

Post-design re-check: `data-model.md`, `contracts/public-api.md`, and `quickstart.md` retain the
same one-target, Resting-only design. No violation requires complexity tracking.

## Project Structure

### Documentation (this feature)

```text
docs/spec-kit/001-current-weather/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── public-api.md
└── tasks.md                 # Created later by $speckit-tasks
```

### Source Code (repository root)

```text
Sources/OpenWeatherMapSwift/
├── OpenWeatherClient.swift
└── CurrentWeather.swift

Tests/OpenWeatherMapSwiftTests/
├── CurrentWeatherTests.swift
└── Fixtures/
    ├── current-weather-full.json
    ├── current-weather-minimal.json
    └── current-weather-string-status.json

README.md
```

**Structure Decision**: Keep the existing library and test targets. Put the client/request logic in
one file and the response graph in one file; keep endpoint fixtures under the existing test target.
Update `README.md` only with the implemented public usage example.

## Complexity Tracking

No constitution violations.
