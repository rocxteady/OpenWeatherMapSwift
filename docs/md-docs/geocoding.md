# Geocoding API

Convert place names or postal codes to coordinates, or coordinates to nearby place names.

## Quick Reference

| Operation | Method | URL | Result |
| --- | --- | --- | --- |
| Direct geocoding | `GET` | `https://api.openweathermap.org/geo/1.0/direct` | Matching locations |
| ZIP geocoding | `GET` | `https://api.openweathermap.org/geo/1.0/zip` | One postal-code area |
| Reverse geocoding | `GET` | `https://api.openweathermap.org/geo/1.0/reverse` | Nearby locations |

All operations require the `appid` query parameter and return JSON.

## Direct Geocoding

Use a place name to retrieve coordinates. Add country and US state codes to reduce ambiguity.

| Parameter | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `q` | string | yes | — | `city`, `city,country`, or `city,state,country`; state applies to US locations. Use ISO 3166 country codes. |
| `limit` | integer | no | product default | Maximum matches, up to `5`. |
| `appid` | string | yes | — | OpenWeather API key. |

```bash
curl --get 'https://api.openweathermap.org/geo/1.0/direct' \
  --data-urlencode 'q=Istanbul,TR' \
  --data-urlencode 'limit=5' \
  --data-urlencode "appid=$OPENWEATHER_API_KEY"
```

```json
[
  {
    "name": "Istanbul",
    "local_names": { "en": "Istanbul", "tr": "İstanbul" },
    "lat": 41.0082,
    "lon": 28.9784,
    "country": "TR",
    "state": "Istanbul"
  }
]
```

## ZIP Geocoding

Use a postal code and country code to retrieve its centroid.

| Parameter | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `zip` | string | yes | — | `postal-code,country-code`; use an ISO 3166 country code. |
| `appid` | string | yes | — | OpenWeather API key. |

```bash
curl --get 'https://api.openweathermap.org/geo/1.0/zip' \
  --data-urlencode 'zip=34000,TR' \
  --data-urlencode "appid=$OPENWEATHER_API_KEY"
```

```json
{
  "zip": "34000",
  "name": "Istanbul",
  "lat": 41.0082,
  "lon": 28.9784,
  "country": "TR"
}
```

## Reverse Geocoding

Use coordinates to retrieve nearby location names.

| Parameter | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `lat` | number | yes | — | Latitude in decimal degrees. |
| `lon` | number | yes | — | Longitude in decimal degrees. |
| `limit` | integer | no | product default | Maximum number of nearby names. |
| `appid` | string | yes | — | OpenWeather API key. |

```bash
curl --get 'https://api.openweathermap.org/geo/1.0/reverse' \
  --data-urlencode 'lat=41.0082' \
  --data-urlencode 'lon=28.9784' \
  --data-urlencode 'limit=5' \
  --data-urlencode "appid=$OPENWEATHER_API_KEY"
```

```json
[
  {
    "name": "Istanbul",
    "local_names": { "en": "Istanbul", "tr": "İstanbul" },
    "lat": 41.0082,
    "lon": 28.9784,
    "country": "TR",
    "state": "Istanbul"
  }
]
```

## Field Reference

### Direct and Reverse Results

| JSON path | Type | Required | Description |
| --- | --- | --- | --- |
| `[]` | array | yes | Matching or nearby locations. An empty array means no result. |
| `[].name` | string | yes | Found location name. |
| `[].local_names` | object | no | Names keyed by language code; keys vary by location. |
| `[].local_names.<language-code>` | string | no | Localized location name. |
| `[].local_names.ascii` | string | no | Internal field. |
| `[].local_names.feature_name` | string | no | Internal field. |
| `[].lat` | number | yes | Location latitude. |
| `[].lon` | number | yes | Location longitude. |
| `[].country` | string | yes | ISO 3166 country code. |
| `[].state` | string | no | State or first-level administrative area where available. |

### ZIP Result

| JSON path | Type | Required | Description |
| --- | --- | --- | --- |
| `zip` | string | yes | Requested postal code. |
| `name` | string | yes | Found area name. |
| `lat` | number | yes | Postal-code centroid latitude. |
| `lon` | number | yes | Postal-code centroid longitude. |
| `country` | string | yes | ISO 3166 country code. |

## Behavior and Caveats

- Direct and reverse endpoints return arrays because names and coordinates can map to multiple places.
- `local_names` and `state` vary by country and location; consumers must treat them as optional.
- Use country codes and US state codes when known to reduce ambiguous direct-geocoding results.
- Feed returned `lat` and `lon` into weather endpoints instead of using deprecated built-in weather geocoding.

## Related Documents

- [Current weather](current-weather.md)
- [5-day / 3-hour forecast](forecast-5-day-3-hour.md)
- [16-day daily forecast](forecast-16-day-daily.md)

## Source

- [OpenWeather Geocoding API](https://openweathermap.org/api/geocoding-api), verified 2026-08-15.

