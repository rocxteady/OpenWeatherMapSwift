# Public API Contract: 16-Day Daily Forecast

This contract defines the public declarations and observable request behavior for this feature.
Every public declaration receives a concise documentation comment during implementation.

## Use site

```swift
import OpenWeatherMapSwift

let client = OpenWeatherClient(apiKey: apiKey)
let forecast = try await client.dailyForecast(
    latitude: 41.0082,
    longitude: 28.9784,
    maximumDayCount: 16,
    units: .metric,
    language: "tr"
)

for entry in forecast.entries {
    print(entry.forecastTime, entry.temperature.maximum)
}
```

## Client declaration

```swift
extension OpenWeatherClient {
    public func dailyForecast(
        latitude: Double,
        longitude: Double,
        maximumDayCount: Int? = nil,
        units: UnitPreference? = nil,
        language: String? = nil
    ) async throws -> DailyForecast
}
```

The existing initializer, `UnitPreference`, and caller-supplied `RestClientConfiguration` remain
unchanged. No request/options wrapper or overload is added.

## Response declarations

```swift
public struct DailyForecast: Decodable, Sendable {
    public let city: DailyForecastCity
    public let status: String
    public let message: Double
    public let entryCount: Int
    public let entries: [DailyForecastEntry]
}

public struct DailyForecastCity: Decodable, Sendable {
    public let id: Int
    public let name: String
    public let coordinates: WeatherCoordinates
    public let country: String
    public let population: Int?
    public let timezoneOffset: Int
}

public struct DailyForecastEntry: Decodable, Sendable {
    public let forecastTime: Int
    public let sunrise: Int
    public let sunset: Int
    public let temperature: DailyTemperature
    public let perceivedTemperature: DailyPerceivedTemperature
    public let pressure: Int
    public let humidity: Int
    public let conditions: [WeatherCondition]
    public let maximumWindSpeed: Double
    public let maximumWindDirection: Int
    public let windGust: Double?
    public let cloudCoverage: Int
    public let rainVolume: Double?
    public let snowVolume: Double?
    public let precipitationProbability: Double
}

public struct DailyTemperature: Decodable, Sendable {
    public let day: Double
    public let minimum: Double
    public let maximum: Double
    public let night: Double
    public let evening: Double
    public let morning: Double
}

public struct DailyPerceivedTemperature: Decodable, Sendable {
    public let day: Double
    public let night: Double
    public let evening: Double
    public let morning: Double
}
```

`WeatherCoordinates` and `WeatherCondition` are existing public types. Memberwise initializers are
not part of the public contract; these values represent service responses.

## Request contract

For a successful invocation the client executes exactly one request:

| Element | Value |
| --- | --- |
| Method | `GET` |
| URL | `https://api.openweathermap.org/data/2.5/forecast/daily` |
| Required query | `lat`, `lon`, `appid`, each exactly once |
| Conditional query | `cnt`, `units`, and `lang` only when supplied |
| Omitted query | `mode`, city name, city ID, and ZIP lookup |
| Body | None |

`maximumDayCount` maps to `cnt`; units use `UnitPreference.rawValue`. Optional values are omitted rather
than serialized as empty query items. Query construction uses `URLQueryItem` through Resting.

## Validation and errors

- Latitude `-90...90` and longitude `-180...180` are valid, including endpoints.
- A supplied `maximumDayCount` must be in `1...16`, including both endpoints.
- Invalid coordinates or counts throw `RestingError.invalidRequest(reason:)` before Resting
  executes a request.
- The client does not preflight subscription access and does not catch or translate Resting
  failures. Callers retain cancellation, transport, invalid-response, rejected-status response
  bytes, and decoding diagnostics.
- Package-owned values expose no API-key property or description.

## Ordering, time, and optionality

- `entries` preserves `list` order and `conditions` preserves each `weather` order.
- `population`, `windGust`, `rainVolume`, and `snowVolume` are optional exactly as documented.
- No absent weather value is synthesized, and the response is not padded or truncated to
  `maximumDayCount`.
- `forecastTime` is interpreted using `city.timezoneOffset`; sunrise and sunset remain Unix UTC
  seconds.
