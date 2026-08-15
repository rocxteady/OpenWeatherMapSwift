import Foundation

/// Current weather conditions for one location.
public struct CurrentWeather: Decodable, Sendable {
    /// Coordinates represented by this observation.
    public let coordinates: WeatherCoordinates
    /// Conditions in service-provided order.
    public let conditions: [WeatherCondition]
    /// Internal data-source name supplied by OpenWeather.
    public let base: String
    /// Temperature, pressure, and humidity measurements.
    public let measurements: CurrentWeatherMeasurements
    /// Visibility in meters.
    public let visibility: Int
    /// Current wind measurements.
    public let wind: Wind
    /// Current cloud coverage.
    public let clouds: Clouds
    /// Rain volume when reported.
    public let rain: Precipitation?
    /// Snow volume when reported.
    public let snow: Precipitation?
    /// Time of calculation as Unix seconds.
    public let calculationTime: Int
    /// Location and daylight metadata.
    public let system: CurrentWeatherSystem
    /// Offset from UTC in seconds.
    public let timezoneOffset: Int
    /// OpenWeather's internal location identifier.
    public let locationID: Int
    /// Location name returned by OpenWeather.
    public let locationName: String
    /// Service status in its original numeric or text form.
    public let status: CurrentWeatherStatus

    private enum CodingKeys: String, CodingKey {
        case coordinates = "coord"
        case conditions = "weather"
        case base
        case measurements = "main"
        case visibility
        case wind
        case clouds
        case rain
        case snow
        case calculationTime = "dt"
        case system = "sys"
        case timezoneOffset = "timezone"
        case locationID = "id"
        case locationName = "name"
        case status = "cod"
    }
}

/// Temperature, pressure, and humidity values for an observation.
public struct CurrentWeatherMeasurements: Decodable, Sendable {
    /// Current temperature in the requested unit system.
    public let temperature: Double
    /// Human-perceived temperature in the requested unit system.
    public let feelsLike: Double
    /// Minimum currently observed temperature, when available.
    public let minimumTemperature: Double?
    /// Maximum currently observed temperature, when available.
    public let maximumTemperature: Double?
    /// Atmospheric pressure in hPa.
    public let pressure: Int
    /// Relative humidity percentage.
    public let humidity: Int
    /// Sea-level pressure in hPa, when available.
    public let seaLevelPressure: Int?
    /// Ground-level pressure in hPa, when available.
    public let groundLevelPressure: Int?

    private enum CodingKeys: String, CodingKey {
        case temperature = "temp"
        case feelsLike = "feels_like"
        case minimumTemperature = "temp_min"
        case maximumTemperature = "temp_max"
        case pressure
        case humidity
        case seaLevelPressure = "sea_level"
        case groundLevelPressure = "grnd_level"
    }
}

/// Recent rain or snow volume.
public struct Precipitation: Decodable, Sendable {
    /// Volume during the previous hour in millimeters.
    public let lastHour: Double

    private enum CodingKeys: String, CodingKey {
        case lastHour = "1h"
    }
}

/// Location and daylight metadata for an observation.
public struct CurrentWeatherSystem: Decodable, Sendable {
    /// Internal system type when supplied.
    public let type: Int?
    /// Internal system identifier when supplied.
    public let id: Int?
    /// Internal service message when supplied.
    public let message: Double?
    /// ISO 3166 country code.
    public let country: String
    /// Sunrise time as Unix seconds.
    public let sunrise: Int
    /// Sunset time as Unix seconds.
    public let sunset: Int
}

/// OpenWeather status preserving its original JSON representation.
public enum CurrentWeatherStatus: Decodable, Sendable {
    /// A numeric status value.
    case number(Int)
    /// A text status value.
    case text(String)

    /// Decodes a numeric or text status value.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let number = try? container.decode(Int.self) {
            self = .number(number)
        } else {
            self = .text(try container.decode(String.self))
        }
    }
}
