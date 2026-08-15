# Implementation Plan: 16-Day Daily Forecast

**Branch**: `003-forecast-16-day-daily` | **Date**: 2026-08-15 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `docs/spec-kit/003-forecast-16-day-daily/spec.md`

## Summary

Extend `OpenWeatherClient` with one coordinate-based async daily-forecast operation that uses the
configured Resting client, validates coordinates and an optional `1...16` day count before
networking, and decodes city metadata plus ordered daily entries into immutable `Sendable` values.
Reuse only identical existing types and add no transport abstraction, dependency, target, retry,
cache, XML, date-conversion, or aggregation layer.

## Technical Context

**Language/Version**: Swift 6.3 language mode

**Primary Dependencies**: Foundation and Resting 1.0.0

**Storage**: N/A

**Testing**: Swift Testing with bundled JSON fixtures and the existing custom `URLProtocol` seam
through `RestClientConfiguration.sessionConfiguration`

**Target Platform**: iOS 15+, macOS 12+, watchOS 8+, tvOS 15+, visionOS 1+

**Project Type**: Swift Package library

**Performance Goals**: One outbound request and one decode per call; preserve up to 16 returned
days and every day's condition ordering without package-added processing

**Constraints**: JSON and coordinate lookup only; validate latitude, longitude, and optional day
count before network work; preserve cancellation, response bytes, and Resting errors; keep Unix
timestamps unmodified and API keys private

**Scale/Scope**: One client operation, one daily-forecast response graph, existing shared values
only where wire semantics match, and deterministic request/decoding/validation/failure tests

## Constitution Check

*GATE: Passed before Phase 0 and passed again after Phase 1 design.*

| Rule | Design evidence | Result |
| --- | --- | --- |
| Canonical governance | The plan follows `AGENTS.md`; the constitution adapter adds no competing rule. | Pass |
| Resting-only transport | The operation uses the client's existing `RestClient` with `RequestDefinition.query`; no protocol, wrapper, or dependency is added. | Pass |
| Swift-native async API | `dailyForecast(latitude:longitude:maximumDayCount:units:language:)` is `async throws`; response values are immutable and `Sendable`; no actor, task, lock, queue, or Combine API is introduced. | Pass |
| Contract fidelity | The design maps every field and documented optionality in `docs/md-docs/forecast-16-day-daily.md`, preserves both ordered arrays, and plans request, decoding, boundary, and failure tests. | Pass |
| Simplicity | The existing target, client, Resting configuration, test stub, coordinate validation, unit enum, coordinates, and weather-condition type are reused. | Pass |
| Platform and scope | Swift 6.3 and deployment targets remain unchanged; only JSON coordinate-based 16-day daily forecast is designed. | Pass |
| Credential safety | The existing private API key is used only as the outbound `appid` query item. | Pass |

Post-design re-check: [data-model.md](data-model.md),
[contracts/public-api.md](contracts/public-api.md), and [quickstart.md](quickstart.md) retain the
same one-target, Resting-only design. No violation requires complexity tracking.

## Project Structure

### Documentation (this feature)

```text
docs/spec-kit/003-forecast-16-day-daily/
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
├── FiveDayForecast.swift
└── DailyForecast.swift

Tests/OpenWeatherMapSwiftTests/
├── CurrentWeatherTests.swift
├── FiveDayForecastTests.swift
├── DailyForecastTests.swift
└── Fixtures/
    ├── forecast-daily-full.json
    └── forecast-daily-optional.json

README.md
```

**Structure Decision**: Keep the existing library and test targets. Add request logic to the
existing client, place the endpoint-specific response graph in one source file, and extend the
existing serialized test suite so the shared request stub remains race-free. Update `README.md`
with the implemented daily-forecast use site.

## Complexity Tracking

No constitution violations.
