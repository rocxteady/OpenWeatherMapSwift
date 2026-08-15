import Foundation
#if canImport(FoundationNetworking)
@preconcurrency import FoundationNetworking
#endif
import Resting
import Testing
@testable import OpenWeatherMapSwift

@Suite(.serialized)
struct CurrentWeatherTests {
    init() {
        StubURLProtocol.reset()
    }

    @Test func fullResponseAndRequestPreferences() async throws {
        let data = try fixture("current-weather-full.json")
        StubURLProtocol.respond(with: data)

        let client = makeClient(apiKey: "sentinel-key")
        let weather = try await client.currentWeather(
            latitude: 41.0082,
            longitude: 28.9784,
            units: .metric,
            language: "tr"
        )

        #expect(weather.coordinates.longitude == 28.9784)
        #expect(weather.coordinates.latitude == 41.0082)
        #expect(weather.conditions.map(\.id) == [500, 701])
        #expect(weather.conditions.map(\.group) == ["Rain", "Mist"])
        #expect(weather.conditions.map(\.description) == ["light rain", "mist"])
        #expect(weather.conditions.map(\.icon) == ["10d", "50d"])
        #expect(weather.base == "stations")
        #expect(weather.measurements.temperature == 18.4)
        #expect(weather.measurements.feelsLike == 18.1)
        #expect(weather.measurements.minimumTemperature == 17.8)
        #expect(weather.measurements.maximumTemperature == 19.2)
        #expect(weather.measurements.pressure == 1014)
        #expect(weather.measurements.humidity == 71)
        #expect(weather.measurements.seaLevelPressure == 1014)
        #expect(weather.measurements.groundLevelPressure == 1008)
        #expect(weather.visibility == 10_000)
        #expect(weather.wind.speed == 3.2)
        #expect(weather.wind.direction == 230)
        #expect(weather.wind.gust == 5.1)
        #expect(weather.clouds.coverage == 75)
        #expect(weather.rain?.lastHour == 0.4)
        #expect(weather.snow?.lastHour == 0.2)
        #expect(weather.calculationTime == 1_786_795_200)
        #expect(weather.system.type == 1)
        #expect(weather.system.id == 6970)
        #expect(weather.system.message == 0.01)
        #expect(weather.system.country == "TR")
        #expect(weather.system.sunrise == 1_786_759_200)
        #expect(weather.system.sunset == 1_786_810_200)
        #expect(weather.timezoneOffset == 10_800)
        #expect(weather.locationID == 745_044)
        #expect(weather.locationName == "Istanbul")
        guard case .number(200) = weather.status else {
            Issue.record("Expected numeric status")
            return
        }

        let request = try #require(StubURLProtocol.requests.first)
        #expect(request.httpMethod == "GET")
        #expect(request.httpBody == nil)
        #expect(request.url?.path == "/data/2.5/weather")
        #expect(queryValues(in: request, named: "lat") == ["41.0082"])
        #expect(queryValues(in: request, named: "lon") == ["28.9784"])
        #expect(queryValues(in: request, named: "appid") == ["sentinel-key"])
        #expect(queryValues(in: request, named: "units") == ["metric"])
        #expect(queryValues(in: request, named: "lang") == ["tr"])
        #expect(queryValues(in: request, named: "mode").isEmpty)
    }

    @Test func omitsUnsuppliedPreferences() async throws {
        StubURLProtocol.respond(with: try fixture("current-weather-full.json"))

        _ = try await makeClient().currentWeather(latitude: 41, longitude: 29)

        let request = try #require(StubURLProtocol.requests.first)
        #expect(queryValues(in: request, named: "units").isEmpty)
        #expect(queryValues(in: request, named: "lang").isEmpty)
    }

    @Test func minimalResponsePreservesMissingValues() async throws {
        StubURLProtocol.respond(with: try fixture("current-weather-minimal.json"))

        let weather = try await makeClient().currentWeather(latitude: -90, longitude: -180)

        #expect(weather.locationName == "Minimal")
        #expect(weather.conditions.isEmpty)
        #expect(weather.measurements.minimumTemperature == nil)
        #expect(weather.measurements.maximumTemperature == nil)
        #expect(weather.measurements.seaLevelPressure == nil)
        #expect(weather.measurements.groundLevelPressure == nil)
        #expect(weather.wind.gust == nil)
        #expect(weather.rain == nil)
        #expect(weather.snow == nil)
        #expect(weather.system.type == nil)
        #expect(weather.system.id == nil)
        #expect(weather.system.message == nil)
    }

    @Test func statusPreservesNumberAndStringWireTypes() async throws {
        let numeric = try JSONDecoder().decode(CurrentWeather.self, from: fixture("current-weather-full.json"))
        let text = try JSONDecoder().decode(CurrentWeather.self, from: fixture("current-weather-string-status.json"))

        guard case .number(200) = numeric.status else {
            Issue.record("Expected numeric status")
            return
        }
        guard case .text("200") = text.status else {
            Issue.record("Expected text status")
            return
        }
    }

    @Test func coordinateBoundariesAreAccepted() async throws {
        StubURLProtocol.respond(with: try fixture("current-weather-minimal.json"))
        let client = makeClient()

        _ = try await client.currentWeather(latitude: -90, longitude: -180)
        _ = try await client.currentWeather(latitude: 90, longitude: 180)

        #expect(StubURLProtocol.requests.count == 2)
    }

    @Test(arguments: [
        (latitude: -90.0001, longitude: 0.0),
        (latitude: 90.0001, longitude: 0.0),
        (latitude: 0.0, longitude: -180.0001),
        (latitude: 0.0, longitude: 180.0001),
        (latitude: Double.nan, longitude: 0.0),
    ])
    func invalidCoordinatesFailBeforeNetworking(latitude: Double, longitude: Double) async {
        do {
            _ = try await makeClient().currentWeather(latitude: latitude, longitude: longitude)
            Issue.record("Expected invalid coordinates to fail")
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

    @Test func cancellationIsPreserved() async {
        StubURLProtocol.fail(with: URLError(.cancelled))
        await expectRestingError(.cancelled)
    }

    @Test func transportFailureIsPreserved() async {
        StubURLProtocol.fail(with: URLError(.notConnectedToInternet))
        await expectRestingError(.transport(.notConnectedToInternet))
    }

    @Test func rejectedStatusRetainsResponseBytes() async {
        let bytes = Data("rate limited".utf8)
        StubURLProtocol.respond(statusCode: 429, with: bytes)

        do {
            _ = try await makeClient().currentWeather(latitude: 0, longitude: 0)
            Issue.record("Expected status failure")
        } catch let error as RestingError {
            guard case .statusCode(429, let data) = error else {
                Issue.record("Expected statusCode, got \(error)")
                return
            }
            #expect(data == bytes)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func malformedJSONRetainsResponseBytes() async {
        let bytes = Data("{".utf8)
        StubURLProtocol.respond(with: bytes)

        do {
            _ = try await makeClient().currentWeather(latitude: 0, longitude: 0)
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

    @Test func credentialAppearsOnlyInTheRequestQuery() async throws {
        let apiKey = "credential-sentinel"
        StubURLProtocol.respond(with: try fixture("current-weather-full.json"))
        let client = makeClient(apiKey: apiKey)

        let weather = try await client.currentWeather(latitude: 41, longitude: 29)

        let request = try #require(StubURLProtocol.requests.first)
        #expect(queryValues(in: request, named: "appid") == [apiKey])
        #expect(!String(describing: client).contains(apiKey))
        #expect(!String(describing: weather).contains(apiKey))
    }

    private enum ExpectedError {
        case cancelled
        case transport(URLError.Code)
    }

    private func expectRestingError(_ expected: ExpectedError) async {
        do {
            _ = try await makeClient().currentWeather(latitude: 0, longitude: 0)
            Issue.record("Expected request to fail")
        } catch let error as RestingError {
            switch (expected, error) {
            case (.cancelled, .cancelled):
                break
            case (.transport(let expectedCode), .transport(let underlying)):
                #expect(underlying.code == expectedCode)
            default:
                Issue.record("Unexpected Resting error: \(error)")
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    func makeClient(apiKey: String = "test-key") -> OpenWeatherClient {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [StubURLProtocol.self]
        return OpenWeatherClient(
            apiKey: apiKey,
            configuration: RestClientConfiguration(sessionConfiguration: sessionConfiguration)
        )
    }

    func fixture(_ name: String) throws -> Data {
        let url = Bundle.module.url(forResource: name, withExtension: nil, subdirectory: "Fixtures")!
        return try Data(contentsOf: url)
    }

    func queryValues(in request: URLRequest, named name: String) -> [String] {
        URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems?
            .filter { $0.name == name }
            .compactMap(\.value) ?? []
    }
}

final class StubURLProtocol: URLProtocol {
    struct Stub {
        let response: URLResponse?
        let data: Data
        let error: Error?
    }

    private static let lock = NSLock()
    nonisolated(unsafe) private static var handler: ((URLRequest) throws -> Stub)?
    nonisolated(unsafe) private(set) static var requests: [URLRequest] = []

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        do {
            Self.lock.lock()
            Self.requests.append(request)
            let handler = Self.handler
            Self.lock.unlock()
            let stub = try handler?(request) ?? .init(response: nil, data: Data(), error: URLError(.unknown))
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
                return
            }
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if !stub.data.isEmpty {
                client?.urlProtocol(self, didLoad: stub.data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}

    static func respond(statusCode: Int = 200, with data: Data) {
        setHandler { request in
            .init(
                response: HTTPURLResponse(
                    url: request.url!,
                    statusCode: statusCode,
                    httpVersion: nil,
                    headerFields: nil
                ),
                data: data,
                error: nil
            )
        }
    }

    static func fail(with error: Error) {
        setHandler { _ in .init(response: nil, data: Data(), error: error) }
    }

    static func reset() {
        lock.lock()
        handler = nil
        requests = []
        lock.unlock()
    }

    private static func setHandler(_ newHandler: @escaping (URLRequest) throws -> Stub) {
        lock.lock()
        handler = newHandler
        requests = []
        lock.unlock()
    }
}
