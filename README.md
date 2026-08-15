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
