# Current Weather Data

Get current weather conditions for one geographic coordinate.

## Quick Reference

| Item | Value |
| --- | --- |
| Method | `GET` |
| URL | `https://api.openweathermap.org/data/2.5/weather` |
| Authentication | Required `appid` query parameter |
| Preferred location input | `lat` and `lon` |
| Default response | JSON |
| Other formats | XML or HTML through `mode` |

## Request

| Parameter | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `lat` | number | yes | — | Latitude in decimal degrees. |
| `lon` | number | yes | — | Longitude in decimal degrees. |
| `appid` | string | yes | — | OpenWeather API key. |
| `units` | string | no | `standard` | `standard`, `metric`, or `imperial`. |
| `lang` | string | no | — | Language code for translated location and weather descriptions. |
| `mode` | string | no | JSON | `xml` or `html`; omit for JSON. |

```bash
curl --get 'https://api.openweathermap.org/data/2.5/weather' \
  --data-urlencode 'lat=41.0082' \
  --data-urlencode 'lon=28.9784' \
  --data-urlencode 'units=metric' \
  --data-urlencode "appid=$OPENWEATHER_API_KEY"
```

## JSON Response

Illustrative response; optional phenomena are included to show their shapes.

```json
{
  "coord": { "lon": 28.9784, "lat": 41.0082 },
  "weather": [
    { "id": 500, "main": "Rain", "description": "light rain", "icon": "10d" }
  ],
  "base": "stations",
  "main": {
    "temp": 18.4,
    "feels_like": 18.1,
    "temp_min": 17.8,
    "temp_max": 19.2,
    "pressure": 1014,
    "humidity": 71,
    "sea_level": 1014,
    "grnd_level": 1008
  },
  "visibility": 10000,
  "wind": { "speed": 3.2, "deg": 230, "gust": 5.1 },
  "rain": { "1h": 0.4 },
  "clouds": { "all": 75 },
  "dt": 1786795200,
  "sys": {
    "type": 1,
    "id": 6970,
    "country": "TR",
    "sunrise": 1786759200,
    "sunset": 1786810200
  },
  "timezone": 10800,
  "id": 745044,
  "name": "Istanbul",
  "cod": 200
}
```

## Field Reference

| JSON path | Type | Unit / values | Description |
| --- | --- | --- | --- |
| `coord.lon` | number | degrees | Requested location longitude. |
| `coord.lat` | number | degrees | Requested location latitude. |
| `weather[]` | array | — | Weather conditions; more than one condition may be returned. |
| `weather[].id` | integer | condition code | Weather condition ID. |
| `weather[].main` | string | — | Condition group such as `Rain`, `Snow`, or `Clouds`. |
| `weather[].description` | string | — | Localizable condition description. |
| `weather[].icon` | string | icon ID | Weather icon identifier. |
| `base` | string | — | Internal data-source parameter. |
| `main.temp` | number | temperature | Current temperature. |
| `main.feels_like` | number | temperature | Human-perceived temperature. |
| `main.temp_min` | number | temperature | Optional minimum currently observed within the location. |
| `main.temp_max` | number | temperature | Optional maximum currently observed within the location. |
| `main.pressure` | integer | hPa | Atmospheric pressure at sea level by default. |
| `main.humidity` | integer | % | Relative humidity. |
| `main.sea_level` | integer | hPa | Sea-level pressure; may be absent. |
| `main.grnd_level` | integer | hPa | Ground-level pressure; may be absent. |
| `visibility` | integer | meters | Visibility, capped at 10,000 meters. |
| `wind.speed` | number | unit-system speed | Wind speed. |
| `wind.deg` | integer | degrees | Meteorological wind direction. |
| `wind.gust` | number | unit-system speed | Wind gust; may be absent. |
| `clouds.all` | integer | % | Cloudiness. |
| `rain.1h` | number | mm/h | Rain volume for the previous hour; present only when available. |
| `snow.1h` | number | mm/h | Snow volume for the previous hour; present only when available. |
| `dt` | integer | Unix, UTC | Time of data calculation. |
| `sys.type` | integer | — | Internal parameter; may be absent. |
| `sys.id` | integer | — | Internal parameter; may be absent. |
| `sys.message` | number | — | Internal parameter; may be absent. |
| `sys.country` | string | ISO 3166 country code | Country containing the location. |
| `sys.sunrise` | integer | Unix, UTC | Sunrise time. |
| `sys.sunset` | integer | Unix, UTC | Sunset time. |
| `timezone` | integer | seconds from UTC | Location timezone offset. |
| `id` | integer | city ID | Internal city identifier. Do not use it as the primary lookup method. |
| `name` | string | — | Location name. |
| `cod` | integer or string | HTTP-like status | Internal response status value. |

Temperature and wind-speed units follow `units`. Precipitation does not change with `units`.

## Behavior and Caveats

- Missing optional fields mean the phenomenon was not measured or calculated for this observation.
- `temp_min` and `temp_max` describe spatial variation at the current moment, not a daily range.
- Use [Geocoding API](geocoding.md) before this request when input starts as a place name or postal code.
- Built-in lookup by city name, city ID, or ZIP code remains available but is deprecated and is not documented here.

## Related Documents

- [Geocoding API](geocoding.md)
- [5-day / 3-hour forecast](forecast-5-day-3-hour.md)
- [16-day daily forecast](forecast-16-day-daily.md)

## Source

- [OpenWeather Current weather data](https://openweathermap.org/api/current), verified 2026-08-15.

