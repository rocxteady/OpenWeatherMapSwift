# Feature Specification: 16-Day Daily Forecast

**Feature Branch**: `003-forecast-16-day-daily`

**Created**: 2026-08-15

**Status**: Ready

**Input**: Daily forecast support for up to sixteen days.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Retrieve Daily Forecast (Priority: P1)

A library consumer requests a daily forecast for coordinates and receives ordered daily entries
with location metadata.

**Why this priority**: Daily planning is the feature's primary value.

**Independent Test**: A multi-day response fixture returns each day in source order with daily
temperatures, conditions, sun times, wind, clouds, and precipitation information.

**Acceptance Scenarios**:

1. **Given** a configured client, valid coordinates, and an eligible API subscription, **When** a
   daily forecast is requested, **Then** city metadata and ordered daily entries are returned.
2. **Given** unit and language preferences, **When** the daily forecast is requested, **Then**
   those preferences are applied and decoded values remain available.

---

### User Story 2 - Select Forecast Length (Priority: P2)

A library consumer chooses between one and sixteen forecast days.

**Why this priority**: Applications need control over forecast horizon while respecting product
limits.

**Independent Test**: Boundary request inspection confirms counts `1` and `16` are accepted and
values outside that range are rejected before network work.

**Acceptance Scenarios**:

1. **Given** a count from `1` through `16`, **When** the forecast is requested, **Then** that count
   is included in the request.
2. **Given** no count, **When** the forecast is requested, **Then** the service default determines
   the returned number of days.

---

### User Story 3 - Handle Product and Weather Variability (Priority: P3)

A library consumer receives clear service errors when the product is unavailable and usable
daily entries when optional precipitation or gust values are absent.

**Why this priority**: This endpoint requires subscription access and returns conditional fields.

**Independent Test**: Subscription-error and mixed-weather fixtures exercise both paths without a
live service.

**Acceptance Scenarios**:

1. **Given** an API key without product access, **When** a daily forecast is requested, **Then**
   the rejected status and response details remain available to the caller.
2. **Given** daily entries without rain, snow, or gust, **When** the response is decoded, **Then**
   each missing value remains absent without losing the day.

### Edge Cases

- Counts `1` and `16` are valid; zero, negative, and values above `16` are rejected locally.
- The service may return fewer days than requested.
- Rain, snow, and gust may be absent independently for each day.
- Daily temperature minima and maxima are distinct from current and three-hour timestamp values.
- Daily timestamps must be interpreted with the returned city timezone.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The existing weather client MUST request daily forecasts using latitude and
  longitude.
- **FR-002**: Consumers MUST be able to provide an optional day count from `1` through `16`.
- **FR-003**: Consumers MUST be able to select standard, metric, or imperial units and provide an
  optional language code.
- **FR-004**: The result MUST expose every JSON field documented in
  `docs/md-docs/forecast-16-day-daily.md` with documented optionality.
- **FR-005**: Daily entries and weather conditions MUST retain service ordering.
- **FR-006**: Invalid coordinates and out-of-range counts MUST fail before a request is sent.
- **FR-007**: Subscription, cancellation, transport, status, and decoding failure details MUST
  remain available to callers.
- **FR-008**: This feature MUST support JSON only and coordinate-based lookup only.
- **FR-009**: Endpoint-specific daily temperature and wind shapes MUST remain distinct when their
  meanings differ from existing weather types.

### Key Entities

- **Daily Forecast**: City metadata and an ordered collection of daily entries.
- **Daily Entry**: Date, sun times, day-part temperatures, perceived temperatures, pressure,
  humidity, weather conditions, wind, clouds, precipitation, and probability.
- **Daily Temperature**: Day, minimum, maximum, night, evening, and morning values.
- **Daily Perceived Temperature**: Day, night, evening, and morning values.
- **Day Count**: Optional inclusive value from one through sixteen.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Representative fixtures preserve 100% of documented daily and city fields.
- **SC-002**: A 16-entry fixture retains all 16 days in source order.
- **SC-003**: Counts `1` and `16` are sent successfully, while every tested out-of-range count
  produces zero network requests.
- **SC-004**: Fixtures without rain, snow, and gust decode every day with those values absent.
- **SC-005**: A simulated subscription rejection remains distinguishable from transport,
  cancellation, and decoding failures.

## Assumptions

- Specs `001-current-weather` and `002-forecast-5-day-3-hour` have established reusable client
  and genuinely shared weather concepts.
- Endpoint availability depends on the consumer's OpenWeather subscription.
- OpenWeather's JSON contract in `docs/md-docs/forecast-16-day-daily.md` is authoritative.
- The library does not check subscription eligibility before sending a request.
- Retries, caching, XML, and daily aggregation from three-hour data are outside this feature.

