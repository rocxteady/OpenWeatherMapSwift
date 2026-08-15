# Data Model: 5-Day / 3-Hour Forecast

All response values are immutable, public, `Decodable`, and `Sendable`. Unix times remain seconds
as `Int`, `dt_txt` remains the service's UTC `String`, and measurement values remain in the unit
system selected by the request.

## Existing shared values

| Type | Forecast use | Reason for reuse |
| --- | --- | --- |
| `UnitPreference` | Optional request `units` value | Same three wire values and behavior. |
| `WeatherCoordinates` | Forecast city coordinates | Same `lat`/`lon` keys and meaning. |
| `WeatherCondition` | Each entry's ordered conditions | Same complete object shape and meaning. |
| `Wind` | Each entry's wind values | Same required speed/direction and optional gust shape. |
| `Clouds` | Each entry's cloud coverage | Same `all` percentage shape. |

Current weather's `Precipitation`, measurements, and system types are not reused because their
wire keys or fields differ.

## FiveDayForecast

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `status` | `cod` | `String` | Yes |
| `message` | `message` | `Double` | Yes |
| `entryCount` | `cnt` | `Int` | Yes |
| `entries` | `list` | `[ThreeHourForecastEntry]` | Yes |
| `city` | `city` | `ForecastCity` | Yes |

`entries` preserves service order. The returned `entryCount` describes the response and may be less
than a requested maximum.

## ThreeHourForecastEntry

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `forecastTime` | `dt` | `Int` | Yes |
| `measurements` | `main` | `ThreeHourForecastMeasurements` | Yes |
| `conditions` | `weather` | `[WeatherCondition]` | Yes |
| `clouds` | `clouds` | `Clouds` | Yes |
| `wind` | `wind` | `Wind` | Yes |
| `visibility` | `visibility` | `Int` | Yes |
| `precipitationProbability` | `pop` | `Double` | Yes |
| `rain` | `rain` | `ThreeHourPrecipitation?` | No |
| `snow` | `snow` | `ThreeHourPrecipitation?` | No |
| `partOfDay` | `sys` | `ForecastPartOfDay` | Yes |
| `forecastTimeText` | `dt_txt` | `String` | Yes |

Each entry independently retains only the rain, snow, and gust values present in that timestamp.
`conditions` preserves service order.

## ThreeHourForecastMeasurements

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `temperature` | `temp` | `Double` | Yes |
| `feelsLike` | `feels_like` | `Double` | Yes |
| `minimumTemperature` | `temp_min` | `Double?` | No |
| `maximumTemperature` | `temp_max` | `Double?` | No |
| `pressure` | `pressure` | `Int` | Yes |
| `seaLevelPressure` | `sea_level` | `Int` | Yes |
| `groundLevelPressure` | `grnd_level` | `Int` | Yes |
| `humidity` | `humidity` | `Int` | Yes |
| `temperatureAdjustment` | `temp_kf` | `Double` | Yes |

## ThreeHourPrecipitation

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `threeHourVolume` | `3h` | `Double` | Yes when the parent rain or snow object exists |

Rain and snow remain millimeters regardless of the request's unit preference.

## ForecastPartOfDay

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `part` | `pod` | `String` | Yes |

The service supplies `d` for day or `n` for night. The model preserves the wire value rather than
adding a rejecting enum around an upstream string.

## ForecastCity

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `id` | `id` | `Int` | Yes |
| `name` | `name` | `String` | Yes |
| `coordinates` | `coord` | `WeatherCoordinates` | Yes |
| `country` | `country` | `String` | Yes |
| `population` | `population` | `Int` | Yes |
| `timezoneOffset` | `timezone` | `Int` | Yes |
| `sunrise` | `sunrise` | `Int` | Yes |
| `sunset` | `sunset` | `Int` | Yes |

## Request validation

- Latitude is valid in the closed range `-90...90`; longitude is valid in `-180...180`.
- `maximumTimestampCount` is absent or greater than zero.
- Invalid input throws `RestingError.invalidRequest` before Resting executes a request.
- Units and language have no package-added normalization or validation.

## Relationships and state

`OpenWeatherClient` returns one `FiveDayForecast`, which owns one city and an ordered collection of
entries. Each entry owns measurements, clouds, wind, part-of-day data, an ordered condition list,
and optional independent rain and snow values. Calls have no mutable state transitions or
persistent relationships.
