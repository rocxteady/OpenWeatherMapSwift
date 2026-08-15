# Phase 0 Research: 5-Day / 3-Hour Forecast

## Public call shape

- **Decision**: Add
  `fiveDayForecast(latitude:longitude:maximumTimestampCount:units:language:) async throws -> FiveDayForecast`.
  Keep latitude and longitude required; default the remaining arguments to `nil`.
- **Rationale**: The base name distinguishes this endpoint from current weather and the later
  16-day daily forecast. `maximumTimestampCount` states exactly what the weakly typed `Int` limits,
  while defaults preserve a compact common call.
- **Alternatives considered**: `forecast(...)` becomes ambiguous when another forecast endpoint is
  added. `count` does not say whether it is requested or returned. An options/request type and
  overload family add surface without current value.

## Request construction and validation

- **Decision**: Execute a Resting `RequestDefinition.query` against
  `https://api.openweathermap.org/data/2.5/forecast`, always supplying `lat`, `lon`, and `appid`;
  add `cnt`, `units`, and `lang` only when their values are supplied. Reuse one private coordinate
  validator across both weather operations and reject `maximumTimestampCount <= 0` with
  `RestingError.invalidRequest` before execution.
- **Rationale**: This matches the authoritative request contract, keeps optional service defaults
  intact, and places shared boundary behavior once in the existing client. `URLQueryItem` and
  Resting already provide encoding and async execution.
- **Alternatives considered**: Direct `URLSession` violates governance. Manual URL strings risk
  escaping errors. Duplicating coordinate guards lets endpoint validation drift. A new public
  error type adds no distinct domain information.

## Shared and endpoint-specific response values

- **Decision**: Reuse `WeatherCoordinates`, `WeatherCondition`, `Wind`, and `Clouds`; introduce
  `FiveDayForecast`, `ThreeHourForecastEntry`, `ThreeHourForecastMeasurements`, `ThreeHourPrecipitation`,
  `ForecastPartOfDay`, and `ForecastCity` for differing wire shapes or semantics.
- **Rationale**: The reused objects have identical keys, types, units, and meaning. Forecast
  measurements add `temp_kf`; forecast precipitation uses `3h` rather than current weather's
  `1h`; forecast system data contains only `pod`; city metadata is a separate shape.
- **Alternatives considered**: Forcing both endpoints through common measurement, precipitation,
  system, or top-level models would weaken required fields or create misleading names. Duplicating
  the four identical shared types adds code without preserving any endpoint distinction.

## Wire representation and ordering

- **Decision**: Decode numeric measurements as `Double` or `Int` according to the readable API
  contract, keep Unix timestamps as `Int`, keep `dt_txt` as `String`, and model only documented
  conditional values—minimum/maximum temperature, gust, rain, and snow—as optional. Preserve
  `list` and `weather` arrays without sorting, filtering, aggregation, or invented defaults.
- **Rationale**: Direct `Decodable` mapping provides complete contract fidelity and retains the
  upstream representation. The city timezone offset stays available separately for callers that
  need local presentation.
- **Alternatives considered**: Converting timestamps to `Date`, applying timezone arithmetic,
  daily aggregation, measurement wrappers, or default zero precipitation introduces behavior the
  feature does not request.

## Test integration and failure behavior

- **Decision**: Extend the existing Swift Testing suite and custom `URLProtocol` test seam. Use a
  40-entry full fixture plus a compact fixture mixing missing/present rain, snow, and gust data.
  Inspect required and optional query items, verify valid boundaries and invalid coordinates/counts,
  and exercise representative cancellation, transport, status-code, and decoding failures without
  catching or translating Resting errors in production code.
- **Rationale**: Existing infrastructure already gives deterministic request capture and failure
  injection with no credential or public network. Keeping forecast tests in the same serialized
  suite avoids races in the shared stub. Direct error propagation retains Resting's cancellation
  and response-byte diagnostics.
- **Alternatives considered**: Live API tests are nondeterministic and require a secret. A second
  test transport or mock protocol duplicates an installed seam. Endpoint-specific error wrapping
  would discard or obscure useful associated data.

## Source basis

- `docs/md-docs/forecast-5-day-3-hour.md` is the authoritative endpoint contract.
- `Sources/OpenWeatherMapSwift/OpenWeatherClient.swift` establishes the reusable Resting request
  path, validation behavior, unit preference, and credential ownership.
- `Sources/OpenWeatherMapSwift/CurrentWeather.swift` establishes the shared wire-shape values.
- `Tests/OpenWeatherMapSwiftTests/CurrentWeatherTests.swift` establishes the deterministic
  Foundation/Resting test seam.

All technical-context questions are resolved.
