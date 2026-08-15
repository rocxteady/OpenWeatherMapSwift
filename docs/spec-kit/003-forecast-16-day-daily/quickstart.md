# Quickstart Validation: 16-Day Daily Forecast

## Prerequisites

- Xcode with Swift 6.3 support.
- Repository dependencies resolved by Swift Package Manager.
- No OpenWeather API key or public network connection is required.

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

1. **Complete ordered forecast**
   - Stub a `200` response with `forecast-daily-full.json` containing 16 distinguishable entries.
   - Request the forecast and verify all 16 days, timestamps, and multiple conditions remain in
     source order.
   - Verify every documented city, top-level, daily, temperature, perceived-temperature, wind,
     cloud, precipitation, and probability field.

2. **Conditional weather and city values**
   - Stub `forecast-daily-optional.json` with missing population and dry, rainy, snowy, calm, and
     gusty days.
   - Verify population, rain, snow, and gust are independently present or `nil` exactly as
     supplied; no zero value is invented and no day is lost.

3. **Request preferences and day count**
   - Capture a request through the existing custom `URLProtocol` and configured Resting client.
   - Verify one `GET` request targets `/data/2.5/forecast/daily`; `lat`, `lon`, `appid`, `cnt`,
     `units`, and `lang` each occur once with the selected values; `mode` and the body are absent.
   - Repeat without optional arguments and verify `cnt`, `units`, and `lang` are absent.

4. **Input boundaries**
   - Verify coordinate pairs `(-90, -180)` and `(90, 180)` reach the stub.
   - Verify `maximumDayCount` values `1` and `16` reach the stub with matching `cnt` values.
   - Verify non-finite or out-of-range coordinates and counts such as `-1`, `0`, and `17` throw
     `RestingError.invalidRequest` with zero observed requests.

5. **Returned count independence**
   - Request 16 days while stubbing a shorter response.
   - Verify `entryCount` and `entries.count` reflect the response without client-side padding,
     truncation, or rejection.

6. **Failure preservation**
   - Stub a representative subscription rejection with response bytes, cancellation, a transport
     `URLError`, and malformed JSON.
   - Verify each remains distinguishable through the matching Resting error case and associated
     data.

7. **Credential exposure check**
   - Keep a sentinel API key in the test client.
   - Verify it appears only once in the captured `appid` query item and not in package-owned
     response values or descriptions exercised by the suite.
