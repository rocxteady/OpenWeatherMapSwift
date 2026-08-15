/// Measurement units supported by OpenWeather requests.
public enum UnitPreference: String, Sendable {
    /// Kelvin temperature and meters-per-second wind speed.
    case standard
    /// Celsius temperature and meters-per-second wind speed.
    case metric
    /// Fahrenheit temperature and miles-per-hour wind speed.
    case imperial
}

/// Geographic coordinates returned by OpenWeather.
public struct WeatherCoordinates: Decodable, Sendable {
    /// Longitude in decimal degrees.
    public let longitude: Double
    /// Latitude in decimal degrees.
    public let latitude: Double

    private enum CodingKeys: String, CodingKey {
        case longitude = "lon"
        case latitude = "lat"
    }
}

/// One weather condition returned for an observation.
public struct WeatherCondition: Decodable, Sendable {
    /// OpenWeather condition identifier.
    public let id: Int
    /// Condition group such as Rain or Clouds.
    public let group: String
    /// Localizable condition description.
    public let description: String
    /// OpenWeather icon identifier.
    public let icon: String

    private enum CodingKeys: String, CodingKey {
        case id
        case group = "main"
        case description
        case icon
    }
}

/// Wind measurements for an observation.
public struct Wind: Decodable, Sendable {
    /// Wind speed in the requested unit system.
    public let speed: Double
    /// Meteorological wind direction in degrees.
    public let direction: Int
    /// Wind gust speed when available.
    public let gust: Double?

    private enum CodingKeys: String, CodingKey {
        case speed
        case direction = "deg"
        case gust
    }
}

/// Cloud measurements for an observation.
public struct Clouds: Decodable, Sendable {
    /// Cloud coverage percentage.
    public let coverage: Int

    private enum CodingKeys: String, CodingKey {
        case coverage = "all"
    }
}
