---

description: "Implementation tasks for current weather"
---

# Tasks: Current Weather

**Input**: Design documents from `docs/spec-kit/001-current-weather/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/public-api.md`, `quickstart.md`

**Tests**: Required by the feature specification and project constitution. Write each story's tests before its implementation changes and keep all tests offline.

**Organization**: Tasks are grouped by user story so each priority can be implemented and validated as an increment.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel with adjacent marked tasks because it changes a different file and has no dependency on an incomplete task
- **[Story]**: Maps the task to its user story
- Every task names the exact file it changes or validates

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm the existing package already supplies the required platform and dependency foundation.

- [X] T001 Verify Swift 6.3 mode, existing deployment targets, the single library target, and Resting 1.0.0-or-newer dependency remain unchanged in `Package.swift`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish the one deterministic test seam used by every story.

**CRITICAL**: Complete this phase before story-specific tests.

- [X] T002 Replace the generated example test with a private custom `URLProtocol` stub, request capture, response/error controls, and an ephemeral `RestClientConfiguration` helper in `Tests/OpenWeatherMapSwiftTests/CurrentWeatherTests.swift`

**Checkpoint**: Tests can exercise Resting without a live API key or public network.

---

## Phase 3: User Story 1 - Retrieve Current Conditions (Priority: P1) MVP

**Goal**: Let a consumer request typed current conditions by coordinate with optional unit and language preferences.

**Independent Test**: A configured stub returns the full fixture; every documented value is readable, two conditions retain service order, and captured requests contain the required and selected optional query items exactly once.

### Tests for User Story 1

- [X] T003 [US1] Add a representative response containing every documented field, two ordered weather conditions, and rain data to `Tests/OpenWeatherMapSwiftTests/Fixtures/current-weather-full.json`
- [X] T004 [US1] Add failing full-response decoding and request-construction tests covering GET path, no body, credentials, coordinates, units, language, and omission of unsupplied preferences in `Tests/OpenWeatherMapSwiftTests/CurrentWeatherTests.swift`

### Implementation for User Story 1

- [X] T005 [US1] Implement the documented immutable public `Decodable` and `Sendable` response graph, coding keys, ordered conditions, optional fields, and numeric/string status decoder in `Sources/OpenWeatherMapSwift/CurrentWeather.swift`
- [X] T006 [US1] Implement documented `UnitPreference`, reusable `OpenWeatherClient`, private API-key storage, one reused `RestClient`, and the async coordinate request using `RequestDefinition.query` in `Sources/OpenWeatherMapSwift/OpenWeatherClient.swift`

**Checkpoint**: User Story 1 passes against the full fixture and both optional-query request variants.

---

## Phase 4: User Story 2 - Handle Partial Observations (Priority: P2)

**Goal**: Decode responses that omit optional phenomena and station values without inventing defaults.

**Independent Test**: Minimal and string-status fixtures decode successfully; missing fields are `nil`, required fields remain readable, and the status preserves its original wire type.

### Tests for User Story 2

- [X] T007 [P] [US2] Add a response omitting optional temperatures, pressure levels, gust, rain, snow, and station fields to `Tests/OpenWeatherMapSwiftTests/Fixtures/current-weather-minimal.json`
- [X] T008 [P] [US2] Add a valid response whose `cod` value is a string to `Tests/OpenWeatherMapSwiftTests/Fixtures/current-weather-string-status.json`
- [X] T009 [US2] Add minimal-response optionality and numeric/string `CurrentWeatherStatus` decoding tests in `Tests/OpenWeatherMapSwiftTests/CurrentWeatherTests.swift`

**Checkpoint**: User Story 2 passes without changing the service's missing values or status representation.

---

## Phase 5: User Story 3 - Receive Actionable Failures (Priority: P3)

**Goal**: Reject invalid coordinates before networking and preserve Resting cancellation, transport, HTTP-status, and decoding diagnostics.

**Independent Test**: Boundary coordinates reach the stub; out-of-range coordinates make zero requests; cancellation, `URLError`, rejected status with bytes, and malformed JSON remain distinguishable Resting errors.

### Tests for User Story 3

- [X] T010 [US3] Add failing boundary, invalid-coordinate, cancellation, transport, status-code byte-retention, malformed-JSON, and sentinel credential-exposure tests in `Tests/OpenWeatherMapSwiftTests/CurrentWeatherTests.swift`

### Implementation for User Story 3

- [X] T011 [US3] Validate latitude in `-90...90` and longitude in `-180...180` before request execution with `RestingError.invalidRequest`, while leaving Resting execution failures untranslated, in `Sources/OpenWeatherMapSwift/OpenWeatherClient.swift`

**Checkpoint**: User Story 3 provides preflight validation and preserves all transport diagnostics.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Publish the implemented use site and run the required package gates.

- [X] T012 [P] Add the public current-weather usage example and document coordinate, units, language, and caller-owned API-key behavior in `README.md`
- [X] T013 Run `xcodebuildmcp swift-package build` for `Package.swift` and `xcodebuildmcp swift-package test` for `Tests/OpenWeatherMapSwiftTests/`, confirming no live credential or network is used

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Starts immediately.
- **Foundational (Phase 2)**: Depends on T001 and blocks story-specific tests.
- **User Story 1 (Phase 3)**: Depends on T002 and establishes the public model and client.
- **User Story 2 (Phase 4)**: Depends on T005; T007 and T008 can run together before T009.
- **User Story 3 (Phase 5)**: Depends on T006; T010 precedes T011.
- **Polish (Phase 6)**: T012 starts after the public API is stable; T013 runs after all selected stories and documentation are complete.

### User Story Completion Order

```text
Setup -> Foundation -> US1 (MVP) -> US2 -> US3 -> Polish
```

- **US1** has no dependency on another story.
- **US2** reuses the response graph delivered by US1 and adds independent partial-response proof.
- **US3** reuses the client delivered by US1 and independently proves validation and failure behavior.

### Within Each User Story

- Add fixtures before tests that consume them.
- Add tests before implementation changes and confirm the new tests fail for the intended reason.
- Implement models before client code that returns them.
- Complete the story checkpoint before moving to the next priority.

### Parallel Opportunities

- T007 and T008 create independent fixtures and can run in parallel.
- After T011, T012 can run independently while implementation review proceeds; T013 remains the final gate.

## Parallel Example: User Story 2

```text
Task T007: Create Tests/OpenWeatherMapSwiftTests/Fixtures/current-weather-minimal.json
Task T008: Create Tests/OpenWeatherMapSwiftTests/Fixtures/current-weather-string-status.json
```

## Implementation Strategy

### MVP First

1. Complete T001-T002.
2. Complete T003-T006 for User Story 1.
3. Run the User Story 1 tests and inspect the captured request.
4. Stop here for the smallest useful current-weather client.

### Incremental Delivery

1. Add T007-T009 to prove partial observations and status variants.
2. Add T010-T011 to prove validation and failure preservation.
3. Complete T012-T013 only after the selected stories pass independently.

## Notes

- Use Foundation and Resting already present in the package; add no transport protocol, target, dependency, cache, retry, persistence, credential storage, UI, or alternate lookup mode.
- Keep request logic in `OpenWeatherClient.swift`, response types in `CurrentWeather.swift`, and endpoint tests in `CurrentWeatherTests.swift`.
- Preserve upstream values and ordering; do not add conversions, defaults, or compatibility APIs.
