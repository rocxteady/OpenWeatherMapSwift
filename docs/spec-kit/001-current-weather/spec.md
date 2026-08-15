# Feature Specification: Current Weather

**Feature Branch**: `001-current-weather`

**Created**: 2026-08-15

**Status**: Ready

**Input**: Current weather support for the OpenWeatherMap Swift client.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Retrieve Current Conditions (Priority: P1)

A library consumer requests current conditions for a geographic coordinate and receives typed
weather data suitable for application use.

**Why this priority**: This is the smallest useful weather-client capability and establishes the
shared client configuration used by later features.

**Independent Test**: A representative current-weather response can be requested through a
configured test client and every documented value can be read from the result.

**Acceptance Scenarios**:

1. **Given** a configured client and valid coordinates, **When** current weather is requested,
   **Then** one current observation is returned with location, conditions, measurements, wind,
   clouds, visibility, system times, and timezone data.
2. **Given** valid coordinates plus unit and language preferences, **When** current weather is
   requested, **Then** those preferences are applied to the request and the response is decoded.

---

### User Story 2 - Handle Partial Observations (Priority: P2)

A library consumer receives a usable observation when optional phenomena or station values are
absent.

**Why this priority**: OpenWeather omits values such as precipitation, gusts, and pressure levels
when unavailable.

**Independent Test**: Minimal and phenomenon-rich response fixtures both decode without invented
defaults.

**Acceptance Scenarios**:

1. **Given** a response without rain, snow, gust, or optional station fields, **When** it is
   decoded, **Then** required data remains available and missing values remain absent.
2. **Given** multiple weather conditions, **When** the response is decoded, **Then** every
   condition is retained in service order.

---

### User Story 3 - Receive Actionable Failures (Priority: P3)

A library consumer can distinguish invalid input, cancellation, transport failure, rejected HTTP
status, and decoding failure.

**Why this priority**: Applications need reliable failure handling without losing diagnostics.

**Independent Test**: Each representative failure reaches the caller without a live network.

**Acceptance Scenarios**:

1. **Given** coordinates outside accepted bounds, **When** weather is requested, **Then** the call
   fails before any network request.
2. **Given** a cancelled operation or non-success response, **When** the request completes,
   **Then** existing cancellation or response details remain available to the caller.

### Edge Cases

- Latitude boundaries `-90` and `90`, and longitude boundaries `-180` and `180`, are valid.
- Values outside coordinate bounds are rejected before network work.
- Conditional `rain.1h` and `snow.1h` objects may be absent independently.
- The weather-condition array may contain multiple entries.
- The service may encode its internal status value as either a number or string.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The package MUST provide a reusable client configured with an OpenWeather API key.
- **FR-002**: The client MUST request current weather using latitude and longitude.
- **FR-003**: Consumers MUST be able to select standard, metric, or imperial units, with service
  default behavior when no selection is supplied.
- **FR-004**: Consumers MUST be able to provide an optional language code.
- **FR-005**: The result MUST expose every JSON field documented in
  `docs/md-docs/current-weather.md` with documented optionality.
- **FR-006**: The result MUST preserve all returned weather conditions in their original order.
- **FR-007**: Invalid coordinates MUST fail before a request is sent.
- **FR-008**: Cancellation, transport, response-status, and decoding failures MUST retain the
  diagnostic information supplied by the shared network client.
- **FR-009**: Package-owned values and descriptions MUST not expose the configured API key.
- **FR-010**: This feature MUST support JSON only and MUST not add deprecated city-name, city-ID,
  or postal-code weather lookup.

### Key Entities

- **Weather Client**: Reusable configured entry point for OpenWeather operations.
- **Coordinate**: Latitude and longitude identifying the requested location.
- **Current Weather**: One observation containing location, conditions, measurements, visibility,
  wind, clouds, precipitation, calculation time, system times, and timezone offset.
- **Weather Condition**: Service condition identifier, group, description, and icon identifier.
- **Unit Preference**: Standard, metric, or imperial measurement selection.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Valid fixtures containing every documented current-weather field decode with 100%
  of supplied values preserved.
- **SC-002**: Minimal fixtures omitting every optional field still produce a usable observation.
- **SC-003**: All invalid coordinate cases are rejected with zero network requests.
- **SC-004**: Request inspection confirms credentials, coordinates, units, and language are each
  sent exactly once when applicable.
- **SC-005**: Cancellation and representative network failures remain distinguishable in all
  automated tests.

## Assumptions

- Consumers supply and manage their own valid API key.
- The package does not persist credentials or weather responses.
- OpenWeather's JSON contract in `docs/md-docs/current-weather.md` is authoritative for this phase.
- Automatic retries, caching, XML, HTML, and Combine convenience APIs are outside this feature.

