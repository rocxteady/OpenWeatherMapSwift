import Foundation
import Resting

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

    func execute<Response: Decodable>(
        url: URL,
        queryItems: [URLQueryItem],
        optionalQueryItems: [URLQueryItem] = [],
        as type: Response.Type
    ) async throws -> Response {
        try await restClient.execute(
            .query(
                url: url,
                queryItems: queryItems
                    + [URLQueryItem(name: "appid", value: apiKey)]
                    + optionalQueryItems
            ),
            as: type
        )
    }

    func validateCoordinates(latitude: Double, longitude: Double) throws {
        guard (-90...90).contains(latitude) else {
            throw RestingError.invalidRequest(reason: "Latitude must be between -90 and 90.")
        }
        guard (-180...180).contains(longitude) else {
            throw RestingError.invalidRequest(reason: "Longitude must be between -180 and 180.")
        }
    }
}
