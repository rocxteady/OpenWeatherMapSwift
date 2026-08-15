# Phase 0 Research: Geocoding

## Public call shape

- **Decision**: Add `geocode(place:maximumResultCount:)`,
  `geocode(postalCode:countryCode:)`, and
  `reverseGeocode(latitude:longitude:maximumResultCount:)` to `OpenWeatherClient`. All are
  `async throws`; optional limits default to `nil`.
- **Rationale**: Labeled string arguments make the overloads unambiguous, the verbs describe the
  network operation, and `maximumResultCount` follows the package's existing count terminology.
  Separate request objects or endpoint-named overload families add surface without useful state.
- **Alternatives considered**: `directGeocoding` and `zipGeocoding` mirror upstream endpoint names
  but expose more service jargon. A generic request value, query parser, or overload per default
  adds code without improving the use site.

## Request construction and validation

- **Decision**: Use Resting `RequestDefinition.query` with `URLQueryItem`. Direct sends `q`,
  optional `limit`, and `appid` to `/geo/1.0/direct`; ZIP sends one `zip` value composed as
  `postalCode,countryCode` plus `appid` to `/geo/1.0/zip`; reverse sends `lat`, `lon`, optional
  `limit`, and `appid` to `/geo/1.0/reverse`. Reject blank required strings using a
  whitespace-and-newline check while sending nonblank input unchanged. Require direct limits in
  `1...5`, reverse limits greater than zero, and reuse coordinate validation.
- **Rationale**: The existing client already owns Resting, safe query encoding, and the coordinate
  boundary guard. Local validation meets the feature contract without parsing place components or
  semantically validating country codes.
- **Alternatives considered**: Manual URLs risk incorrect escaping. Trimming, parsing, clamping,
  or ISO lookup changes caller input or service semantics. A new transport or error type duplicates
  Resting.

## Response representation

- **Decision**: Introduce `GeocodedLocation` for direct and reverse results and `PostalLocation`
  for ZIP. Both expose flat latitude and longitude properties as delivered by the wire contract.
  Decode `local_names` as optional `[String: String]` and `state` as optional. Decode direct and
  reverse responses directly as arrays.
- **Rationale**: Direct and reverse share an identical object shape, while ZIP has distinct fields.
  A dictionary preserves arbitrary language and internal keys. Flat coordinate properties permit
  synthesized decoding; forcing these fields into the existing nested `WeatherCoordinates` shape
  would require custom decoding solely for type reuse.
- **Alternatives considered**: Fixed localized-name properties lose unknown keys. `[String: Any]`
  is neither strongly decodable nor safely sendable. Sorting, filtering, deduplicating, or wrapping
  arrays changes or obscures the upstream result.

## Failure and empty-result behavior

- **Decision**: Throw `RestingError.invalidRequest` before execution for invalid local input, and
  otherwise let Resting errors pass through untranslated. Treat `[]` from direct or reverse as a
  successful empty collection.
- **Rationale**: Resting already retains cancellation, transport failures, rejected-status bytes,
  and decoding evidence. The service contract defines an empty array as a valid no-match result.
- **Alternatives considered**: Endpoint-specific error wrapping can hide Resting evidence. Turning
  an empty array into an error invents behavior absent from OpenWeather.

## Test integration

- **Decision**: Reuse the existing serialized Swift Testing suite, configured Resting client,
  custom `URLProtocol`, fixture loader, and query inspector. Add one fixture per endpoint plus one
  shared empty-array fixture. Cover full decoding and order, optional values and arbitrary localized
  keys, exact request paths and queries, omitted limits, boundaries, zero-request validation,
  empty results, representative Resting failures, and credential exposure.
- **Rationale**: The current seam is deterministic, offline, and already exercises Resting without
  another protocol or dependency. One distinguishable fixture per wire contract proves each
  endpoint without a redundant matrix.
- **Alternatives considered**: Live requests require a secret and network. A mock transport
  duplicates Resting/Foundation facilities. Per-language or per-boundary fixture sets add upkeep
  without distinct contract coverage.

## Source basis

- `docs/md-docs/geocoding.md` is the authoritative endpoint contract.
- `Sources/OpenWeatherMapSwift/OpenWeatherClient.swift` establishes Resting execution, query,
  coordinate-validation, and credential-ownership patterns.
- `Sources/OpenWeatherMapSwift/CurrentWeather.swift` establishes public response-value conventions.
- `Tests/OpenWeatherMapSwiftTests/CurrentWeatherTests.swift` establishes the deterministic test seam.

All technical-context questions are resolved.
