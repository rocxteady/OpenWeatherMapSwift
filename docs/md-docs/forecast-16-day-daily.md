# Daily Forecast for 16 Days

Get one forecast entry per day for up to 16 days.

## Quick Reference

| Item | Value |
| --- | --- |
| Method | `GET` |
| URL | `https://api.openweathermap.org/data/2.5/forecast/daily` |
| Authentication | Required `appid` query parameter |
| Preferred location input | `lat` and `lon` |
| Forecast interval | 1 day |
| Maximum count | 16 days |
| Default response | JSON |
| Other format | XML through `mode=xml` |
| Access | Paid subscription product; verify current plan eligibility |

## Request

| Parameter | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `lat` | number | yes | — | Latitude in decimal degrees. |
| `lon` | number | yes | — | Longitude in decimal degrees. |
| `appid` | string | yes | — | OpenWeather API key. |
| `cnt` | integer | no | product default | Number of days to return, from `1` through `16`. |
| `units` | string | no | `standard` | `standard`, `metric`, or `imperial`. |
| `lang` | string | no | — | Language code for translated location and weather descriptions. |
| `mode` | string | no | JSON | Set to `xml` for XML. |

```bash
curl --get 'https://api.openweathermap.org/data/2.5/forecast/daily' \
  --data-urlencode 'lat=41.0082' \
  --data-urlencode 'lon=28.9784' \
  --data-urlencode 'cnt=16' \
  --data-urlencode 'units=metric' \
  --data-urlencode "appid=$OPENWEATHER_API_KEY"
```

## JSON Response

Illustrative response with one daily item. Real responses contain up to `cnt` entries.

```json
{
  "city": {
    "id": 745044,
    "name": "Istanbul",
    "coord": { "lat": 41.0082, "lon": 28.9784 },
    "country": "TR",
    "population": 15460000,
    "timezone": 10800
  },
  "cod": "200",
  "message": 0,
  "cnt": 1,
  "list": [
    {
      "dt": 1786795200,
      "sunrise": 1786759200,
      "sunset": 1786810200,
      "temp": {
        "day": 24.1,
        "min": 19.3,
        "max": 25.6,
        "night": 20.2,
        "eve": 23.4,
        "morn": 19.7
      },
      "feels_like": { "day": 24.3, "night": 20.4, "eve": 23.6, "morn": 19.8 },
      "pressure": 1012,
      "humidity": 65,
      "weather": [
        { "id": 500, "main": "Rain", "description": "light rain", "icon": "10d" }
      ],
      "speed": 4.2,
      "deg": 220,
      "gust": 6.1,
      "clouds": 58,
      "rain": 1.7,
      "pop": 0.6
    }
  ]
}
```

## Field Reference

| JSON path | Type | Unit / values | Description |
| --- | --- | --- | --- |
| `city.id` | integer | city ID | Internal city identifier. |
| `city.name` | string | — | Location name. |
| `city.coord.lat` | number | degrees | Location latitude. |
| `city.coord.lon` | number | degrees | Location longitude. |
| `city.country` | string | ISO 3166 country code | Location country. |
| `city.population` | integer | people | Internal population parameter; may be absent. |
| `city.timezone` | integer | seconds from UTC | Location timezone offset. |
| `cod` | string | HTTP-like status | Internal response status value. |
| `message` | number | — | Internal parameter. |
| `cnt` | integer | days | Number of daily entries returned. |
| `list[]` | array | — | Daily forecast entries. |
| `list[].dt` | integer | Unix | Forecast date/time. Interpret with `city.timezone`. |
| `list[].sunrise` | integer | Unix, UTC | Sunrise time. |
| `list[].sunset` | integer | Unix, UTC | Sunset time. |
| `list[].temp.day` | number | temperature | Temperature at 12:00 local time. |
| `list[].temp.min` | number | temperature | Minimum daily temperature. |
| `list[].temp.max` | number | temperature | Maximum daily temperature. |
| `list[].temp.night` | number | temperature | Temperature at 00:00 local time. |
| `list[].temp.eve` | number | temperature | Temperature at 18:00 local time. |
| `list[].temp.morn` | number | temperature | Temperature at 06:00 local time. |
| `list[].feels_like.day` | number | temperature | Perceived temperature at 12:00 local time. |
| `list[].feels_like.night` | number | temperature | Perceived temperature at 00:00 local time. |
| `list[].feels_like.eve` | number | temperature | Perceived temperature at 18:00 local time. |
| `list[].feels_like.morn` | number | temperature | Perceived temperature at 06:00 local time. |
| `list[].pressure` | integer | hPa | Sea-level atmospheric pressure. |
| `list[].humidity` | integer | % | Relative humidity. |
| `list[].weather[]` | array | — | Weather conditions for the day. |
| `list[].weather[].id` | integer | condition code | Weather condition ID. |
| `list[].weather[].main` | string | — | Condition group. |
| `list[].weather[].description` | string | — | Localizable condition description. |
| `list[].weather[].icon` | string | icon ID | Weather icon identifier. |
| `list[].speed` | number | unit-system speed | Maximum wind speed for the day. |
| `list[].deg` | integer | degrees | Direction associated with maximum wind speed. |
| `list[].gust` | number | unit-system speed | Wind gust; may be absent. |
| `list[].clouds` | integer | % | Cloudiness. |
| `list[].rain` | number | mm/day | Daily rain volume; conditional. |
| `list[].snow` | number | mm/day | Daily snow volume; conditional. |
| `list[].pop` | number | `0` to `1` | Probability of precipitation. |

Temperature and wind-speed units follow `units`. Rain and snow remain millimeters.

## Behavior and Caveats

- Product availability depends on the OpenWeather subscription attached to the API key.
- `cnt` must be between `1` and `16`.
- `temp.min` and `temp.max` are daily extremes, unlike similarly named fields in current and 3-hour forecast responses.
- `rain`, `snow`, and `gust` may be absent.
- Use [Geocoding API](geocoding.md) for names or postal codes; built-in weather geocoding is deprecated.

## Related Documents

- [Geocoding API](geocoding.md)
- [Current weather](current-weather.md)
- [5-day / 3-hour forecast](forecast-5-day-3-hour.md)

## Sources

- [OpenWeather Daily Forecast 16 Days](https://openweathermap.org/api/forecast16), verified 2026-08-15.
- [OpenWeather pricing](https://openweathermap.org/price), checked 2026-08-15 for product access.
