# Public API Contract: Geocoding

This contract defines the public declarations and observable request behavior for this feature.
Every public declaration receives a concise documentation comment during implementation.

## Use sites

```swift
import OpenWeatherMapSwift

let client = OpenWeatherClient(apiKey: apiKey)

let matches = try await client.geocode(
    place: "Istanbul,TR",
    maximumResultCount: 5
)

let postalArea = try await client.geocode(
    postalCode: "34000",
    countryCode: "TR"
)

let nearby = try await client.reverseGeocode(
    latitude: 41.0082,
    longitude: 28.9784,
    maximumResultCount: 5
)
```

## Client declarations

```swift
extension OpenWeatherClient {
    public func geocode(
        place: String,
        maximumResultCount: Int? = nil
    ) async throws -> [GeocodedLocation]

    public func geocode(
        postalCode: String,
        countryCode: String
    ) async throws -> PostalLocation

    public func reverseGeocode(
        latitude: Double,
        longitude: Double,
        maximumResultCount: Int? = nil
    ) async throws -> [GeocodedLocation]
}
```

The existing initializer and caller-supplied `RestClientConfiguration` remain unchanged. No
request/options wrapper or additional overload is added.

## Response declarations

```swift
public struct GeocodedLocation: Decodable, Sendable {
    public let name: String
    public let localizedNames: [String: String]?
    public let latitude: Double
    public let longitude: Double
    public let country: String
    public let state: String?
}

public struct PostalLocation: Decodable, Sendable {
    public let postalCode: String
    public let name: String
    public let latitude: Double
    public let longitude: Double
    public let country: String
}
```

Memberwise initializers are not public contract; these values represent service responses.

## Request contract

Each successful invocation executes exactly one bodyless `GET` request.

| Operation | Path | Required query | Conditional query |
| --- | --- | --- | --- |
| Place | `/geo/1.0/direct` | `q`, `appid`, each exactly once | `limit` only when supplied |
| Postal | `/geo/1.0/zip` | `zip`, `appid`, each exactly once | None |
| Reverse | `/geo/1.0/reverse` | `lat`, `lon`, `appid`, each exactly once | `limit` only when supplied |

The `zip` value is exactly `postalCode,countryCode`. Optional limits are omitted rather than
replaced by package defaults. Query construction uses `URLQueryItem` through Resting.

## Validation and errors

- Place, postal code, and country code must not be empty after trimming whitespace and newlines;
  nonblank values are sent unchanged.
- A supplied place limit must be within `1...5`, including both endpoints.
- Latitude `-90...90` and longitude `-180...180` are valid, including endpoints; non-finite and
  out-of-range coordinates are invalid.
- A supplied reverse limit must be positive; OpenWeather determines its upper bound.
- Invalid local input throws `RestingError.invalidRequest(reason:)` before Resting executes.
- The client does not catch or translate Resting failures. Callers retain cancellation, transport,
  invalid-response, rejected-status response bytes, and decoding diagnostics.
- Package-owned values expose no API-key property or description.

## Ordering and optionality

- Place and reverse arrays preserve service order and may successfully contain zero locations.
- `localizedNames` and `state` remain optional; no empty dictionary, fallback name, or state is
  synthesized.
- Every localized-name key and value is preserved without filtering.
