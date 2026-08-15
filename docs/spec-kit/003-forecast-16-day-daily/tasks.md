---

description: "Dependency-ordered implementation tasks for the 16-day daily forecast"
---

# Tasks: 16-Day Daily Forecast

**Input**: Design documents from `docs/spec-kit/003-forecast-16-day-daily/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/public-api.md`, `quickstart.md`

**Tests**: Required by the feature specification and project governance. All tests use bundled fixtures and the existing `StubURLProtocol`; no live API key or public network is allowed.

**Organization**: Tasks are grouped by user story so each accepted behavior can be implemented and tested as a focused increment.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel because it touches a different file and has no dependency on another incomplete task
- **[Story]**: Maps a task to its user story (`US1`, `US2`, or `US3`)
- Every task names the exact file it changes or verifies

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish a clean baseline before feature edits.

- [X] T001 Run `xcodebuildmcp swift-package build` and `xcodebuildmcp swift-package test` against `Package.swift` to confirm the existing package baseline passes

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Reuse the existing one-target package, `OpenWeatherClient`, `RestClient`, coordinate validator, shared `UnitPreference`/`WeatherCoordinates`/`WeatherCondition` values, serialized Swift Testing suite, and `StubURLProtocol` seam.

No foundational code changes are required. Adding another target, dependency, transport protocol, request wrapper, or test seam is out of scope.

**Checkpoint**: T001 passes and the existing foundations are ready for User Story 1.

---

## Phase 3: User Story 1 - Retrieve Daily Forecast (Priority: P1) 🎯 MVP

**Goal**: Return city metadata and ordered daily entries for a coordinate-based request while applying optional unit and language preferences.

**Independent Test**: Stub the 16-entry full fixture, request metric Turkish results, and verify the request plus every documented top-level, city, daily, temperature, perceived-temperature, wind, cloud, precipitation, probability, and ordered-condition value.

### Tests for User Story 1

- [X] T002 [US1] Add a distinguishable 16-entry complete response fixture with every documented field in `Tests/OpenWeatherMapSwiftTests/Fixtures/forecast-daily-full.json`
- [X] T003 [US1] Add failing full-response, 16-day ordering, request construction, optional-preference omission, returned-count independence, and credential-exposure tests using the existing shared seam in `Tests/OpenWeatherMapSwiftTests/DailyForecastTests.swift`

### Implementation for User Story 1

- [X] T004 [P] [US1] Implement documented immutable `Decodable` and `Sendable` response types, concise public documentation, and wire-key mappings while reusing only `WeatherCoordinates` and `WeatherCondition` in `Sources/OpenWeatherMapSwift/DailyForecast.swift`
- [X] T005 [P] [US1] Implement `dailyForecast(latitude:longitude:maximumDayCount:units:language:)`, coordinate validation reuse, conditional `units`/`lang` query items, and one Resting request to `/data/2.5/forecast/daily` in `Sources/OpenWeatherMapSwift/OpenWeatherClient.swift`

**Checkpoint**: T002-T005 pass the User Story 1 tests and expose the complete ordered forecast API without requiring a day-count argument.

---

## Phase 4: User Story 2 - Select Forecast Length (Priority: P2)

**Goal**: Include a supplied forecast length from 1 through 16 and reject every out-of-range value before networking.

**Independent Test**: Inspect requests for counts `1` and `16`, confirm omitted count produces no `cnt`, and verify `-1`, `0`, and `17` throw `RestingError.invalidRequest` with zero captured requests.

### Tests for User Story 2

- [X] T006 [US2] Add failing accepted-boundary, rejected-count, omitted-count, coordinate-boundary, invalid-coordinate, and zero-network request tests in `Tests/OpenWeatherMapSwiftTests/DailyForecastTests.swift`

### Implementation for User Story 2

- [X] T007 [US2] Validate supplied `maximumDayCount` with the closed range `1...16` before execution and append its `cnt` query item exactly once in `Sources/OpenWeatherMapSwift/OpenWeatherClient.swift`

**Checkpoint**: T006-T007 prove count and coordinate boundaries locally without changing service-default or returned-count behavior.

---

## Phase 5: User Story 3 - Handle Product and Weather Variability (Priority: P3)

**Goal**: Preserve absent population, gust, rain, and snow values and expose Resting subscription, cancellation, transport, and decoding failures unchanged.

**Independent Test**: Decode a mixed-weather fixture without losing days, then inject representative status, cancellation, transport, and malformed-JSON failures and match their original Resting error cases and associated bytes.

### Tests for User Story 3

- [X] T008 [P] [US3] Add a compact fixture covering absent population plus independently dry, rainy, snowy, calm, and gusty days in `Tests/OpenWeatherMapSwiftTests/Fixtures/forecast-daily-optional.json`
- [X] T009 [US3] Add optional-value, subscription-response-byte, cancellation, transport, and decoding-response-byte preservation tests in `Tests/OpenWeatherMapSwiftTests/DailyForecastTests.swift`

**Checkpoint**: T008-T009 prove the direct `Decodable` model and untranslated Resting execution path satisfy variable weather and product-access behavior.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Publish the completed call site and run the required package gates.

- [X] T010 Update daily-forecast usage, `maximumDayCount` bounds, service-default behavior, units, language, and timestamp/timezone guidance in `README.md`
- [X] T011 Run every scenario in `docs/spec-kit/003-forecast-16-day-daily/quickstart.md` through `xcodebuildmcp swift-package build` and `xcodebuildmcp swift-package test`, confirming no live credential or public-network dependency

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; T001 establishes the baseline.
- **Foundational (Phase 2)**: Depends on T001; existing infrastructure is reused without changes.
- **User Story 1 (Phase 3)**: Depends on Phase 2 and creates the MVP API and model.
- **User Stories 2 and 3 (Phases 4-5)**: Both depend on User Story 1; after that they are behaviorally independent and may proceed in parallel if edits to `DailyForecastTests.swift` are coordinated.
- **Polish (Phase 6)**: Depends on all selected user stories.

### User Story Dependency Graph

```text
Setup -> Existing Foundation -> US1 (MVP) -> US2
                                      `-----> US3
US2 + US3 -> Polish and final gates
```

### Within Each User Story

- Create the story fixture before its tests.
- Add the story tests before implementation and observe the relevant failure where new production behavior is required.
- For US1, `DailyForecast.swift` and `OpenWeatherClient.swift` can be implemented in parallel after T003.
- Keep Resting failures untranslated and preserve both service-provided array orders.

### Parallel Opportunities

- T004 and T005 touch separate production files and can run in parallel after T003.
- After US1, US2 behavior and the T008 fixture can proceed in parallel.
- US2 and US3 can be developed concurrently only if their changes to `DailyForecastTests.swift` are serialized or coordinated.

---

## Parallel Example: User Story 1

After T003 records the failing contract:

```text
Task T004: Implement response types in Sources/OpenWeatherMapSwift/DailyForecast.swift
Task T005: Implement the client operation in Sources/OpenWeatherMapSwift/OpenWeatherClient.swift
```

## Parallel Example: User Story 2

User Story 2 has one test task followed by one production task, so it has no safe within-story parallel work. After US1, run T006-T007 concurrently with User Story 3 only while serializing edits to `Tests/OpenWeatherMapSwiftTests/DailyForecastTests.swift`.

## Parallel Example: User Story 3

After US1, T008 can run alongside User Story 2 because it changes only `Tests/OpenWeatherMapSwiftTests/Fixtures/forecast-daily-optional.json`; T009 follows T008.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete T001 and reuse the existing foundation.
2. Complete T002-T003 and observe the new contract tests fail.
3. Complete T004-T005 in parallel, then run the User Story 1 tests.
4. Stop and validate that a complete ordered 16-day response works independently.

### Incremental Delivery

1. Deliver US1 as the callable daily-forecast MVP.
2. Add US2 count bounds and request mapping without changing default behavior.
3. Add US3 variability and failure-preservation proof without adding error wrappers.
4. Complete README and build/test gates in T010-T011.

## Notes

- No new package, target, transport abstraction, options type, retry, cache, XML mode, date conversion, sorting, padding, or aggregation layer is needed.
- `entries`, `conditions`, timestamps, optional weather values, response bytes, and cancellation information remain service/Resting owned.
- Stop after T011; later geocoding specs can add their own scope.
