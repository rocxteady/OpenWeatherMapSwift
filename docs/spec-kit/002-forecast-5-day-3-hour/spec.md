# Feature Specification: 5-Day / 3-Hour Forecast

**Feature Branch**: `002-forecast-5-day-3-hour`

**Created**: 2026-08-15

**Status**: Ready

**Input**: Five-day forecast support in three-hour intervals.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Retrieve Forecast Timeline (Priority: P1)

A library consumer requests the five-day forecast for coordinates and receives the ordered
three-hour forecast timeline plus location metadata.

**Why this priority**: The timeline is the feature's primary user value.

**Independent Test**: A multi-entry response fixture returns every forecast entry in source order
with its timestamp and measurements.

**Acceptance Scenarios**:

1. **Given** a configured client and valid coordinates, **When** the forecast is requested,
   **Then** the response contains its city metadata and ordered three-hour entries.
2. **Given** unit and language preferences, **When** the forecast is requested, **Then** both
   preferences are applied and the response is decoded.

---

### User Story 2 - Limit Returned Timestamps (Priority: P2)

A library consumer can request fewer forecast timestamps when the full timeline is unnecessary.

**Why this priority**: Smaller responses support focused application experiences.

**Independent Test**: Request inspection confirms a positive count is sent only when supplied.

**Acceptance Scenarios**:

1. **Given** a positive timestamp count, **When** the forecast is requested, **Then** that count
   is included in the request.
2. **Given** no timestamp count, **When** the forecast is requested, **Then** the service default
   determines the returned count.

---

### User Story 3 - Decode Conditional Weather (Priority: P3)

A library consumer can use forecast entries whether precipitation and gust data are present or
absent.

**Why this priority**: Conditional weather values are common and must not break a full timeline.

**Independent Test**: Fixtures mixing dry, rainy, snowy, calm, and gusty timestamps all decode.

**Acceptance Scenarios**:

1. **Given** entries with different optional phenomena, **When** the response is decoded,
   **Then** each entry retains only values supplied for that timestamp.
2. **Given** malformed data or a rejected response, **When** the operation fails, **Then** the
   caller receives the existing network-client diagnostics.

### Edge Cases

- A count of zero or less is rejected before network work.
- The returned count may differ from the requested count when the service has less data.
- Rain, snow, and gust may appear independently on each entry.
- Human-readable timestamps are UTC; location offset remains separately available.
- Each entry may contain multiple weather conditions.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The existing weather client MUST request the 5-day/3-hour forecast using latitude
  and longitude.
- **FR-002**: Consumers MUST be able to provide an optional positive maximum timestamp count.
- **FR-003**: Consumers MUST be able to select standard, metric, or imperial units and provide an
  optional language code.
- **FR-004**: The result MUST expose every JSON field documented in
  `docs/md-docs/forecast-5-day-3-hour.md` with documented optionality.
- **FR-005**: Forecast entries and their weather conditions MUST retain service ordering.
- **FR-006**: Invalid coordinates and non-positive counts MUST fail before a request is sent.
- **FR-007**: Cancellation and network-client failure details MUST remain available to callers.
- **FR-008**: This feature MUST support JSON only and coordinate-based lookup only.
- **FR-009**: Shared concepts from current weather MUST reuse the established public types only
  when their meaning and response shape match.

### Key Entities

- **Forecast Timeline**: Response metadata and an ordered collection of three-hour entries.
- **Forecast Entry**: Timestamped temperature, pressure, humidity, conditions, clouds, wind,
  visibility, precipitation probability, and conditional precipitation volumes.
- **Forecast City**: Location name, coordinate, country, population, timezone, sunrise, and sunset.
- **Timestamp Count**: Optional positive limit on returned three-hour entries.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Representative fixtures preserve 100% of documented forecast and city fields.
- **SC-002**: A 40-entry fixture retains all 40 entries in source order.
- **SC-003**: Mixed optional-phenomena fixtures decode with zero invented precipitation or gust
  values.
- **SC-004**: Every non-positive count and invalid coordinate test produces zero network requests.
- **SC-005**: Request tests confirm optional count, units, and language are omitted or included
  exactly as selected.

## Assumptions

- Spec `001-current-weather` has established the client, coordinate, unit, and shared condition
  concepts.
- Count limits timestamps, not days; the upstream service decides its maximum available count.
- OpenWeather's JSON contract in `docs/md-docs/forecast-5-day-3-hour.md` is authoritative.
- Aggregation into daily summaries, retries, caching, and XML are outside this feature.

