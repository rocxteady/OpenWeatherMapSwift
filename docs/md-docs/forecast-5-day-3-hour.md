# 5-Day / 3-Hour Forecast

Get forecast data in 3-hour steps for the next 5 days.

## Quick Reference

| Item | Value |
| --- | --- |
| Method | `GET` |
| URL | `https://api.openweathermap.org/data/2.5/forecast` |
| Authentication | Required `appid` query parameter |
| Preferred location input | `lat` and `lon` |
| Forecast interval | 3 hours |
| Default response | JSON |
| Other format | XML through `mode=xml` |

## Request

| Parameter | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `lat` | number | yes | — | Latitude in decimal degrees. |
| `lon` | number | yes | — | Longitude in decimal degrees. |
| `appid` | string | yes | — | OpenWeather API key. |
| `cnt` | integer | no | all available | Maximum number of 3-hour timestamps to return. |
| `units` | string | no | `standard` | `standard`, `metric`, or `imperial`. |
| `lang` | string | no | — | Language code for translated location and weather descriptions. |
| `mode` | string | no | JSON | Set to `xml` for XML. |

```bash
curl --get 'https://api.openweathermap.org/data/2.5/forecast' \
  --data-urlencode 'lat=41.0082' \
  --data-urlencode 'lon=28.9784' \
  --data-urlencode 'units=metric' \
  --data-urlencode "appid=$OPENWEATHER_API_KEY"
```

## JSON Response

Illustrative response with one forecast item. Real responses contain multiple entries in `list`.

```json
{
  "cod": "200",
  "message": 0,
  "cnt": 1,
  "list": [
    {
      "dt": 1786806000,
      "main": {
        "temp": 19.2,
        "feels_like": 18.9,
        "temp_min": 18.7,
        "temp_max": 19.2,
        "pressure": 1013,
        "sea_level": 1013,
        "grnd_level": 1007,
        "humidity": 68,
        "temp_kf": 0.5
      },
      "weather": [
        { "id": 500, "main": "Rain", "description": "light rain", "icon": "10d" }
      ],
      "clouds": { "all": 72 },
      "wind": { "speed": 3.5, "deg": 225, "gust": 5.4 },
      "visibility": 10000,
      "pop": 0.65,
      "rain": { "3h": 1.2 },
      "sys": { "pod": "d" },
      "dt_txt": "2026-08-15 15:00:00"
    }
  ],
  "city": {
    "id": 745044,
    "name": "Istanbul",
    "coord": { "lat": 41.0082, "lon": 28.9784 },
    "country": "TR",
    "population": 15460000,
    "timezone": 10800,
    "sunrise": 1786759200,
    "sunset": 1786810200
  }
}
```

## Field Reference

| JSON path | Type | Unit / values | Description |
| --- | --- | --- | --- |
| `cod` | string | HTTP-like status | Internal response status value. |
| `message` | number | — | Internal parameter. |
| `cnt` | integer | entries | Number of returned forecast timestamps. |
| `list[]` | array | — | Forecast entries ordered in 3-hour steps. |
| `list[].dt` | integer | Unix, UTC | Forecast timestamp. |
| `list[].main.temp` | number | temperature | Forecast temperature. |
| `list[].main.feels_like` | number | temperature | Human-perceived temperature. |
| `list[].main.temp_min` | number | temperature | Optional minimum temperature within the location at this timestamp. |
| `list[].main.temp_max` | number | temperature | Optional maximum temperature within the location at this timestamp. |
| `list[].main.pressure` | integer | hPa | Atmospheric pressure at sea level by default. |
| `list[].main.sea_level` | integer | hPa | Sea-level pressure. |
| `list[].main.grnd_level` | integer | hPa | Ground-level pressure. |
| `list[].main.humidity` | integer | % | Relative humidity. |
| `list[].main.temp_kf` | number | temperature | Internal temperature adjustment parameter. |
| `list[].weather[]` | array | — | Weather conditions for the timestamp. |
| `list[].weather[].id` | integer | condition code | Weather condition ID. |
| `list[].weather[].main` | string | — | Condition group. |
| `list[].weather[].description` | string | — | Localizable condition description. |
| `list[].weather[].icon` | string | icon ID | Weather icon identifier. |
| `list[].clouds.all` | integer | % | Cloudiness. |
| `list[].wind.speed` | number | unit-system speed | Wind speed. |
| `list[].wind.deg` | integer | degrees | Meteorological wind direction. |
| `list[].wind.gust` | number | unit-system speed | Wind gust; may be absent. |
| `list[].visibility` | integer | meters | Average visibility, capped at 10,000 meters. |
| `list[].pop` | number | `0` to `1` | Probability of precipitation. |
| `list[].rain.3h` | number | mm | Rain volume for the 3-hour period; conditional. |
| `list[].snow.3h` | number | mm | Snow volume for the 3-hour period; conditional. |
| `list[].sys.pod` | string | `d` or `n` | Day or night part for the timestamp. |
| `list[].dt_txt` | string | UTC | Human-readable forecast timestamp. |
| `city.id` | integer | city ID | Internal city identifier. |
| `city.name` | string | — | Location name. |
| `city.coord.lat` | number | degrees | Location latitude. |
| `city.coord.lon` | number | degrees | Location longitude. |
| `city.country` | string | ISO 3166 country code | Location country. |
| `city.population` | integer | people | City population. |
| `city.timezone` | integer | seconds from UTC | Location timezone offset. |
| `city.sunrise` | integer | Unix, UTC | Sunrise time. |
| `city.sunset` | integer | Unix, UTC | Sunset time. |

Temperature and wind-speed units follow `units`. Rain and snow remain millimeters.

## Behavior and Caveats

- `cnt` limits timestamps, not days. Eight timestamps represent approximately one day.
- `dt_txt` is UTC; use `city.timezone` when rendering local time.
- `temp_min` and `temp_max` are values for one forecast timestamp, not daily extremes.
- `rain`, `snow`, and `wind.gust` may be absent.
- Use [Geocoding API](geocoding.md) for names or postal codes; built-in weather geocoding is deprecated.

## Related Documents

- [Geocoding API](geocoding.md)
- [Current weather](current-weather.md)
- [16-day daily forecast](forecast-16-day-daily.md)

## Source

- [OpenWeather 5 day weather forecast](https://openweathermap.org/api/forecast5), verified 2026-08-15.

