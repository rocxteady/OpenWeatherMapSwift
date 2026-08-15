# Public API Contract: 5-Day / 3-Hour Forecast

This contract defines the public declarations and observable request behavior for this feature.
Every public declaration receives a concise documentation comment during implementation.

## Use site

```swift
import OpenWeatherMapSwift

let client = OpenWeatherClient(apiKey: apiKey)
let forecast = try await client.fiveDayForecast(
    latitude: 41.0082,
    longitude: 28.9784,
    maximumTimestampCount: 8,
    units: .metric,
    language: "tr"
)

for entry in forecast.entries {
    print(entry.forecastTime, entry.measurements.temperature)
}
```

## Client declaration

```swift
extension OpenWeatherClient {
    public func fiveDayForecast(
        latitude: Double,
        longitude: Double,
        maximumTimestampCount: Int? = nil,
        units: UnitPreference? = nil,
        language: String? = nil
    ) async throws -> FiveDayForecast
}
```

The existing initializer, `UnitPreference`, and caller-supplied `RestClientConfiguration` remain
unchanged. No request/options wrapper or overload is added.

## Response declarations

```swift
public struct FiveDayForecast: Decodable, Sendable {
    public let status: String
    public let message: Double
    public let entryCount: Int
    public let entries: [ThreeHourForecastEntry]
    public let city: ForecastCity
}

public struct ThreeHourForecastEntry: Decodable, Sendable {
    public let forecastTime: Int
    public let measurements: ThreeHourForecastMeasurements
    public let conditions: [WeatherCondition]
    public let clouds: Clouds
    public let wind: Wind
    public let visibility: Int
    public let precipitationProbability: Double
    public let rain: ThreeHourPrecipitation?
    public let snow: ThreeHourPrecipitation?
    public let partOfDay: ForecastPartOfDay
    public let forecastTimeText: String
}

public struct ThreeHourForecastMeasurements: Decodable, Sendable {
    public let temperature: Double
    public let feelsLike: Double
    public let minimumTemperature: Double?
    public let maximumTemperature: Double?
    public let pressure: Int
    public let seaLevelPressure: Int
    public let groundLevelPressure: Int
    public let humidity: Int
    public let temperatureAdjustment: Double
}

public struct ThreeHourPrecipitation: Decodable, Sendable {
    public let threeHourVolume: Double
}

public struct ForecastPartOfDay: Decodable, Sendable {
    public let part: String
}

public struct ForecastCity: Decodable, Sendable {
    public let id: Int
    public let name: String
    public let coordinates: WeatherCoordinates
    public let country: String
    public let population: Int
    public let timezoneOffset: Int
    public let sunrise: Int
    public let sunset: Int
}
```

`WeatherCoordinates`, `WeatherCondition`, `Clouds`, and `Wind` are the existing public types.
Memberwise initializers are not part of the public contract; these values represent service
responses.

## Request contract

For a successful invocation the client executes exactly one request:

| Element | Value |
| --- | --- |
| Method | `GET` |
| URL | `https://api.openweathermap.org/data/2.5/forecast` |
| Required query | `lat`, `lon`, `appid`, each exactly once |
| Conditional query | `cnt`, `units`, and `lang` only when supplied |
| Omitted query | `mode`, city name, city ID, and ZIP lookup |
| Body | None |

`maximumTimestampCount` maps to `cnt`; units use `UnitPreference.rawValue`. Optional values are omitted,
not serialized as empty query items. Query construction uses `URLQueryItem` through Resting.

## Validation and errors

- Latitude `-90...90` and longitude `-180...180` are valid, including endpoints.
- A supplied `maximumTimestampCount` must be greater than zero.
- Invalid coordinates or counts throw `RestingError.invalidRequest(reason:)` before Resting
  executes a request.
- The client does not catch or translate Resting failures. Callers retain cancellation, transport,
  invalid-response, rejected-status response bytes, and decoding diagnostics.
- Package-owned values expose no API-key property or description.

## Ordering and optionality

- `entries` preserves `list` order and `conditions` preserves each `weather` order.
- `rain`, `snow`, and `wind.gust` are independent optional values.
- Minimum and maximum temperatures are optional as documented; no absent value is synthesized.
- The response's `entryCount` is authoritative even when it differs from
  `maximumTimestampCount`.
