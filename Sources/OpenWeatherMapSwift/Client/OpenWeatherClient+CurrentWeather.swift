import Foundation

extension OpenWeatherClient {
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

        var optionalQueryItems: [URLQueryItem] = []
        if let units {
            optionalQueryItems.append(URLQueryItem(name: "units", value: units.rawValue))
        }
        if let language {
            optionalQueryItems.append(URLQueryItem(name: "lang", value: language))
        }

        return try await execute(
            url: URL(string: "https://api.openweathermap.org/data/2.5/weather")!,
            queryItems: [
                URLQueryItem(name: "lat", value: String(latitude)),
                URLQueryItem(name: "lon", value: String(longitude)),
            ],
            optionalQueryItems: optionalQueryItems,
            as: CurrentWeather.self
        )
    }
}
