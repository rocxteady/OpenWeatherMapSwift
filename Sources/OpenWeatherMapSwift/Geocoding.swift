/// A named location returned by direct or reverse geocoding.
public struct GeocodedLocation: Decodable, Sendable {
    /// The location name.
    public let name: String
    /// Names keyed by the service-provided language or name category.
    public let localizedNames: [String: String]?
    /// The latitude in decimal degrees.
    public let latitude: Double
    /// The longitude in decimal degrees.
    public let longitude: Double
    /// The country code.
    public let country: String
    /// The state or region name, when supplied.
    public let state: String?

    private enum CodingKeys: String, CodingKey {
        case name
        case localizedNames = "local_names"
        case latitude = "lat"
        case longitude = "lon"
        case country
        case state
    }
}

/// A postal-code area returned by ZIP geocoding.
public struct PostalLocation: Decodable, Sendable {
    /// The postal code.
    public let postalCode: String
    /// The location name.
    public let name: String
    /// The latitude in decimal degrees.
    public let latitude: Double
    /// The longitude in decimal degrees.
    public let longitude: Double
    /// The country code.
    public let country: String

    private enum CodingKeys: String, CodingKey {
        case postalCode = "zip"
        case name
        case latitude = "lat"
        case longitude = "lon"
        case country
    }
}
