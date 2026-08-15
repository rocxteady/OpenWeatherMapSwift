# Data Model: Current Weather

All response values are immutable, public, `Decodable`, and `Sendable`. Numeric timestamps remain
Unix-second `Int` values and measurements remain service-supplied numeric values; the package does
not invent unit conversions or date semantics.

## OpenWeatherClient

Reusable configured entry point.

| Stored value | Visibility | Rule |
| --- | --- | --- |
| API key | Private | Supplied at initialization; used only as the `appid` query value. |
| Rest client | Private | Created once from the supplied `RestClientConfiguration` and reused. |

No lifecycle state machine is needed. Calls are independent and may overlap through Resting.

## UnitPreference

| Case | Wire value |
| --- | --- |
| `standard` | `standard` |
| `metric` | `metric` |
| `imperial` | `imperial` |

The entire preference is optional. Absence omits `units` so OpenWeather applies its default.

## CurrentWeather

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `coordinates` | `coord` | `WeatherCoordinates` | Yes |
| `conditions` | `weather` | `[WeatherCondition]` | Yes |
| `base` | `base` | `String` | Yes |
| `measurements` | `main` | `CurrentWeatherMeasurements` | Yes |
| `visibility` | `visibility` | `Int` | Yes |
| `wind` | `wind` | `Wind` | Yes |
| `clouds` | `clouds` | `Clouds` | Yes |
| `rain` | `rain` | `Precipitation` | No |
| `snow` | `snow` | `Precipitation` | No |
| `calculationTime` | `dt` | `Int` | Yes |
| `system` | `sys` | `CurrentWeatherSystem` | Yes |
| `timezoneOffset` | `timezone` | `Int` | Yes |
| `locationID` | `id` | `Int` | Yes |
| `locationName` | `name` | `String` | Yes |
| `status` | `cod` | `CurrentWeatherStatus` | Yes |

The `conditions` array preserves service order and cardinality.

## WeatherCoordinates

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `longitude` | `lon` | `Double` | Yes |
| `latitude` | `lat` | `Double` | Yes |

Request validation accepts latitude in the closed range `-90...90` and longitude in
`-180...180`. Values outside either range fail before Resting executes a request.

## WeatherCondition

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `id` | `id` | `Int` | Yes |
| `group` | `main` | `String` | Yes |
| `description` | `description` | `String` | Yes |
| `icon` | `icon` | `String` | Yes |

## CurrentWeatherMeasurements

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `temperature` | `temp` | `Double` | Yes |
| `feelsLike` | `feels_like` | `Double` | Yes |
| `minimumTemperature` | `temp_min` | `Double?` | No |
| `maximumTemperature` | `temp_max` | `Double?` | No |
| `pressure` | `pressure` | `Int` | Yes |
| `humidity` | `humidity` | `Int` | Yes |
| `seaLevelPressure` | `sea_level` | `Int?` | No |
| `groundLevelPressure` | `grnd_level` | `Int?` | No |

## Wind

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `speed` | `speed` | `Double` | Yes |
| `direction` | `deg` | `Int` | Yes |
| `gust` | `gust` | `Double?` | No |

## Clouds

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `coverage` | `all` | `Int` | Yes |

## Precipitation

Used independently by the optional `rain` and `snow` objects.

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `lastHour` | `1h` | `Double` | Yes when parent object exists |

## CurrentWeatherSystem

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `type` | `type` | `Int?` | No |
| `id` | `id` | `Int?` | No |
| `message` | `message` | `Double?` | No |
| `country` | `country` | `String` | Yes |
| `sunrise` | `sunrise` | `Int` | Yes |
| `sunset` | `sunset` | `Int` | Yes |

## CurrentWeatherStatus

| Case | Associated value | Wire form |
| --- | --- | --- |
| `number` | `Int` | JSON number |
| `text` | `String` | JSON string |

A single-value decoder attempts `Int` and then `String`; any other value produces the normal
decoding failure, which Resting wraps with the response bytes.

## Relationships

`OpenWeatherClient` returns one `CurrentWeather`. Each result owns one coordinate,
measurements, wind, clouds, system record, status, zero or one rain record, zero or one snow
record, and an ordered list of zero or more conditions. There are no mutable state transitions or
persistent relationships.
