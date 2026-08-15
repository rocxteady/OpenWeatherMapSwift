---

description: "Dependency-ordered implementation tasks for geocoding"
---

# Tasks: Geocoding

**Input**: Design documents from `docs/spec-kit/004-geocoding/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/public-api.md`, `quickstart.md`

**Tests**: Required by the feature specification and project constitution. Write each story's tests first and confirm they fail before implementing that story's client operation.

**Organization**: Tasks are grouped by user story so each geocoding operation can be implemented and validated independently.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel with other marked fixture tasks because it changes different files
- **[Story]**: Maps the task to a user story in `spec.md`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm whether feature-specific project setup is needed.

The existing Swift package target, Resting dependency, copied fixture resources, and serialized `URLProtocol` test seam already satisfy the plan. No setup changes are required in `Package.swift`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add the response values required by the three operations without adding transport or request abstractions.

- [X] T001 Add documented `GeocodedLocation` and `PostalLocation` public `Decodable & Sendable` response values with explicit JSON key mappings and documentation comments in `Sources/OpenWeatherMapSwift/Geocoding.swift`

**Checkpoint**: The shared response contract compiles and all story-specific request work can begin.

---

## Phase 3: User Story 1 - Find Coordinates by Place (Priority: P1) 🎯 MVP

**Goal**: Return ordered direct-geocoding matches, including arbitrary localized names and optional state, for a validated place query.

**Independent Test**: Stub multi-result and empty-array fixtures; verify exact decoded values and ordering, exact direct request construction, omitted/default behavior, boundary acceptance, pre-network rejection, and preserved Resting failures without a live key or network.

### Tests for User Story 1

> Write these tests first and confirm they fail before T004.

- [X] T002 [P] [US1] Add distinguishable ordered direct results and a shared empty-array response in `Tests/OpenWeatherMapSwiftTests/Fixtures/geocoding-direct.json` and `Tests/OpenWeatherMapSwiftTests/Fixtures/geocoding-empty.json`
- [X] T003 [US1] Add direct-geocoding decoding, localized-name/state optionality, empty-result, bodyless GET path/query uniqueness, unchanged nonblank input, omitted limit, valid limits `1` and `5`, invalid/blank zero-request, cancellation, and API-key exposure tests in `Tests/OpenWeatherMapSwiftTests/GeocodingTests.swift`

### Implementation for User Story 1

- [X] T004 [US1] Implement documented `geocode(place:maximumResultCount:)` validation, `/geo/1.0/direct` query construction, and untranslated Resting execution in `Sources/OpenWeatherMapSwift/OpenWeatherClient.swift`

**Checkpoint**: Direct geocoding passes its fixture, request, validation, empty-result, failure, and credential tests independently.

---

## Phase 4: User Story 2 - Resolve Postal Code (Priority: P2)

**Goal**: Return the documented postal-code area for validated postal and country values.

**Independent Test**: Stub one ZIP response; verify all five fields, the exact composed ZIP query, unchanged input, local blank rejection, and rejected-status evidence preservation.

### Tests for User Story 2

> Write these tests first and confirm they fail before T007.

- [X] T005 [P] [US2] Add a complete postal location response in `Tests/OpenWeatherMapSwiftTests/Fixtures/geocoding-zip.json`
- [X] T006 [US2] Add ZIP decoding, bodyless GET path/query uniqueness, exact `postalCode,countryCode` composition, unchanged nonblank input, no semantic country validation, blank zero-request, rejected-status response-byte, and API-key exposure tests in `Tests/OpenWeatherMapSwiftTests/GeocodingTests.swift`

### Implementation for User Story 2

- [X] T007 [US2] Implement documented `geocode(postalCode:countryCode:)` validation, `/geo/1.0/zip` query construction, and untranslated Resting execution in `Sources/OpenWeatherMapSwift/OpenWeatherClient.swift`

**Checkpoint**: ZIP geocoding passes its fixture, request, validation, failure, and credential tests independently.

---

## Phase 5: User Story 3 - Find Names by Coordinate (Priority: P3)

**Goal**: Return ordered nearby names for validated coordinates and an optional positive result limit.

**Independent Test**: Stub ordered reverse and empty-array responses; verify exact decoded values and ordering, exact reverse request construction, coordinate and limit boundaries, pre-network rejection, and preserved Resting failures.

### Tests for User Story 3

> Write these tests first and confirm they fail before T010.

- [X] T008 [P] [US3] Add distinguishable ordered reverse results with present and absent optional metadata in `Tests/OpenWeatherMapSwiftTests/Fixtures/geocoding-reverse.json`
- [X] T009 [US3] Add reverse decoding/order/optionality, shared empty-result, bodyless GET path/query uniqueness, omitted and positive limit, coordinate boundary, invalid coordinate/nonpositive-limit zero-request, transport/malformed-JSON evidence, and API-key exposure tests in `Tests/OpenWeatherMapSwiftTests/GeocodingTests.swift`

### Implementation for User Story 3

- [X] T010 [US3] Implement documented `reverseGeocode(latitude:longitude:maximumResultCount:)` validation, `/geo/1.0/reverse` query construction, and untranslated Resting execution using the existing coordinate guard in `Sources/OpenWeatherMapSwift/OpenWeatherClient.swift`

**Checkpoint**: Reverse geocoding passes its fixture, request, validation, empty-result, failure, and credential tests independently.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Publish usage and run the required package gates without expanding feature scope.

- [X] T011 Add direct, ZIP, and reverse geocoding usage plus validation/default notes in `README.md`
- [X] T012 Run `xcodebuildmcp swift-package build` against `Package.swift` and resolve only geocoding-related build failures
- [X] T013 Run `xcodebuildmcp swift-package test` against `Package.swift` and resolve only geocoding-related test failures

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No changes required; the existing package infrastructure is ready.
- **Foundational (Phase 2)**: Starts immediately and blocks all user-story implementation.
- **User Stories (Phases 3-5)**: Depend on T001. They are behaviorally independent, but T003/T006/T009 share `GeocodingTests.swift` and T004/T007/T010 share `OpenWeatherClient.swift`, so serialize edits to those files.
- **Polish (Phase 6)**: T011 follows the public API implementation; T012 and T013 follow all desired story tasks.

### User Story Dependencies

- **User Story 1 (P1)**: Depends only on T001 and is the suggested MVP.
- **User Story 2 (P2)**: Depends only on T001; it does not require User Story 1 behavior.
- **User Story 3 (P3)**: Depends only on T001; it reuses `GeocodedLocation` and the existing coordinate guard, not another story's operation.

### Within Each User Story

- Create the fixture before its tests.
- Write tests and confirm failure before implementing the operation.
- Implement validation before any Resting execution path.
- Complete the story checkpoint before treating that story as deliverable.

### Parallel Opportunities

- After T001, T002, T005, and T008 can run in parallel because they create distinct fixture files (T002 alone owns the shared empty fixture).
- Different story test designs can be prepared in parallel, but edits must be merged serially into `GeocodingTests.swift`.
- Different client operations are logically independent, but edits must be merged serially into `OpenWeatherClient.swift`.

---

## Parallel Example: Fixture Preparation

```text
Task T002: Create direct and empty fixtures.
Task T005: Create the ZIP fixture.
Task T008: Create the reverse fixture.
```

## Parallel Example: User Story 1

```text
Task T002: Create the direct and empty fixtures while T001 is under review.
Then T003: Add and run the direct tests.
Then T004: Implement the direct operation and rerun those tests.
```

## Parallel Example: User Story 2

```text
Task T005: Create the ZIP fixture while T001 is under review.
Then T006: Add and run the ZIP tests.
Then T007: Implement the ZIP operation and rerun those tests.
```

## Parallel Example: User Story 3

```text
Task T008: Create the reverse fixture while T001 is under review.
Then T009: Add and run the reverse tests.
Then T010: Implement the reverse operation and rerun those tests.
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete T001.
2. Complete T002-T004 in order.
3. Run the direct-geocoding tests and the package build/test gates.
4. Stop with a usable place-to-coordinate API before adding lower-priority operations.

### Incremental Delivery

1. Foundation → shared response values compile.
2. User Story 1 → direct place lookup is independently usable and tested.
3. User Story 2 → ZIP lookup is independently usable and tested.
4. User Story 3 → reverse lookup is independently usable and tested.
5. README and full build/test gates complete the feature.

## Notes

- Preserve upstream arrays and dictionaries without sorting, filtering, normalization, caching, or retries.
- Use only Foundation, Resting, and the existing test seam; add no dependency, target, transport protocol, request wrapper, actor, task, lock, or queue.
- Keep invalid input failures in `RestingError.invalidRequest` and let all Resting execution failures pass through untranslated.
