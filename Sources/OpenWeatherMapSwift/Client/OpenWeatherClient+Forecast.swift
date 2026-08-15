import Foundation
import Resting

extension OpenWeatherClient {
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

        var optionalQueryItems: [URLQueryItem] = []
        if let maximumTimestampCount {
            guard maximumTimestampCount > 0 else {
                throw RestingError.invalidRequest(reason: "Maximum timestamp count must be positive.")
            }
            optionalQueryItems.append(URLQueryItem(name: "cnt", value: String(maximumTimestampCount)))
        }
        if let units {
            optionalQueryItems.append(URLQueryItem(name: "units", value: units.rawValue))
        }
        if let language {
            optionalQueryItems.append(URLQueryItem(name: "lang", value: language))
        }

        return try await execute(
            url: URL(string: "https://api.openweathermap.org/data/2.5/forecast")!,
            queryItems: [
                URLQueryItem(name: "lat", value: String(latitude)),
                URLQueryItem(name: "lon", value: String(longitude)),
            ],
            optionalQueryItems: optionalQueryItems,
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

        var optionalQueryItems: [URLQueryItem] = []
        if let maximumDayCount {
            guard (1...16).contains(maximumDayCount) else {
                throw RestingError.invalidRequest(reason: "Maximum day count must be between 1 and 16.")
            }
            optionalQueryItems.append(URLQueryItem(name: "cnt", value: String(maximumDayCount)))
        }
        if let units {
            optionalQueryItems.append(URLQueryItem(name: "units", value: units.rawValue))
        }
        if let language {
            optionalQueryItems.append(URLQueryItem(name: "lang", value: language))
        }

        return try await execute(
            url: URL(string: "https://api.openweathermap.org/data/2.5/forecast/daily")!,
            queryItems: [
                URLQueryItem(name: "lat", value: String(latitude)),
                URLQueryItem(name: "lon", value: String(longitude)),
            ],
            optionalQueryItems: optionalQueryItems,
            as: DailyForecast.self
        )
    }
}
