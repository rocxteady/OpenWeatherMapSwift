# Quickstart Validation: 5-Day / 3-Hour Forecast

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

1. **Complete ordered timeline**
   - Stub a `200` response with `forecast-5-day-full.json` containing 40 distinguishable entries.
   - Request the forecast and verify all 40 entries, their timestamps, and multiple conditions
     remain in source order.
   - Verify every documented top-level, entry, measurement, and city field.

2. **Conditional phenomena**
   - Stub `forecast-5-day-optional.json` with dry, rainy, snowy, calm, and gusty entries.
   - Verify rain, snow, and gust are independently present or `nil` exactly as supplied; no zero
     precipitation value is invented.

3. **Request preferences and count**
   - Capture a request through the existing custom `URLProtocol` and an ephemeral
     `URLSessionConfiguration` passed to `RestClientConfiguration`.
   - Verify one `GET` request targets `/data/2.5/forecast`; `lat`, `lon`, `appid`, `cnt`, `units`,
     and `lang` each occur once with the selected values; `mode` and the body are absent.
   - Repeat without optional arguments and verify `cnt`, `units`, and `lang` are absent.

4. **Input boundaries**
   - Verify `(-90, -180)` and `(90, 180)` reach the stub.
   - Verify coordinates immediately outside their closed ranges, non-finite latitude, and counts
     of zero and below throw `RestingError.invalidRequest` with zero observed requests.
   - Verify a count of one reaches the stub with `cnt=1`.

5. **Returned count independence**
   - Request a larger maximum than a short fixture contains.
   - Verify the decoded `entryCount` and `entries.count` reflect the response without client-side
     padding, truncation, or rejection.

6. **Failure preservation**
   - Stub cancellation, a representative `URLError`, a rejected HTTP status with response bytes,
     and malformed JSON.
   - Verify callers receive the matching Resting error cases and retained associated data.

7. **Credential exposure check**
   - Keep a sentinel API key in the test client.
   - Verify it appears only once in the captured `appid` query item and not in any package-owned
     value or description exercised by the suite.
