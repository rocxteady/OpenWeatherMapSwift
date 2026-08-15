# Feature Specification: Geocoding

**Feature Branch**: `004-geocoding`

**Created**: 2026-08-15

**Status**: Ready

**Input**: Direct, ZIP, and reverse geocoding support.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Find Coordinates by Place (Priority: P1)

A library consumer searches by place name and receives ordered matching locations with
coordinates and available localized names.

**Why this priority**: Place search is the primary bridge from human input to weather endpoints.

**Independent Test**: A multi-result direct-geocoding fixture preserves every match, localized
name, coordinate, country, and optional state.

**Acceptance Scenarios**:

1. **Given** a non-empty place query, **When** direct geocoding is requested, **Then** up to the
   selected number of matching locations is returned in service order.
2. **Given** no matching place, **When** the service returns an empty array, **Then** the operation
   succeeds with no results.

---

### User Story 2 - Resolve Postal Code (Priority: P2)

A library consumer supplies a postal code and country code and receives that area's coordinate.

**Why this priority**: Postal codes are a common structured location input.

**Independent Test**: A ZIP response fixture returns postal code, name, coordinate, and country.

**Acceptance Scenarios**:

1. **Given** non-empty postal and country codes, **When** ZIP geocoding is requested, **Then** the
   matching postal-code area is returned.
2. **Given** a rejected postal-code lookup, **When** the operation fails, **Then** response status
   and body details remain available to the caller.

---

### User Story 3 - Find Names by Coordinate (Priority: P3)

A library consumer supplies coordinates and receives nearby named locations.

**Why this priority**: Reverse lookup makes coordinate-based weather data understandable to users.

**Independent Test**: A reverse-geocoding fixture returns ordered nearby names and optional
localized metadata.

**Acceptance Scenarios**:

1. **Given** valid coordinates, **When** reverse geocoding is requested, **Then** nearby locations
   are returned in service order.
2. **Given** a selected result limit, **When** reverse geocoding is requested, **Then** that limit
   is applied to the request.

### Edge Cases

- Empty or whitespace-only place, postal, or country values are rejected before network work.
- Direct and reverse result arrays may be empty.
- Localized-name dictionaries may be absent and may contain unknown language keys.
- State may be absent for any location.
- Direct-limit boundaries `1` and `5` are valid; other direct limits are rejected locally.
- A reverse limit must be positive; the service determines its upper bound.
- Coordinate boundaries follow the shared coordinate rules.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The existing client MUST support direct geocoding from a place query.
- **FR-002**: Direct geocoding MUST accept an optional result limit from `1` through `5`.
- **FR-003**: The client MUST support ZIP geocoding from a postal code and ISO 3166 country code.
- **FR-004**: The client MUST support reverse geocoding from latitude and longitude with an
  optional positive result limit.
- **FR-005**: Direct and reverse results MUST preserve service order and arbitrary localized-name
  keys.
- **FR-006**: An empty direct or reverse result MUST be returned as a successful empty collection.
- **FR-007**: Results MUST expose every JSON field documented in `docs/md-docs/geocoding.md` with
  documented optionality.
- **FR-008**: Invalid coordinates, limits, or blank required text MUST fail before a request is
  sent.
- **FR-009**: Cancellation and network-client failure details MUST remain available to callers.
- **FR-010**: Weather methods MUST continue using coordinates; geocoding MUST not restore
  deprecated built-in weather lookup by city name, city ID, or postal code.

### Key Entities

- **Geocoded Location**: Name, arbitrary localized names, coordinate, country, and optional state.
- **Postal Location**: Postal code, name, coordinate, and country.
- **Place Query**: Non-empty place text, optionally qualified by state and country components.
- **Result Limit**: Optional direct limit from one through five or positive reverse limit.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Direct and reverse fixtures preserve 100% of supplied locations and localized-name
  entries in source order.
- **SC-002**: ZIP fixtures preserve all five documented response fields.
- **SC-003**: Empty direct and reverse fixtures return successful collections containing zero
  locations.
- **SC-004**: Every invalid coordinate, limit, and blank required-text test produces zero network
  requests.
- **SC-005**: Request tests confirm each operation uses its documented path and query values
  exactly once.

## Assumptions

- The existing client and coordinate type come from prior numbered specs.
- Callers compose qualified direct queries such as `city,state,country`; the library does not
  parse or normalize query components.
- Country codes are passed through after rejecting blank input; semantic ISO validation belongs
  to OpenWeather.
- OpenWeather's JSON contract in `docs/md-docs/geocoding.md` is authoritative.
- Fuzzy matching, result ranking, offline gazetteers, caching, and address parsing are outside
  this feature.
