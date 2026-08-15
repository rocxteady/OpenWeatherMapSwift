import Foundation
import Resting
import Testing
@testable import OpenWeatherMapSwift

extension OpenWeatherClientTests {
    @Test func fiveDayForecastFullResponsePreservesOrderAndRequest() async throws {
        StubURLProtocol.respond(with: try fixture("forecast-5-day-full.json"))

        let forecast = try await makeClient(apiKey: "sentinel-key").fiveDayForecast(
            latitude: 41.0082,
            longitude: 28.9784,
            units: .metric,
            language: "tr"
        )

        #expect(forecast.status == "200")
        #expect(forecast.message == 0)
        #expect(forecast.entryCount == 40)
        #expect(forecast.entries.count == 40)
        #expect(forecast.entries.map(\.forecastTime) == (0..<40).map { 1_786_806_000 + $0 * 10_800 })
        #expect(forecast.entries[0].conditions.map(\.id) == [500, 701])

        let entry = forecast.entries[0]
        #expect(entry.measurements.temperature == 19.2)
        #expect(entry.measurements.feelsLike == 18.9)
        #expect(entry.measurements.minimumTemperature == 18.7)
        #expect(entry.measurements.maximumTemperature == 19.2)
        #expect(entry.measurements.pressure == 1013)
        #expect(entry.measurements.seaLevelPressure == 1013)
        #expect(entry.measurements.groundLevelPressure == 1007)
        #expect(entry.measurements.humidity == 68)
        #expect(entry.measurements.temperatureAdjustment == 0.5)
        #expect(entry.conditions.map(\.group) == ["Rain", "Mist"])
        #expect(entry.conditions.map(\.description) == ["light rain", "mist"])
        #expect(entry.conditions.map(\.icon) == ["10d", "50d"])
        #expect(entry.clouds.coverage == 0)
        #expect(entry.wind.speed == 3.5)
        #expect(entry.wind.direction == 225)
        #expect(entry.wind.gust == 5.4)
        #expect(entry.visibility == 10_000)
        #expect(entry.precipitationProbability == 0)
        #expect(entry.rain?.threeHourVolume == 1.2)
        #expect(entry.snow?.threeHourVolume == 0.2)
        #expect(entry.partOfDay.part == "d")
        #expect(entry.forecastTimeText == "2026-08-15 15:00:00")

        #expect(forecast.city.id == 745_044)
        #expect(forecast.city.name == "Istanbul")
        #expect(forecast.city.coordinates.latitude == 41.0082)
        #expect(forecast.city.coordinates.longitude == 28.9784)
        #expect(forecast.city.country == "TR")
        #expect(forecast.city.population == 15_460_000)
        #expect(forecast.city.timezoneOffset == 10_800)
        #expect(forecast.city.sunrise == 1_786_759_200)
        #expect(forecast.city.sunset == 1_786_810_200)

        let request = try #require(StubURLProtocol.requests.first)
        #expect(StubURLProtocol.requests.count == 1)
        #expect(request.httpMethod == "GET")
        #expect(request.httpBody == nil)
        #expect(request.url?.path == "/data/2.5/forecast")
        #expect(queryValues(in: request, named: "lat") == ["41.0082"])
        #expect(queryValues(in: request, named: "lon") == ["28.9784"])
        #expect(queryValues(in: request, named: "appid") == ["sentinel-key"])
        #expect(queryValues(in: request, named: "units") == ["metric"])
        #expect(queryValues(in: request, named: "lang") == ["tr"])
        #expect(queryValues(in: request, named: "mode").isEmpty)
    }

    @Test func fiveDayForecastOmitsUnsuppliedPreferences() async throws {
        StubURLProtocol.respond(with: try fixture("forecast-5-day-full.json"))

        _ = try await makeClient().fiveDayForecast(latitude: 41, longitude: 29)

        let request = try #require(StubURLProtocol.requests.first)
        #expect(queryValues(in: request, named: "units").isEmpty)
        #expect(queryValues(in: request, named: "lang").isEmpty)
        #expect(queryValues(in: request, named: "cnt").isEmpty)
    }

    @Test func fiveDayForecastSendsPositiveMaximumTimestampCount() async throws {
        StubURLProtocol.respond(with: try fixture("forecast-5-day-full.json"))

        _ = try await makeClient().fiveDayForecast(
            latitude: 41,
            longitude: 29,
            maximumTimestampCount: 8
        )

        let request = try #require(StubURLProtocol.requests.first)
        #expect(queryValues(in: request, named: "cnt") == ["8"])
    }

    @Test(arguments: [0, -1])
    func fiveDayForecastRejectsNonPositiveMaximumTimestampCount(_ count: Int) async {
        do {
            _ = try await makeClient().fiveDayForecast(
                latitude: 41,
                longitude: 29,
                maximumTimestampCount: count
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

    @Test func fiveDayForecastKeepsReturnedCountIndependentFromMaximum() async throws {
        var response = try #require(
            JSONSerialization.jsonObject(with: fixture("forecast-5-day-full.json")) as? [String: Any]
        )
        let entries = try #require(response["list"] as? [[String: Any]])
        response["cnt"] = 2
        response["list"] = Array(entries.prefix(2))
        StubURLProtocol.respond(with: try JSONSerialization.data(withJSONObject: response))

        let forecast = try await makeClient().fiveDayForecast(
            latitude: 41,
            longitude: 29,
            maximumTimestampCount: 8
        )

        #expect(forecast.entryCount == 2)
        #expect(forecast.entries.count == 2)
    }

    @Test func fiveDayForecastCoordinateBoundariesAreAccepted() async throws {
        StubURLProtocol.respond(with: try fixture("forecast-5-day-full.json"))
        let client = makeClient()

        _ = try await client.fiveDayForecast(latitude: -90, longitude: -180)
        _ = try await client.fiveDayForecast(latitude: 90, longitude: 180)

        #expect(StubURLProtocol.requests.count == 2)
    }

    @Test(arguments: [
        (latitude: -90.0001, longitude: 0.0),
        (latitude: 90.0001, longitude: 0.0),
        (latitude: 0.0, longitude: -180.0001),
        (latitude: 0.0, longitude: 180.0001),
        (latitude: Double.nan, longitude: 0.0),
        (latitude: 0.0, longitude: Double.infinity),
    ])
    func fiveDayForecastInvalidCoordinatesFailBeforeNetworking(
        latitude: Double,
        longitude: Double
    ) async {
        do {
            _ = try await makeClient().fiveDayForecast(latitude: latitude, longitude: longitude)
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

    @Test func fiveDayForecastPreservesConditionalWeatherValues() async throws {
        StubURLProtocol.respond(with: try fixture("forecast-5-day-optional.json"))

        let entries = try await makeClient().fiveDayForecast(latitude: 41, longitude: 29).entries

        #expect(entries.count == 5)
        #expect(entries[0].measurements.minimumTemperature == nil)
        #expect(entries[0].measurements.maximumTemperature == nil)
        #expect(entries[0].rain == nil)
        #expect(entries[0].snow == nil)
        #expect(entries[0].wind.gust == nil)
        #expect(entries[1].rain?.threeHourVolume == 1.5)
        #expect(entries[1].snow == nil)
        #expect(entries[1].wind.gust == 6.2)
        #expect(entries[2].rain == nil)
        #expect(entries[2].snow?.threeHourVolume == 0.7)
        #expect(entries[2].wind.gust == nil)
        #expect(entries[3].rain?.threeHourVolume == 0.4)
        #expect(entries[3].snow?.threeHourVolume == 0.2)
        #expect(entries[4].rain == nil)
        #expect(entries[4].snow == nil)
        #expect(entries[4].wind.gust == 8.1)
    }

    @Test func fiveDayForecastCancellationIsPreserved() async {
        StubURLProtocol.fail(with: URLError(.cancelled))

        do {
            _ = try await makeClient().fiveDayForecast(latitude: 0, longitude: 0)
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

    @Test func fiveDayForecastTransportFailureIsPreserved() async {
        StubURLProtocol.fail(with: URLError(.notConnectedToInternet))

        do {
            _ = try await makeClient().fiveDayForecast(latitude: 0, longitude: 0)
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

    @Test func fiveDayForecastRejectedStatusRetainsResponseBytes() async {
        let bytes = Data("rate limited".utf8)
        StubURLProtocol.respond(statusCode: 429, with: bytes)

        do {
            _ = try await makeClient().fiveDayForecast(latitude: 0, longitude: 0)
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

    @Test func fiveDayForecastMalformedJSONRetainsResponseBytes() async {
        let bytes = Data("{".utf8)
        StubURLProtocol.respond(with: bytes)

        do {
            _ = try await makeClient().fiveDayForecast(latitude: 0, longitude: 0)
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

    @Test func fiveDayForecastCredentialAppearsOnlyInRequestQuery() async throws {
        let apiKey = "forecast-credential-sentinel"
        StubURLProtocol.respond(with: try fixture("forecast-5-day-optional.json"))
        let client = makeClient(apiKey: apiKey)

        let forecast = try await client.fiveDayForecast(latitude: 41, longitude: 29)

        let request = try #require(StubURLProtocol.requests.first)
        #expect(queryValues(in: request, named: "appid") == [apiKey])
        #expect(!String(describing: client).contains(apiKey))
        #expect(!String(describing: forecast).contains(apiKey))
    }
}
