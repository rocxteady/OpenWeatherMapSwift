# OpenWeatherMapSwift

A Swift package client for OpenWeather APIs.

## Current weather

The caller owns and supplies the API key. The package uses it only as the request's `appid` query
value and does not persist it.

```swift
import OpenWeatherMapSwift

let client = OpenWeatherClient(apiKey: apiKey)
let weather = try await client.currentWeather(
    latitude: 41.0082,
    longitude: 28.9784,
    units: .metric,
    language: "tr"
)

print(weather.measurements.temperature)
```

Latitude must be within `-90...90` and longitude within `-180...180`. Omit `units` to use the
OpenWeather default, or select `.standard`, `.metric`, or `.imperial`. The optional `language`
argument accepts an OpenWeather language code.

## 5-day / 3-hour forecast

```swift
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

`maximumTimestampCount` limits three-hour timestamps, not days, and must be positive when supplied.
Omit it to request the full service-provided timeline.

## 16-day daily forecast

```swift
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

`maximumDayCount` must be within `1...16`; omit it to use the service default. Units and language
behave like current-weather requests. Interpret each `forecastTime` using
`forecast.city.timezoneOffset`; sunrise and sunset remain Unix UTC seconds.

## Geocoding

```swift
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

Place, postal-code, and country-code values must not be blank and are sent unchanged. Direct
limits must be within `1...5`; reverse limits must be positive. Omit either optional limit to use
the service default. Reverse geocoding uses the same coordinate bounds as weather requests.
