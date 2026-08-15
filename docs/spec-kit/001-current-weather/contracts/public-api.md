# Public API Contract: Current Weather

This contract defines the public declarations and observable request behavior for Phase 1.
Every public declaration receives a concise documentation comment during implementation.

## Use site

```swift
import OpenWeatherMapSwift

let client = OpenWeatherClient(apiKey: apiKey)
let weather = try await client.currentWeather(
    latitude: 41.0082,
    longitude: 28.9784,
    units: .metric,
    language: "tr"
)
```

## Client declarations

```swift
public final class OpenWeatherClient: Sendable {
    public init(
        apiKey: String,
        configuration: RestClientConfiguration = .init()
    )

    public func currentWeather(
        latitude: Double,
        longitude: Double,
        units: UnitPreference? = nil,
        language: String? = nil
    ) async throws -> CurrentWeather
}

public enum UnitPreference: String, Sendable {
    case standard
    case metric
    case imperial
}
```

The initializer's public signature imports Resting for `RestClientConfiguration`; the package does
not redeclare or wrap that configuration.

## Response declarations

```swift
public struct CurrentWeather: Decodable, Sendable {
    public let coordinates: WeatherCoordinates
    public let conditions: [WeatherCondition]
    public let base: String
    public let measurements: CurrentWeatherMeasurements
    public let visibility: Int
    public let wind: Wind
    public let clouds: Clouds
    public let rain: Precipitation?
    public let snow: Precipitation?
    public let calculationTime: Int
    public let system: CurrentWeatherSystem
    public let timezoneOffset: Int
    public let locationID: Int
    public let locationName: String
    public let status: CurrentWeatherStatus
}

public struct WeatherCoordinates: Decodable, Sendable {
    public let longitude: Double
    public let latitude: Double
}

public struct WeatherCondition: Decodable, Sendable {
    public let id: Int
    public let group: String
    public let description: String
    public let icon: String
}

public struct CurrentWeatherMeasurements: Decodable, Sendable {
    public let temperature: Double
    public let feelsLike: Double
    public let minimumTemperature: Double?
    public let maximumTemperature: Double?
    public let pressure: Int
    public let humidity: Int
    public let seaLevelPressure: Int?
    public let groundLevelPressure: Int?
}

public struct Wind: Decodable, Sendable {
    public let speed: Double
    public let direction: Int
    public let gust: Double?
}

public struct Clouds: Decodable, Sendable {
    public let coverage: Int
}

public struct Precipitation: Decodable, Sendable {
    public let lastHour: Double
}

public struct CurrentWeatherSystem: Decodable, Sendable {
    public let type: Int?
    public let id: Int?
    public let message: Double?
    public let country: String
    public let sunrise: Int
    public let sunset: Int
}

public enum CurrentWeatherStatus: Decodable, Sendable {
    case number(Int)
    case text(String)
}
```

Memberwise initializers are not part of this phase's public contract; these types represent
service responses.

## Request contract

For a successful invocation the client executes exactly one request:

| Element | Value |
| --- | --- |
| Method | `GET` |
| URL | `https://api.openweathermap.org/data/2.5/weather` |
| Required query | `lat`, `lon`, `appid`, each exactly once |
| Conditional query | `units` only when supplied; `lang` only when supplied |
| Omitted query | `mode`, city name, city ID, and ZIP lookup |
| Body | None |

`units` uses the enum raw value. Optional preferences are omitted rather than serialized as empty
values. Query construction uses `URLQueryItem` through Resting.

## Validation and errors

- Latitude `-90...90` and longitude `-180...180` are valid, including endpoints.
- Any out-of-range value throws `RestingError.invalidRequest(reason:)` before Resting executes a
  request.
- The client does not catch or translate Resting failures. Callers receive `.cancelled`,
  `.transport`, `.invalidResponse`, `.statusCode`, or `.decoding` with their associated diagnostics.
- Package-owned values do not conform to `CustomStringConvertible` and expose no API-key property.
