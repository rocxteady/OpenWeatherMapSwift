# Phase 0 Research: 16-Day Daily Forecast

## Public call shape

- **Decision**: Add
  `dailyForecast(latitude:longitude:maximumDayCount:units:language:) async throws -> DailyForecast`.
  Keep coordinates required and default the remaining arguments to `nil`.
- **Rationale**: The base name distinguishes daily results from the existing three-hour forecast.
  `maximumDayCount` matches the existing `maximumTimestampCount` convention and acknowledges that
  the service may return fewer entries without introducing a request/options type.
- **Alternatives considered**: An overloaded `forecast(...)` is ambiguous. A request object and
  overload family add surface without current value. A custom bounded count type is unnecessary
  because the client must already validate coordinates at the network boundary.

## Request construction and validation

- **Decision**: Execute a Resting `RequestDefinition.query` against
  `https://api.openweathermap.org/data/2.5/forecast/daily`, always supplying `lat`, `lon`, and
  `appid`; add `cnt`, `units`, and `lang` only when supplied. Reuse the private coordinate
  validator and reject a supplied day count outside `1...16` with
  `RestingError.invalidRequest` before execution.
- **Rationale**: This matches the authoritative readable contract, preserves service defaults,
  and keeps common validation in one place. `URLQueryItem` and Resting already provide query
  encoding and async execution.
- **Alternatives considered**: Direct `URLSession` violates governance. Manual URL strings risk
  escaping errors. Duplicated coordinate guards can drift. A new public error type adds no domain
  information beyond Resting's existing invalid-request case.

## Shared and endpoint-specific response values

- **Decision**: Reuse `WeatherCoordinates` and `WeatherCondition`. Introduce `DailyForecast`,
  `DailyForecastEntry`, `DailyTemperature`, `DailyPerceivedTemperature`, and
  `DailyForecastCity`. Keep the daily entry's flattened wind, cloud, rain, and snow wire values as
  directly named properties rather than forcing them through existing nested weather types.
- **Rationale**: Coordinates and conditions have identical keys, types, and meanings. The daily
  city lacks forecast-city sun times and has optional population. Daily temperatures represent
  local day parts and extremes, while daily wind is the maximum-speed tuple flattened into each
  entry. Direct scalar properties require no custom decoder or one-use wrapper.
- **Alternatives considered**: Reusing `ForecastCity`, `Wind`, `Clouds`, current measurements, or
  precipitation types would misstate required fields, nesting, periods, or meaning. New wrappers
  for scalar wind/cloud/precipitation fields add code without strengthening the contract.

## Wire representation, time, and ordering

- **Decision**: Decode documented numeric measurements as `Double` or `Int`, keep Unix times as
  `Int`, and model only `city.population`, daily gust, rain, and snow as optional. Preserve `list`
  and `weather` arrays directly, with the city timezone offset available for caller-side date
  interpretation.
- **Rationale**: Direct `Decodable` mapping preserves the documented JSON and upstream ordering.
  It avoids silently inventing zeros or applying presentation policy in a networking package.
- **Alternatives considered**: Converting timestamps to `Date`, sorting, padding to the requested
  count, aggregating the three-hour endpoint, or adding measurement wrappers would introduce
  behavior outside the feature.

## Product access and failure behavior

- **Decision**: Send requests without a subscription preflight and allow Resting errors to pass
  through untranslated, including cancellation, transport, rejected-status response bytes, and
  decoding diagnostics.
- **Rationale**: Eligibility is controlled by OpenWeather and cannot be inferred locally. The
  existing error model already distinguishes the required failures and retains useful evidence.
- **Alternatives considered**: A preliminary access request adds latency and cannot guarantee the
  following call. Endpoint-specific wrapping risks hiding Resting error cases or response bytes.

## Test integration

- **Decision**: Extend the existing serialized Swift Testing suite and custom `URLProtocol` seam.
  Use a distinguishable 16-entry full fixture and a compact mixed-weather fixture. Inspect query
  construction, count and coordinate boundaries, returned-count independence, optional values,
  ordering, subscription rejection, cancellation, transport, decoding, and credential exposure.
- **Rationale**: Existing infrastructure provides deterministic capture and failure injection
  without a credential or public network. One full and one optional fixture cover the response
  contract without a matrix of redundant files.
- **Alternatives considered**: Live API tests are nondeterministic and secret-dependent. A new
  test transport duplicates the configured Resting/Foundation seam. One fixture per weather
  combination increases maintenance without increasing meaningful coverage.

## Source basis

- `docs/md-docs/forecast-16-day-daily.md` is the authoritative endpoint contract.
- `Sources/OpenWeatherMapSwift/OpenWeatherClient.swift` establishes the reusable Resting request,
  validation, units, and credential-ownership patterns.
- `Sources/OpenWeatherMapSwift/CurrentWeather.swift` establishes the identical shared response
  values.
- `Tests/OpenWeatherMapSwiftTests/CurrentWeatherTests.swift` establishes the deterministic test
  seam, and `FiveDayForecastTests.swift` establishes forecast failure and ordering coverage.

All technical-context questions are resolved.
