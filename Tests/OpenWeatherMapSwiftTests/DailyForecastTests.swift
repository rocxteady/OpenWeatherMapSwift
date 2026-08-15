import Foundation
import Resting
import Testing
@testable import OpenWeatherMapSwift

extension OpenWeatherClientTests {
    @Test func dailyForecastFullResponsePreservesOrderAndRequest() async throws {
        StubURLProtocol.respond(with: try fixture("forecast-daily-full.json"))

        let forecast = try await makeClient(apiKey: "sentinel-key").dailyForecast(
            latitude: 41.0082,
            longitude: 28.9784,
            maximumDayCount: 16,
            units: .metric,
            language: "tr"
        )

        #expect(forecast.status == "200")
        #expect(forecast.message == 0)
        #expect(forecast.entryCount == 16)
        #expect(forecast.entries.count == 16)
        #expect(forecast.entries.map(\.forecastTime) == (0..<16).map { 1_786_795_200 + $0 * 86_400 })

        #expect(forecast.city.id == 745_044)
        #expect(forecast.city.name == "Istanbul")
        #expect(forecast.city.coordinates.latitude == 41.0082)
        #expect(forecast.city.coordinates.longitude == 28.9784)
        #expect(forecast.city.country == "TR")
        #expect(forecast.city.population == 15_460_000)
        #expect(forecast.city.timezoneOffset == 10_800)

        let entry = forecast.entries[0]
        #expect(entry.sunrise == 1_786_759_200)
        #expect(entry.sunset == 1_786_810_200)
        #expect(entry.temperature.day == 24.1)
        #expect(entry.temperature.minimum == 19.3)
        #expect(entry.temperature.maximum == 25.6)
        #expect(entry.temperature.night == 20.2)
        #expect(entry.temperature.evening == 23.4)
        #expect(entry.temperature.morning == 19.7)
        #expect(entry.perceivedTemperature.day == 24.3)
        #expect(entry.perceivedTemperature.night == 20.4)
        #expect(entry.perceivedTemperature.evening == 23.6)
        #expect(entry.perceivedTemperature.morning == 19.8)
        #expect(entry.pressure == 1_012)
        #expect(entry.humidity == 65)
        #expect(entry.conditions.map(\.id) == [500, 701])
        #expect(entry.conditions.map(\.group) == ["Rain", "Mist"])
        #expect(entry.conditions.map(\.description) == ["light rain", "mist"])
        #expect(entry.conditions.map(\.icon) == ["10d", "50d"])
        #expect(entry.maximumWindSpeed == 4.2)
        #expect(entry.maximumWindDirection == 220)
        #expect(entry.windGust == 6.1)
        #expect(entry.cloudCoverage == 58)
        #expect(entry.rainVolume == 1.7)
        #expect(entry.snowVolume == 0.1)
        #expect(entry.precipitationProbability == 0.05)

        let request = try #require(StubURLProtocol.requests.first)
        #expect(StubURLProtocol.requests.count == 1)
        #expect(request.httpMethod == "GET")
        #expect(request.httpBody == nil)
        #expect(request.url?.path == "/data/2.5/forecast/daily")
        #expect(queryValues(in: request, named: "lat") == ["41.0082"])
        #expect(queryValues(in: request, named: "lon") == ["28.9784"])
        #expect(queryValues(in: request, named: "appid") == ["sentinel-key"])
        #expect(queryValues(in: request, named: "cnt") == ["16"])
        #expect(queryValues(in: request, named: "units") == ["metric"])
        #expect(queryValues(in: request, named: "lang") == ["tr"])
        #expect(queryValues(in: request, named: "mode").isEmpty)
    }

    @Test func dailyForecastOmitsUnsuppliedPreferences() async throws {
        StubURLProtocol.respond(with: try fixture("forecast-daily-full.json"))

        _ = try await makeClient().dailyForecast(latitude: 41, longitude: 29)

        let request = try #require(StubURLProtocol.requests.first)
        #expect(queryValues(in: request, named: "cnt").isEmpty)
        #expect(queryValues(in: request, named: "units").isEmpty)
        #expect(queryValues(in: request, named: "lang").isEmpty)
    }

    @Test func dailyForecastKeepsReturnedCountIndependentFromMaximum() async throws {
        var response = try #require(
            JSONSerialization.jsonObject(with: fixture("forecast-daily-full.json")) as? [String: Any]
        )
        let entries = try #require(response["list"] as? [[String: Any]])
        response["cnt"] = 2
        response["list"] = Array(entries.prefix(2))
        StubURLProtocol.respond(with: try JSONSerialization.data(withJSONObject: response))

        let forecast = try await makeClient().dailyForecast(
            latitude: 41,
            longitude: 29,
            maximumDayCount: 16
        )

        #expect(forecast.entryCount == 2)
        #expect(forecast.entries.count == 2)
    }

    @Test func dailyForecastCredentialAppearsOnlyInRequestQuery() async throws {
        let apiKey = "daily-forecast-credential-sentinel"
        StubURLProtocol.respond(with: try fixture("forecast-daily-full.json"))
        let client = makeClient(apiKey: apiKey)

        let forecast = try await client.dailyForecast(latitude: 41, longitude: 29)

        let request = try #require(StubURLProtocol.requests.first)
        #expect(queryValues(in: request, named: "appid") == [apiKey])
        #expect(!String(describing: client).contains(apiKey))
        #expect(!String(describing: forecast).contains(apiKey))
    }

    @Test func dailyForecastAcceptsCountAndCoordinateBoundaries() async throws {
        StubURLProtocol.respond(with: try fixture("forecast-daily-full.json"))
        let client = makeClient()

        _ = try await client.dailyForecast(latitude: -90, longitude: -180, maximumDayCount: 1)
        _ = try await client.dailyForecast(latitude: 90, longitude: 180, maximumDayCount: 16)
        _ = try await client.dailyForecast(latitude: 0, longitude: 0)

        #expect(StubURLProtocol.requests.count == 3)
        #expect(queryValues(in: StubURLProtocol.requests[0], named: "cnt") == ["1"])
        #expect(queryValues(in: StubURLProtocol.requests[1], named: "cnt") == ["16"])
        #expect(queryValues(in: StubURLProtocol.requests[2], named: "cnt").isEmpty)
    }

    @Test(arguments: [-1, 0, 17])
    func dailyForecastRejectsOutOfRangeDayCount(_ count: Int) async {
        do {
            _ = try await makeClient().dailyForecast(
                latitude: 41,
                longitude: 29,
                maximumDayCount: count
            )
            Issue.record("Expected invalid count to fail")
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

    @Test(arguments: [
        (latitude: -90.0001, longitude: 0.0),
        (latitude: 90.0001, longitude: 0.0),
        (latitude: 0.0, longitude: -180.0001),
        (latitude: 0.0, longitude: 180.0001),
        (latitude: Double.nan, longitude: 0.0),
        (latitude: 0.0, longitude: Double.infinity),
    ])
    func dailyForecastRejectsInvalidCoordinates(
        latitude: Double,
        longitude: Double
    ) async {
        do {
            _ = try await makeClient().dailyForecast(latitude: latitude, longitude: longitude)
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

    @Test func dailyForecastPreservesOptionalWeatherValues() async throws {
        StubURLProtocol.respond(with: try fixture("forecast-daily-optional.json"))

        let forecast = try await makeClient().dailyForecast(latitude: 41, longitude: 29)
        let entries = forecast.entries

        #expect(forecast.city.population == nil)
        #expect(entries.count == 5)
        #expect(entries[0].rainVolume == nil)
        #expect(entries[0].snowVolume == nil)
        #expect(entries[0].windGust == nil)
        #expect(entries[1].rainVolume == 1.5)
        #expect(entries[1].snowVolume == nil)
        #expect(entries[1].windGust == 6.2)
        #expect(entries[2].rainVolume == nil)
        #expect(entries[2].snowVolume == 0.7)
        #expect(entries[2].windGust == nil)
        #expect(entries[3].rainVolume == 0.4)
        #expect(entries[3].snowVolume == 0.2)
        #expect(entries[3].windGust == nil)
        #expect(entries[4].rainVolume == nil)
        #expect(entries[4].snowVolume == nil)
        #expect(entries[4].windGust == 8.1)
    }

    @Test func dailyForecastSubscriptionFailureRetainsResponseBytes() async {
        let bytes = Data("subscription required".utf8)
        StubURLProtocol.respond(statusCode: 403, with: bytes)

        do {
            _ = try await makeClient().dailyForecast(latitude: 0, longitude: 0)
            Issue.record("Expected status failure")
        } catch let error as RestingError {
            guard case .statusCode(403, let data) = error else {
                Issue.record("Expected statusCode, got \(error)")
                return
            }
            #expect(data == bytes)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func dailyForecastCancellationIsPreserved() async {
        StubURLProtocol.fail(with: URLError(.cancelled))

        do {
            _ = try await makeClient().dailyForecast(latitude: 0, longitude: 0)
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

    @Test func dailyForecastTransportFailureIsPreserved() async {
        StubURLProtocol.fail(with: URLError(.notConnectedToInternet))

        do {
            _ = try await makeClient().dailyForecast(latitude: 0, longitude: 0)
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

    @Test func dailyForecastMalformedJSONRetainsResponseBytes() async {
        let bytes = Data("{".utf8)
        StubURLProtocol.respond(with: bytes)

        do {
            _ = try await makeClient().dailyForecast(latitude: 0, longitude: 0)
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
}
