# Phase 0 Research: Current Weather

## Resting request and execution path

- **Decision**: Construct the operation with `RequestDefinition.query(url:queryItems:)` and execute
  it with the configured `RestClient.execute(_:as:)` overload.
- **Rationale**: Resting 1.0.0 already appends `URLQueryItem` values safely, validates HTTP
  responses, decodes with its configured `JSONDecoder`, and exposes an async API. This is the
  shortest path that complies with the required transport.
- **Alternatives considered**: `URLSession` directly violates governance. A package-owned
  transport protocol duplicates the sole implementation. Manual URL interpolation risks incorrect
  query escaping.

## Client configuration and test seam

- **Decision**: Initialize one `RestClient` from a caller-supplied `RestClientConfiguration`, whose
  default value uses Resting defaults. Tests install a custom `URLProtocol` on an ephemeral
  `URLSessionConfiguration` and pass that through the same initializer.
- **Rationale**: This uses Resting and Foundation's existing seams, permits request inspection and
  stubbed responses without live traffic, and keeps one reusable network session per weather
  client.
- **Alternatives considered**: Injecting closures or a one-implementation protocol adds an
  abstraction forbidden by the constitution. A live OpenWeather test would require a credential
  and public network.

## Validation and failure behavior

- **Decision**: Check latitude against `-90...90` and longitude against `-180...180` at the start
  of `currentWeather`; throw `RestingError.invalidRequest(reason:)` before constructing or executing
  a request. Do not catch errors from `RestClient.execute`.
- **Rationale**: Resting's public error model already distinguishes invalid request, cancellation,
  transport, status-code, invalid-response, and decoding failures while retaining response bytes.
  Passing errors through preserves all diagnostics.
- **Alternatives considered**: A new weather error enum has no distinct domain behavior to add.
  Clamping coordinates would silently change caller input.

## Public call shape

- **Decision**: Use
  `currentWeather(latitude:longitude:units:language:) async throws -> CurrentWeather`, with optional
  `units` and `language` defaults.
- **Rationale**: The use site states both coordinate roles, avoids a speculative coordinate-input
  abstraction, and leaves the service defaults intact by omitting optional query items.
- **Alternatives considered**: Separate overloads multiply API surface. A public request/options
  type has only one operation to configure in this phase.

## Response representation

- **Decision**: Model each JSON object as an immutable public `Decodable & Sendable` value. Map
  snake-case keys with local `CodingKeys`, retain the `weather` array unchanged, and represent
  `cod` as an enum with integer and string cases using a single-value decoder.
- **Rationale**: Typed values preserve documented field shapes and optionality. The enum preserves
  both documented wire variants without weakening the rest of the model to untyped values.
- **Alternatives considered**: `[String: Any]` is not `Decodable` or `Sendable` and loses API
  clarity. Normalizing `cod` to a string loses its original wire type. Custom date or measurement
  wrappers would add semantics not required by the upstream contract.

## Source basis

- `docs/md-docs/current-weather.md` is the authoritative endpoint contract.
- `Package.swift` pins the Resting dependency range beginning at 1.0.0; `Package.resolved` selects
  revision `2c1d4d69849d959a5e7cd97dba239fb03ab9a57c`.
- The selected [Resting source](https://github.com/rocxteady/Resting/tree/2c1d4d69849d959a5e7cd97dba239fb03ab9a57c)
  defines `RestClient`, `RestClientConfiguration`, `RequestDefinition`, and `RestingError` used by
  this design.

All technical-context questions are resolved.
