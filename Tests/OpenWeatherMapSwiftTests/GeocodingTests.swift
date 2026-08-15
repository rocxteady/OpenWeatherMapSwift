import Foundation
import Resting
import Testing
@testable import OpenWeatherMapSwift

extension OpenWeatherClientTests {
    @Test func directGeocodingDecodesOrderedResultsAndRequest() async throws {
        StubURLProtocol.respond(with: try fixture("geocoding-direct.json"))
        let client = makeClient(apiKey: "direct-key")

        let locations = try await client.geocode(
            place: "  Istanbul,TR\n",
            maximumResultCount: 5
        )

        #expect(locations.map(\.latitude) == [41.0082, 41.105])
        #expect(locations.map(\.longitude) == [28.9784, 29.01])
        #expect(locations.map(\.country) == ["TR", "TR"])
        #expect(locations[0].name == "Istanbul")
        #expect(locations[0].localizedNames == [
            "tr": "İstanbul",
            "ascii": "Istanbul",
            "x-test": "First",
        ])
        #expect(locations[0].state == "Istanbul")
        #expect(locations[1].localizedNames == nil)
        #expect(locations[1].state == nil)

        let request = try #require(StubURLProtocol.requests.first)
        #expect(StubURLProtocol.requests.count == 1)
        #expect(request.httpMethod == "GET")
        #expect(request.httpBody == nil)
        #expect(request.url?.path == "/geo/1.0/direct")
        #expect(queryValues(in: request, named: "q") == ["  Istanbul,TR\n"])
        #expect(queryValues(in: request, named: "limit") == ["5"])
        #expect(queryValues(in: request, named: "appid") == ["direct-key"])
    }

    @Test func directGeocodingAllowsEmptyResultsAndOmittedLimit() async throws {
        StubURLProtocol.respond(with: try fixture("geocoding-empty.json"))

        let locations = try await makeClient().geocode(place: "Nowhere")

        #expect(locations.isEmpty)
        let request = try #require(StubURLProtocol.requests.first)
        #expect(queryValues(in: request, named: "limit").isEmpty)
    }

    @Test(arguments: [1, 5])
    func directGeocodingAcceptsLimitBoundaries(_ limit: Int) async throws {
        StubURLProtocol.respond(with: try fixture("geocoding-empty.json"))

        _ = try await makeClient().geocode(place: "Istanbul", maximumResultCount: limit)

        #expect(StubURLProtocol.requests.count == 1)
        #expect(queryValues(in: StubURLProtocol.requests[0], named: "limit") == [String(limit)])
    }

    @Test(arguments: [0, 6])
    func directGeocodingRejectsInvalidLimits(_ limit: Int) async {
        await expectInvalidGeocoding {
            try await makeClient().geocode(place: "Istanbul", maximumResultCount: limit)
        }
    }

    @Test(arguments: ["", "   ", "\n\t"])
    func directGeocodingRejectsBlankPlaces(_ place: String) async {
        await expectInvalidGeocoding {
            try await makeClient().geocode(place: place)
        }
    }

    @Test func directGeocodingPreservesCancellation() async {
        StubURLProtocol.fail(with: URLError(.cancelled))

        do {
            _ = try await makeClient().geocode(place: "Istanbul")
            Issue.record("Expected cancellation")
        } catch let error as RestingError {
            guard case .cancelled = error else {
                Issue.record("Expected cancelled, got \(error)")
                return
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func directGeocodingDoesNotExposeCredential() async throws {
        let apiKey = "direct-credential-sentinel"
        StubURLProtocol.respond(with: try fixture("geocoding-direct.json"))
        let client = makeClient(apiKey: apiKey)

        let locations = try await client.geocode(place: "Istanbul")

        let request = try #require(StubURLProtocol.requests.first)
        #expect(queryValues(in: request, named: "appid") == [apiKey])
        #expect(!String(describing: client).contains(apiKey))
        #expect(!String(describing: locations).contains(apiKey))
    }

    @Test func zipGeocodingDecodesResultAndExactRequest() async throws {
        StubURLProtocol.respond(with: try fixture("geocoding-zip.json"))
        let client = makeClient(apiKey: "zip-key")

        let location = try await client.geocode(
            postalCode: " 34000 ",
            countryCode: "ZZ"
        )

        #expect(location.postalCode == "34000")
        #expect(location.name == "Istanbul")
        #expect(location.latitude == 41.0082)
        #expect(location.longitude == 28.9784)
        #expect(location.country == "TR")

        let request = try #require(StubURLProtocol.requests.first)
        #expect(StubURLProtocol.requests.count == 1)
        #expect(request.httpMethod == "GET")
        #expect(request.httpBody == nil)
        #expect(request.url?.path == "/geo/1.0/zip")
        #expect(queryValues(in: request, named: "zip") == [" 34000 ,ZZ"])
        #expect(queryValues(in: request, named: "appid") == ["zip-key"])
    }

    @Test(arguments: [
        (postalCode: "", countryCode: "TR"),
        (postalCode: "34000", countryCode: ""),
        (postalCode: " \n", countryCode: "TR"),
        (postalCode: "34000", countryCode: "\t"),
    ])
    func zipGeocodingRejectsBlankComponents(postalCode: String, countryCode: String) async {
        await expectInvalidGeocoding {
            try await makeClient().geocode(postalCode: postalCode, countryCode: countryCode)
        }
    }

    @Test func zipGeocodingRetainsRejectedStatusBytes() async {
        let bytes = Data("unknown postal code".utf8)
        StubURLProtocol.respond(statusCode: 404, with: bytes)

        do {
            _ = try await makeClient().geocode(postalCode: "34000", countryCode: "TR")
            Issue.record("Expected rejected status")
        } catch let error as RestingError {
            guard case .statusCode(404, let data) = error else {
                Issue.record("Expected statusCode, got \(error)")
                return
            }
            #expect(data == bytes)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func zipGeocodingDoesNotExposeCredential() async throws {
        let apiKey = "zip-credential-sentinel"
        StubURLProtocol.respond(with: try fixture("geocoding-zip.json"))
        let client = makeClient(apiKey: apiKey)

        let location = try await client.geocode(postalCode: "34000", countryCode: "TR")

        let request = try #require(StubURLProtocol.requests.first)
        #expect(queryValues(in: request, named: "appid") == [apiKey])
        #expect(!String(describing: client).contains(apiKey))
        #expect(!String(describing: location).contains(apiKey))
    }

    @Test func reverseGeocodingDecodesOrderedResultsAndRequest() async throws {
        StubURLProtocol.respond(with: try fixture("geocoding-reverse.json"))
        let client = makeClient(apiKey: "reverse-key")

        let locations = try await client.reverseGeocode(
            latitude: 41.0082,
            longitude: 28.9784,
            maximumResultCount: 2
        )

        #expect(locations.map(\.name) == ["Sultanahmet", "Fatih"])
        #expect(locations[0].localizedNames?["feature_name"] == "Historic Peninsula")
        #expect(locations[0].state == "Istanbul")
        #expect(locations[1].localizedNames == nil)
        #expect(locations[1].state == nil)

        let request = try #require(StubURLProtocol.requests.first)
        #expect(StubURLProtocol.requests.count == 1)
        #expect(request.httpMethod == "GET")
        #expect(request.httpBody == nil)
        #expect(request.url?.path == "/geo/1.0/reverse")
        #expect(queryValues(in: request, named: "lat") == ["41.0082"])
        #expect(queryValues(in: request, named: "lon") == ["28.9784"])
        #expect(queryValues(in: request, named: "limit") == ["2"])
        #expect(queryValues(in: request, named: "appid") == ["reverse-key"])
    }

    @Test func reverseGeocodingAllowsEmptyResultsAndOmittedLimit() async throws {
        StubURLProtocol.respond(with: try fixture("geocoding-empty.json"))

        let locations = try await makeClient().reverseGeocode(latitude: 41, longitude: 29)

        #expect(locations.isEmpty)
        let request = try #require(StubURLProtocol.requests.first)
        #expect(queryValues(in: request, named: "limit").isEmpty)
    }

    @Test func reverseGeocodingAcceptsBoundariesAndPositiveLimit() async throws {
        StubURLProtocol.respond(with: try fixture("geocoding-empty.json"))
        let client = makeClient()

        _ = try await client.reverseGeocode(latitude: -90, longitude: -180, maximumResultCount: 1)
        _ = try await client.reverseGeocode(latitude: 90, longitude: 180, maximumResultCount: 500)

        #expect(StubURLProtocol.requests.count == 2)
        #expect(queryValues(in: StubURLProtocol.requests[0], named: "limit") == ["1"])
        #expect(queryValues(in: StubURLProtocol.requests[1], named: "limit") == ["500"])
    }

    @Test(arguments: [0, -1])
    func reverseGeocodingRejectsNonpositiveLimits(_ limit: Int) async {
        await expectInvalidGeocoding {
            try await makeClient().reverseGeocode(
                latitude: 41,
                longitude: 29,
                maximumResultCount: limit
            )
        }
    }

    @Test(arguments: [
        (latitude: -90.0001, longitude: 0.0),
        (latitude: 90.0001, longitude: 0.0),
        (latitude: 0.0, longitude: -180.0001),
        (latitude: 0.0, longitude: 180.0001),
        (latitude: Double.nan, longitude: 0.0),
        (latitude: 0.0, longitude: Double.infinity),
    ])
    func reverseGeocodingRejectsInvalidCoordinates(latitude: Double, longitude: Double) async {
        await expectInvalidGeocoding {
            try await makeClient().reverseGeocode(latitude: latitude, longitude: longitude)
        }
    }

    @Test func reverseGeocodingPreservesTransportFailure() async {
        StubURLProtocol.fail(with: URLError(.notConnectedToInternet))

        do {
            _ = try await makeClient().reverseGeocode(latitude: 41, longitude: 29)
            Issue.record("Expected transport failure")
        } catch let error as RestingError {
            guard case .transport(let underlying) = error else {
                Issue.record("Expected transport, got \(error)")
                return
            }
            #expect(underlying.code == .notConnectedToInternet)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func reverseGeocodingRetainsMalformedJSONBytes() async {
        let bytes = Data("{".utf8)
        StubURLProtocol.respond(with: bytes)

        do {
            _ = try await makeClient().reverseGeocode(latitude: 41, longitude: 29)
            Issue.record("Expected decoding failure")
        } catch let error as RestingError {
            guard case .decoding(_, let data) = error else {
                Issue.record("Expected decoding error, got \(error)")
                return
            }
            #expect(data == bytes)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func reverseGeocodingDoesNotExposeCredential() async throws {
        let apiKey = "reverse-credential-sentinel"
        StubURLProtocol.respond(with: try fixture("geocoding-reverse.json"))
        let client = makeClient(apiKey: apiKey)

        let locations = try await client.reverseGeocode(latitude: 41, longitude: 29)

        let request = try #require(StubURLProtocol.requests.first)
        #expect(queryValues(in: request, named: "appid") == [apiKey])
        #expect(!String(describing: client).contains(apiKey))
        #expect(!String(describing: locations).contains(apiKey))
    }

    private func expectInvalidGeocoding<T>(
        _ operation: () async throws -> T
    ) async {
        do {
            _ = try await operation()
            Issue.record("Expected invalid request")
        } catch let error as RestingError {
            guard case .invalidRequest = error else {
                Issue.record("Expected invalidRequest, got \(error)")
                return
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
        #expect(StubURLProtocol.requests.isEmpty)
    }
}
