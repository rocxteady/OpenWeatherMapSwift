# Quickstart Validation: Geocoding

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

1. **Direct place results and request**
   - Stub `geocoding-direct.json` with multiple distinguishable locations, arbitrary localized-name
     keys, and both present and absent state values.
   - Verify every result and localized-name entry remains in source order.
   - Verify one `GET` targets `/geo/1.0/direct`; `q`, `limit`, and `appid` occur exactly once and
     the request has no body.

2. **Postal result and request**
   - Stub `geocoding-zip.json` and verify postal code, name, latitude, longitude, and country.
   - Verify one `GET` targets `/geo/1.0/zip` with exactly one `zip=34000,TR` and one `appid` query
     item and no body.

3. **Reverse results and request**
   - Stub `geocoding-reverse.json` with ordered nearby locations and optional metadata.
   - Verify one `GET` targets `/geo/1.0/reverse`; `lat`, `lon`, `limit`, and `appid` occur exactly
     once and the response order is unchanged.

4. **Service defaults and empty results**
   - Omit the optional direct and reverse limits and verify `limit` is absent.
   - Stub `geocoding-empty.json` for each array endpoint and verify successful empty collections.

5. **Input boundaries and pre-network rejection**
   - Verify direct limits `1` and `5`, reverse limit `1`, and coordinate pairs `(-90, -180)` and
     `(90, 180)` reach the stub.
   - Verify direct limits outside `1...5`, nonpositive reverse limits, invalid coordinates, and
     empty or whitespace-only place, postal, and country values throw
     `RestingError.invalidRequest` with zero observed requests.
   - Verify nonblank input is transmitted unchanged and country codes receive no semantic check.

6. **Failure preservation**
   - Exercise representative rejected-status response bytes, cancellation, transport failure,
     and malformed JSON across the three operations.
   - Verify each remains distinguishable through the matching Resting error case and associated
     data.

7. **Credential exposure check**
   - Use a sentinel API key and verify it appears once in each captured `appid` query and nowhere
     in package-owned response values or descriptions exercised by the suite.
