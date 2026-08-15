---

description: "Implementation tasks for the 5-day / 3-hour forecast feature"
---

# Tasks: 5-Day / 3-Hour Forecast

**Input**: Design documents from `docs/spec-kit/002-forecast-5-day-3-hour/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/public-api.md`, `quickstart.md`

**Tests**: Required by the feature specification and project governance. Add each story's tests before its production change and confirm they fail for the intended missing behavior.

**Organization**: Tasks are grouped by user story so the default forecast, optional count, and conditional weather behavior can be implemented and validated incrementally.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel because it changes a different file and has no dependency on an incomplete task
- **[Story]**: User story traced from `spec.md`
- Every task names the exact file it changes or validates

## Phase 1: Setup (Baseline)

**Purpose**: Establish that the existing package is healthy before feature work.

- [X] T001 Run `xcodebuildmcp swift-package build` and `xcodebuildmcp swift-package test` against `Package.swift` and record any pre-existing failure before editing

---

## Phase 2: Foundational (Shared Prerequisites)

**Purpose**: Reuse the existing coordinate validation and serialized request stub without adding a transport abstraction.

**Critical**: Complete this phase before user-story work.

- [X] T002 Extract the latitude/longitude guards into one private validator and call it from `currentWeather` in `Sources/OpenWeatherMapSwift/OpenWeatherClient.swift`, preserving current validation behavior
- [X] T003 [P] Make the existing client, fixture, query, and `StubURLProtocol` helpers accessible to an extension of the serialized suite in `Tests/OpenWeatherMapSwiftTests/CurrentWeatherTests.swift`

**Checkpoint**: Current-weather tests still pass, and forecast work can reuse both production validation and the existing test seam.

---

## Phase 3: User Story 1 - Retrieve Forecast Timeline (Priority: P1) MVP

**Goal**: Fetch a coordinate-based forecast with optional units and language, then expose the complete ordered timeline and city metadata.

**Independent Test**: A stubbed 40-entry response decodes all documented fields and preserves entry and condition order; request inspection finds one GET to `/data/2.5/forecast` with only the selected query preferences.

### Tests for User Story 1

- [X] T004 [P] [US1] Add a representative 40-entry response with distinguishable timestamps and multiple ordered conditions in `Tests/OpenWeatherMapSwiftTests/Fixtures/forecast-5-day-full.json`
- [X] T005 [US1] Add failing full-response, ordering, required/omitted query, coordinate-boundary, and invalid-coordinate tests as an extension of the serialized suite in `Tests/OpenWeatherMapSwiftTests/FiveDayForecastTests.swift`

### Implementation for User Story 1

- [X] T006 [US1] Implement the documented immutable `Decodable` and `Sendable` response graph with concise public documentation and exact coding keys in `Sources/OpenWeatherMapSwift/FiveDayForecast.swift`
- [X] T007 [US1] Implement `fiveDayForecast(latitude:longitude:maximumTimestampCount:units:language:)` using `RestClient`, shared coordinate validation, and conditional units/language query items in `Sources/OpenWeatherMapSwift/OpenWeatherClient.swift`

**Checkpoint**: The default forecast call and unit/language preferences work without a live API key or network.

---

## Phase 4: User Story 2 - Limit Returned Timestamps (Priority: P2)

**Goal**: Send a positive optional timestamp limit while leaving the query absent when no limit is supplied.

**Independent Test**: Request capture observes `cnt` exactly once for positive values, never for `nil`, and observes zero requests for zero or negative values; a short response remains authoritative when fewer entries are returned.

### Tests for User Story 2

- [X] T008 [US2] Add failing positive, omitted, zero, negative, and returned-count-independence tests in `Tests/OpenWeatherMapSwiftTests/FiveDayForecastTests.swift`

### Implementation for User Story 2

- [X] T009 [US2] Validate `maximumTimestampCount` before networking and append one `cnt` query item only when supplied in `Sources/OpenWeatherMapSwift/OpenWeatherClient.swift`

**Checkpoint**: Count selection is independently verified and does not alter or pad the decoded response.

---

## Phase 5: User Story 3 - Decode Conditional Weather (Priority: P3)

**Goal**: Preserve independently optional rain, snow, and gust values and expose Resting failure diagnostics unchanged.

**Independent Test**: A mixed dry/rain/snow/gust fixture decodes absent values as `nil`, while cancellation, transport, rejected-status, and malformed-JSON cases retain their Resting error case and associated bytes.

### Tests for User Story 3

- [X] T010 [P] [US3] Add a compact mixed-phenomena response fixture in `Tests/OpenWeatherMapSwiftTests/Fixtures/forecast-5-day-optional.json`
- [X] T011 [US3] Add conditional rain/snow/gust decoding, cancellation, transport, status-byte, malformed-JSON-byte, and API-key exposure tests in `Tests/OpenWeatherMapSwiftTests/FiveDayForecastTests.swift`

**Checkpoint**: Conditional values and representative failures satisfy the public contract without endpoint-specific error wrapping.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Publish the new call site and run the required package gates.

- [X] T012 [P] Add a concise 5-day forecast usage example and document the optional timestamp limit in `README.md`
- [X] T013 Run every scenario in `docs/spec-kit/002-forecast-5-day-3-hour/quickstart.md` with `xcodebuildmcp swift-package build` and `xcodebuildmcp swift-package test`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Starts after T001; T002 and T003 can run in parallel because they edit different files.
- **User Story 1 (Phase 3)**: Starts after Phase 2 and establishes the models and endpoint used by later stories.
- **User Story 2 (Phase 4)**: Starts after US1 because it extends the same public method with count behavior.
- **User Story 3 (Phase 5)**: Starts after US1; it may run in parallel with US2 because it changes only fixture and test behavior after the response graph exists.
- **Polish (Phase 6)**: T012 starts after the public API is complete; T013 runs after all selected stories and documentation are complete.

### User Story Dependencies

```text
Setup -> Foundation -> US1 (MVP) -> US2
                            \-----> US3
US2 + US3 -> Polish and final gates
```

- **US1 (P1)**: No dependency on another story; independently delivers the default forecast timeline.
- **US2 (P2)**: Depends on US1's client operation, then adds only count validation and query construction.
- **US3 (P3)**: Depends on US1's response graph, but is independent of US2.

### Within Each User Story

- Add the fixture before tests that load it.
- Add and run story tests before production changes; confirm failure is caused by missing story behavior.
- Implement models before the client operation that decodes them.
- Run the story tests at its checkpoint before proceeding.

### Parallel Opportunities

- T002 and T003 can run in parallel after T001.
- T004 can be prepared while the foundational tasks are finishing because it changes only a fixture.
- After US1, US2 and US3 can proceed in parallel.
- T010 can be prepared independently of T008 and T009.
- T012 can proceed alongside US3 verification once the final public call shape is stable.

---

## Parallel Example: User Story 3

```text
Task: "Add the mixed optional-weather fixture in Tests/OpenWeatherMapSwiftTests/Fixtures/forecast-5-day-optional.json"
Task: "Implement and verify count behavior for US2 in Sources/OpenWeatherMapSwift/OpenWeatherClient.swift and Tests/OpenWeatherMapSwiftTests/FiveDayForecastTests.swift"
```

---

## Implementation Strategy

### MVP First

1. Complete T001-T003.
2. Complete T004-T007 for US1.
3. Stop and run the US1 tests: the default forecast timeline is the MVP.

### Incremental Delivery

1. Add T008-T009 to support a timestamp limit.
2. Add T010-T011 to prove conditional values and failure preservation.
3. Complete T012-T013 only after the desired stories pass independently.

### Scope Guard

Do not add caching, retries, XML, daily aggregation, date conversion, city-name lookup, a transport protocol, another package target, or a new dependency. The existing Resting client, Foundation query items, shared weather value types, and serialized URL protocol seam cover this feature.

## Notes

- `[P]` marks work on separate files with no dependency on an unfinished task.
- Tests use bundled fixtures and must never require a live API key or public network.
- Preserve array order and Resting errors directly; do not sort, normalize, catch, or translate them.
- Commit after a task or a small logical group, and validate at each checkpoint.
