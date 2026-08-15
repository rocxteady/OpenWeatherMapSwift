# Implementation Plan: Geocoding

**Branch**: `004-geocoding` | **Date**: 2026-08-15 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `docs/spec-kit/004-geocoding/spec.md`

## Summary

Extend `OpenWeatherClient` with direct place, ZIP, and reverse-coordinate geocoding operations.
Each operation uses the configured Resting client, validates bounded or blank input before
networking, and decodes the documented JSON without sorting or normalizing it. One shared
geocoded-location value serves direct and reverse results; ZIP uses its distinct response value.

## Technical Context

**Language/Version**: Swift 6.3 language mode

**Primary Dependencies**: Foundation and Resting 1.0.0

**Storage**: N/A

**Testing**: Swift Testing with bundled JSON fixtures and the existing custom `URLProtocol` seam
through `RestClientConfiguration.sessionConfiguration`

**Target Platform**: iOS 15+, macOS 12+, watchOS 8+, tvOS 15+, visionOS 1+

**Project Type**: Swift Package library

**Performance Goals**: Exactly one outbound request and one decode per valid call; preserve all
returned locations, localized-name entries, and service ordering without package-added processing

**Constraints**: JSON only; reject invalid coordinates, limits, and blank required text before
network work; preserve cancellation, response bytes, and Resting errors; keep API keys private;
do not parse, normalize, rank, cache, or retry geocoding input or results

**Scale/Scope**: Three client operations, two response types, one existing library target, and
deterministic request, decoding, boundary-validation, empty-result, and failure tests

## Constitution Check

*GATE: Passed before Phase 0 and passed again after Phase 1 design.*

| Rule | Design evidence | Result |
| --- | --- | --- |
| Canonical governance | The plan follows `AGENTS.md`; the constitution adapter adds no competing rule. | Pass |
| Resting-only transport | All three operations use the existing `RestClient` and `RequestDefinition.query`; no wrapper, protocol, or dependency is added. | Pass |
| Swift-native async API | All network methods are `async throws`; response values are immutable and `Sendable`; no actor, task, lock, queue, or Combine API is introduced. | Pass |
| Contract fidelity | The design maps every field and optionality in `docs/md-docs/geocoding.md`, preserves arrays and arbitrary localized-name keys, and covers every endpoint with fixture, request, validation, and failure tests. | Pass |
| Simplicity | One location type is shared only by the identical direct/reverse wire shape; ZIP remains distinct; flat coordinates avoid a custom decoder solely for type reuse. | Pass |
| Platform and scope | Swift 6.3 and all deployment targets remain unchanged; deprecated weather lookup, caching, retries, address parsing, ranking, and persistence remain excluded. | Pass |
| Credential safety | The existing private API key is used only as the outbound `appid` query item. | Pass |

Post-design re-check: [data-model.md](data-model.md),
[contracts/public-api.md](contracts/public-api.md), and [quickstart.md](quickstart.md) retain the
same one-target, Resting-only design. No violation requires complexity tracking.

## Project Structure

### Documentation (this feature)

```text
docs/spec-kit/004-geocoding/
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
├── DailyForecast.swift
└── Geocoding.swift

Tests/OpenWeatherMapSwiftTests/
├── CurrentWeatherTests.swift
├── FiveDayForecastTests.swift
├── DailyForecastTests.swift
├── GeocodingTests.swift
└── Fixtures/
    ├── geocoding-direct.json
    ├── geocoding-zip.json
    ├── geocoding-reverse.json
    └── geocoding-empty.json

README.md
```

**Structure Decision**: Keep the existing library and test targets. Add the three request methods
to the existing client, put both endpoint response values in one source file, and extend the
existing serialized test suite so its shared request stub remains race-free. Update `README.md`
with implemented geocoding use sites.

## Complexity Tracking

No constitution violations.
