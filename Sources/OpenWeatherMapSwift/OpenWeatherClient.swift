import Foundation
import Resting

/// Measurement units supported by OpenWeather requests.
public enum UnitPreference: String, Sendable {
    /// Kelvin temperature and meters-per-second wind speed.
    case standard
    /// Celsius temperature and meters-per-second wind speed.
    case metric
    /// Fahrenheit temperature and miles-per-hour wind speed.
    case imperial
}

/// A reusable client for OpenWeather API operations.
public final class OpenWeatherClient: Sendable {
    private let apiKey: String
    private let restClient: RestClient

    /// Creates a client with a caller-owned API key and Resting configuration.
    ///
    /// - Parameters:
    ///   - apiKey: The OpenWeather API key sent with requests but never persisted by the package.
    ///   - configuration: The Resting configuration used to create the reusable HTTP client.
    public init(
        apiKey: String,
        configuration: RestClientConfiguration = .init()
    ) {
        self.apiKey = apiKey
        self.restClient = RestClient(configuration: configuration)
    }

    /// Fetches current weather for one geographic coordinate.
    ///
    /// - Parameters:
    ///   - latitude: Latitude in the closed range `-90...90`.
    ///   - longitude: Longitude in the closed range `-180...180`.
    ///   - units: Optional measurement units; `nil` uses the service default.
    ///   - language: Optional OpenWeather language code.
    /// - Returns: The decoded current-weather observation.
    /// - Throws: `RestingError.invalidRequest` for invalid coordinates, or an untranslated Resting failure.
    public func currentWeather(
        latitude: Double,
        longitude: Double,
        units: UnitPreference? = nil,
        language: String? = nil
    ) async throws -> CurrentWeather {
        try validateCoordinates(latitude: latitude, longitude: longitude)

        var queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "appid", value: apiKey),
        ]
        if let units {
            queryItems.append(URLQueryItem(name: "units", value: units.rawValue))
        }
        if let language {
            queryItems.append(URLQueryItem(name: "lang", value: language))
        }

        return try await restClient.execute(
            .query(
                url: URL(string: "https://api.openweathermap.org/data/2.5/weather")!,
                queryItems: queryItems
            ),
            as: CurrentWeather.self
        )
    }

    /// Fetches the ordered five-day forecast in three-hour intervals.
    ///
    /// - Parameters:
    ///   - latitude: Latitude in the closed range `-90...90`.
    ///   - longitude: Longitude in the closed range `-180...180`.
    ///   - maximumTimestampCount: Optional positive maximum number of timestamps.
    ///   - units: Optional measurement units; `nil` uses the service default.
    ///   - language: Optional OpenWeather language code.
    /// - Returns: The decoded forecast timeline and city metadata.
    /// - Throws: `RestingError.invalidRequest` for invalid input, or an untranslated Resting failure.
    public func fiveDayForecast(
        latitude: Double,
        longitude: Double,
        maximumTimestampCount: Int? = nil,
        units: UnitPreference? = nil,
        language: String? = nil
    ) async throws -> FiveDayForecast {
        try validateCoordinates(latitude: latitude, longitude: longitude)

        var queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "appid", value: apiKey),
        ]
        if let maximumTimestampCount {
            guard maximumTimestampCount > 0 else {
                throw RestingError.invalidRequest(reason: "Maximum timestamp count must be positive.")
            }
            queryItems.append(URLQueryItem(name: "cnt", value: String(maximumTimestampCount)))
        }
        if let units {
            queryItems.append(URLQueryItem(name: "units", value: units.rawValue))
        }
        if let language {
            queryItems.append(URLQueryItem(name: "lang", value: language))
        }

        return try await restClient.execute(
            .query(
                url: URL(string: "https://api.openweathermap.org/data/2.5/forecast")!,
                queryItems: queryItems
            ),
            as: FiveDayForecast.self
        )
    }

    /// Fetches an ordered daily forecast for one geographic coordinate.
    ///
    /// - Parameters:
    ///   - latitude: Latitude in the closed range `-90...90`.
    ///   - longitude: Longitude in the closed range `-180...180`.
    ///   - maximumDayCount: Optional number of days in the closed range `1...16`.
    ///   - units: Optional measurement units; `nil` uses the service default.
    ///   - language: Optional OpenWeather language code.
    /// - Returns: The decoded daily forecast and city metadata.
    /// - Throws: `RestingError.invalidRequest` for invalid input, or an untranslated Resting failure.
    public func dailyForecast(
        latitude: Double,
        longitude: Double,
        maximumDayCount: Int? = nil,
        units: UnitPreference? = nil,
        language: String? = nil
    ) async throws -> DailyForecast {
        try validateCoordinates(latitude: latitude, longitude: longitude)

        var queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "appid", value: apiKey),
        ]
        if let maximumDayCount {
            guard (1...16).contains(maximumDayCount) else {
                throw RestingError.invalidRequest(reason: "Maximum day count must be between 1 and 16.")
            }
            queryItems.append(URLQueryItem(name: "cnt", value: String(maximumDayCount)))
        }
        if let units {
            queryItems.append(URLQueryItem(name: "units", value: units.rawValue))
        }
        if let language {
            queryItems.append(URLQueryItem(name: "lang", value: language))
        }

        return try await restClient.execute(
            .query(
                url: URL(string: "https://api.openweathermap.org/data/2.5/forecast/daily")!,
                queryItems: queryItems
            ),
            as: DailyForecast.self
        )
    }

    private func validateCoordinates(latitude: Double, longitude: Double) throws {
        guard (-90...90).contains(latitude) else {
            throw RestingError.invalidRequest(reason: "Latitude must be between -90 and 90.")
        }
        guard (-180...180).contains(longitude) else {
            throw RestingError.invalidRequest(reason: "Longitude must be between -180 and 180.")
        }
    }
}
