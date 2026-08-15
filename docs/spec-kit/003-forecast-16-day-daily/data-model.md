# Data Model: 16-Day Daily Forecast

All response values are immutable, public, `Decodable`, and `Sendable`. Unix times remain seconds
as `Int`; callers interpret forecast times with the returned city timezone. Temperatures and wind
speeds remain in the requested unit system, while rain and snow remain millimeters.

## Existing shared values

| Type | Daily forecast use | Reason for reuse |
| --- | --- | --- |
| `UnitPreference` | Optional request `units` value | Same three wire values and behavior. |
| `WeatherCoordinates` | Forecast city coordinates | Same `lat`/`lon` keys and meaning. |
| `WeatherCondition` | Each day's ordered conditions | Same complete object shape and meaning. |

Existing city, measurements, wind, clouds, and precipitation types are not reused because their
required fields, nesting, time periods, or semantics differ.

## DailyForecast

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `city` | `city` | `DailyForecastCity` | Yes |
| `status` | `cod` | `String` | Yes |
| `message` | `message` | `Double` | Yes |
| `entryCount` | `cnt` | `Int` | Yes |
| `entries` | `list` | `[DailyForecastEntry]` | Yes |

`entries` preserves service order. `entryCount` and the returned array are authoritative and may
contain fewer days than requested.

## DailyForecastCity

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `id` | `id` | `Int` | Yes |
| `name` | `name` | `String` | Yes |
| `coordinates` | `coord` | `WeatherCoordinates` | Yes |
| `country` | `country` | `String` | Yes |
| `population` | `population` | `Int?` | No |
| `timezoneOffset` | `timezone` | `Int` | Yes |

## DailyForecastEntry

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `forecastTime` | `dt` | `Int` | Yes |
| `sunrise` | `sunrise` | `Int` | Yes |
| `sunset` | `sunset` | `Int` | Yes |
| `temperature` | `temp` | `DailyTemperature` | Yes |
| `perceivedTemperature` | `feels_like` | `DailyPerceivedTemperature` | Yes |
| `pressure` | `pressure` | `Int` | Yes |
| `humidity` | `humidity` | `Int` | Yes |
| `conditions` | `weather` | `[WeatherCondition]` | Yes |
| `maximumWindSpeed` | `speed` | `Double` | Yes |
| `maximumWindDirection` | `deg` | `Int` | Yes |
| `windGust` | `gust` | `Double?` | No |
| `cloudCoverage` | `clouds` | `Int` | Yes |
| `rainVolume` | `rain` | `Double?` | No |
| `snowVolume` | `snow` | `Double?` | No |
| `precipitationProbability` | `pop` | `Double` | Yes |

Each entry independently preserves missing gust, rain, and snow as `nil`. `conditions` preserves
service order. Wind properties remain endpoint-specific because `speed` means the day's maximum
wind speed, not the observation-shaped nested `Wind` value.

## DailyTemperature

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `day` | `day` | `Double` | Yes |
| `minimum` | `min` | `Double` | Yes |
| `maximum` | `max` | `Double` | Yes |
| `night` | `night` | `Double` | Yes |
| `evening` | `eve` | `Double` | Yes |
| `morning` | `morn` | `Double` | Yes |

Minimum and maximum are daily extremes. The other values represent documented local day parts.

## DailyPerceivedTemperature

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `day` | `day` | `Double` | Yes |
| `night` | `night` | `Double` | Yes |
| `evening` | `eve` | `Double` | Yes |
| `morning` | `morn` | `Double` | Yes |

## Request validation

- Latitude is valid in the closed range `-90...90`; longitude is valid in `-180...180`.
- `maximumDayCount` is absent or within the closed range `1...16`.
- Invalid input throws `RestingError.invalidRequest` before Resting executes a request.
- Units and language have no package-added normalization or validation.

## Relationships and state

`OpenWeatherClient` returns one `DailyForecast`, which owns one city and an ordered collection of
daily entries. Each entry owns temperatures and an ordered condition list plus scalar weather
measurements. Calls have no mutable state transitions or persistent relationships.
