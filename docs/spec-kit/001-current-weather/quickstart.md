# Quickstart Validation: Current Weather

## Prerequisites

- Xcode with Swift 6.3 support.
- The repository dependencies resolved by Swift Package Manager.
- No OpenWeather API key and no public network connection are required.

The expected API and model shapes are defined in [contracts/public-api.md](contracts/public-api.md)
and [data-model.md](data-model.md).

## Run the gates

From the repository root:

```bash
xcodebuildmcp swift-package build
xcodebuildmcp swift-package test
```

Expected outcome: both commands exit successfully, with no live-network access.

## Validation scenarios

1. **Full response decoding**
   - Stub a `200` response with `current-weather-full.json`.
   - Request current weather with metric units and a language.
   - Verify every documented value, both weather conditions in service order, and independent rain
     data are preserved.

2. **Minimal response decoding**
   - Stub a `200` response with `current-weather-minimal.json`.
   - Verify optional temperatures, pressure levels, gust, rain, snow, and station fields are `nil`
     while required values remain readable.

3. **Status wire variants**
   - Decode the numeric status in the full fixture and the string status in
     `current-weather-string-status.json`.
   - Verify the matching `CurrentWeatherStatus` cases and values.

4. **Request construction**
   - Capture the request with a custom `URLProtocol` installed through an ephemeral
     `URLSessionConfiguration` and `RestClientConfiguration`.
   - Verify one `GET` request targets `/data/2.5/weather`; `lat`, `lon`, `appid`, `units`, and `lang`
     each occur once; no `mode` or request body is present.
   - Repeat without optional preferences and verify `units` and `lang` are absent.

5. **Coordinate boundaries**
   - Verify `(-90, -180)` and `(90, 180)` reach the stub once each.
   - Verify latitudes immediately outside `-90...90` and longitudes immediately outside
     `-180...180` throw `RestingError.invalidRequest` with zero observed requests.

6. **Failure preservation**
   - Stub cancellation, a representative `URLError`, a rejected HTTP status with response bytes,
     and malformed JSON.
   - Verify callers receive the matching Resting error cases and retained associated data.

7. **Credential exposure check**
   - Keep a sentinel API key in the test client.
   - Verify it appears only once in the captured `appid` query item and not in any package-owned
     value or description exercised by the suite.
