import Foundation
import Resting

extension OpenWeatherClient {
    /// Finds ordered locations matching a place query.
    ///
    /// - Parameters:
    ///   - place: A nonblank place query sent unchanged to OpenWeather.
    ///   - maximumResultCount: An optional result limit in the closed range `1...5`.
    /// - Returns: The decoded matching locations in service order.
    /// - Throws: `RestingError.invalidRequest` for invalid input, or an untranslated Resting failure.
    public func geocode(
        place: String,
        maximumResultCount: Int? = nil
    ) async throws -> [GeocodedLocation] {
        guard !place.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw RestingError.invalidRequest(reason: "Place must not be blank.")
        }

        var optionalQueryItems: [URLQueryItem] = []
        if let maximumResultCount {
            guard (1...5).contains(maximumResultCount) else {
                throw RestingError.invalidRequest(reason: "Maximum result count must be between 1 and 5.")
            }
            optionalQueryItems.append(URLQueryItem(name: "limit", value: String(maximumResultCount)))
        }

        return try await execute(
            url: URL(string: "https://api.openweathermap.org/geo/1.0/direct")!,
            queryItems: [URLQueryItem(name: "q", value: place)],
            optionalQueryItems: optionalQueryItems,
            as: [GeocodedLocation].self
        )
    }

    /// Finds the location represented by a postal and country code.
    ///
    /// - Parameters:
    ///   - postalCode: A nonblank postal code sent unchanged to OpenWeather.
    ///   - countryCode: A nonblank country code sent unchanged to OpenWeather.
    /// - Returns: The decoded postal-code area.
    /// - Throws: `RestingError.invalidRequest` for invalid input, or an untranslated Resting failure.
    public func geocode(
        postalCode: String,
        countryCode: String
    ) async throws -> PostalLocation {
        guard !postalCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw RestingError.invalidRequest(reason: "Postal code must not be blank.")
        }
        guard !countryCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw RestingError.invalidRequest(reason: "Country code must not be blank.")
        }

        return try await execute(
            url: URL(string: "https://api.openweathermap.org/geo/1.0/zip")!,
            queryItems: [
                URLQueryItem(name: "zip", value: "\(postalCode),\(countryCode)"),
            ],
            as: PostalLocation.self
        )
    }

    /// Finds ordered nearby locations for one geographic coordinate.
    ///
    /// - Parameters:
    ///   - latitude: Latitude in the closed range `-90...90`.
    ///   - longitude: Longitude in the closed range `-180...180`.
    ///   - maximumResultCount: An optional positive result limit.
    /// - Returns: The decoded nearby locations in service order.
    /// - Throws: `RestingError.invalidRequest` for invalid input, or an untranslated Resting failure.
    public func reverseGeocode(
        latitude: Double,
        longitude: Double,
        maximumResultCount: Int? = nil
    ) async throws -> [GeocodedLocation] {
        try validateCoordinates(latitude: latitude, longitude: longitude)

        var optionalQueryItems: [URLQueryItem] = []
        if let maximumResultCount {
            guard maximumResultCount > 0 else {
                throw RestingError.invalidRequest(reason: "Maximum result count must be positive.")
            }
            optionalQueryItems.append(URLQueryItem(name: "limit", value: String(maximumResultCount)))
        }

        return try await execute(
            url: URL(string: "https://api.openweathermap.org/geo/1.0/reverse")!,
            queryItems: [
                URLQueryItem(name: "lat", value: String(latitude)),
                URLQueryItem(name: "lon", value: String(longitude)),
            ],
            optionalQueryItems: optionalQueryItems,
            as: [GeocodedLocation].self
        )
    }
}
