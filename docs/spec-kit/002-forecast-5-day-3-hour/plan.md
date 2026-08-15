# Implementation Plan: 5-Day / 3-Hour Forecast

**Branch**: `002-forecast-5-day-3-hour` | **Date**: 2026-08-15 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `docs/spec-kit/002-forecast-5-day-3-hour/spec.md`

## Summary

Extend the existing `OpenWeatherClient` with one coordinate-based async forecast operation that
uses the configured Resting client, validates coordinates and an optional positive timestamp
limit before networking, and decodes OpenWeather's ordered forecast timeline into immutable
`Sendable` values. Reuse current-weather value types only for identical wire shapes; add no
transport abstraction, dependency, target, retry, cache, or date-conversion layer.

## Technical Context

**Language/Version**: Swift 6.3 language mode

**Primary Dependencies**: Foundation and Resting 1.0.0

**Storage**: N/A

**Testing**: Swift Testing with bundled JSON fixtures and the existing custom `URLProtocol` seam
through `RestClientConfiguration.sessionConfiguration`

**Target Platform**: iOS 15+, macOS 12+, watchOS 8+, tvOS 15+, visionOS 1+

**Project Type**: Swift Package library

**Performance Goals**: One outbound request and one decode per call; preserve all returned entries
and conditions in source order without package-added processing

**Constraints**: JSON and coordinate lookup only; validate latitude, longitude, and optional count
before network work; preserve cancellation, response bytes, and Resting errors; keep human-readable
timestamps as service strings and API keys private

**Scale/Scope**: One client operation, one forecast response graph, shared current-weather values
where wire semantics match, and deterministic tests including a 40-entry fixture

## Constitution Check

*GATE: Passed before Phase 0 and passed again after Phase 1 design.*

| Rule | Design evidence | Result |
| --- | --- | --- |
| Canonical governance | The plan follows `AGENTS.md`; the constitution adapter adds no competing rule. | Pass |
| Resting-only transport | The operation uses the client's existing `RestClient` with `RequestDefinition.query`; no protocol, wrapper, or dependency is added. | Pass |
| Swift-native async API | `fiveDayForecast(latitude:longitude:maximumTimestampCount:units:language:)` is `async throws`; response values are immutable and `Sendable`; no actor, task, lock, queue, or Combine API is introduced. | Pass |
| Contract fidelity | The design maps every field and documented optionality in `docs/md-docs/forecast-5-day-3-hour.md`, preserves both ordered arrays, and plans request, decoding, boundary, and failure tests. | Pass |
| Simplicity | The existing target, client, Resting configuration, test stub, coordinate validation, unit enum, and truly identical response types are reused. | Pass |
| Platform and scope | Swift 6.3 and deployment targets remain unchanged; only JSON coordinate-based 5-day/3-hour forecast is designed. | Pass |
| Credential safety | The existing private API key is used only as the outbound `appid` query item. | Pass |

Post-design re-check: [data-model.md](data-model.md),
[contracts/public-api.md](contracts/public-api.md), and [quickstart.md](quickstart.md) retain the
same one-target, Resting-only design. No violation requires complexity tracking.

## Project Structure

### Documentation (this feature)

```text
docs/spec-kit/002-forecast-5-day-3-hour/
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
├── CurrentWeather.swift
└── FiveDayForecast.swift

Tests/OpenWeatherMapSwiftTests/
├── CurrentWeatherTests.swift
├── FiveDayForecastTests.swift
└── Fixtures/
    ├── forecast-5-day-full.json
    └── forecast-5-day-optional.json

README.md
```

**Structure Decision**: Keep the existing library and test targets. Add forecast request logic to
the existing client, place only the new endpoint-specific response graph in one source file, and
extend the existing serialized test suite so it can reuse the same request stub without a second
transport abstraction. Update `README.md` with the implemented forecast use site.

## Complexity Tracking

No constitution violations.
