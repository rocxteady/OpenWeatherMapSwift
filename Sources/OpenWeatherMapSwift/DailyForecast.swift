/// A daily forecast containing ordered entries and city metadata.
public struct DailyForecast: Decodable, Sendable {
    /// Metadata for the forecast location.
    public let city: DailyForecastCity
    /// OpenWeather's response status.
    public let status: String
    /// Internal response message value.
    public let message: Double
    /// Number of entries reported by OpenWeather.
    public let entryCount: Int
    /// Daily entries in service-provided order.
    public let entries: [DailyForecastEntry]

    private enum CodingKeys: String, CodingKey {
        case city
        case status = "cod"
        case message
        case entryCount = "cnt"
        case entries = "list"
    }
}

/// Location metadata returned with a daily forecast.
public struct DailyForecastCity: Decodable, Sendable {
    /// OpenWeather's internal city identifier.
    public let id: Int
    /// Location name returned by OpenWeather.
    public let name: String
    /// Geographic coordinates for the location.
    public let coordinates: WeatherCoordinates
    /// ISO 3166 country code.
    public let country: String
    /// Reported population when available.
    public let population: Int?
    /// Offset from UTC in seconds.
    public let timezoneOffset: Int

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case coordinates = "coord"
        case country
        case population
        case timezoneOffset = "timezone"
    }
}

/// Weather forecast for one day.
public struct DailyForecastEntry: Decodable, Sendable {
    /// Forecast date and time as Unix seconds.
    public let forecastTime: Int
    /// Sunrise time as Unix seconds.
    public let sunrise: Int
    /// Sunset time as Unix seconds.
    public let sunset: Int
    /// Temperatures for the day's local-time periods.
    public let temperature: DailyTemperature
    /// Human-perceived temperatures for the day's local-time periods.
    public let perceivedTemperature: DailyPerceivedTemperature
    /// Sea-level atmospheric pressure in hPa.
    public let pressure: Int
    /// Relative humidity percentage.
    public let humidity: Int
    /// Conditions in service-provided order.
    public let conditions: [WeatherCondition]
    /// Maximum wind speed in the requested unit system.
    public let maximumWindSpeed: Double
    /// Direction associated with the maximum wind speed, in degrees.
    public let maximumWindDirection: Int
    /// Wind gust speed when available.
    public let windGust: Double?
    /// Cloud coverage percentage.
    public let cloudCoverage: Int
    /// Daily rain volume in millimeters when available.
    public let rainVolume: Double?
    /// Daily snow volume in millimeters when available.
    public let snowVolume: Double?
    /// Probability of precipitation from zero through one.
    public let precipitationProbability: Double

    private enum CodingKeys: String, CodingKey {
        case forecastTime = "dt"
        case sunrise
        case sunset
        case temperature = "temp"
        case perceivedTemperature = "feels_like"
        case pressure
        case humidity
        case conditions = "weather"
        case maximumWindSpeed = "speed"
        case maximumWindDirection = "deg"
        case windGust = "gust"
        case cloudCoverage = "clouds"
        case rainVolume = "rain"
        case snowVolume = "snow"
        case precipitationProbability = "pop"
    }
}

/// Temperatures for local-time periods and daily extremes.
public struct DailyTemperature: Decodable, Sendable {
    /// Temperature at local noon.
    public let day: Double
    /// Minimum daily temperature.
    public let minimum: Double
    /// Maximum daily temperature.
    public let maximum: Double
    /// Temperature at local midnight.
    public let night: Double
    /// Temperature in the local evening.
    public let evening: Double
    /// Temperature in the local morning.
    public let morning: Double

    private enum CodingKeys: String, CodingKey {
        case day
        case minimum = "min"
        case maximum = "max"
        case night
        case evening = "eve"
        case morning = "morn"
    }
}

/// Human-perceived temperatures for local-time periods.
public struct DailyPerceivedTemperature: Decodable, Sendable {
    /// Perceived temperature at local noon.
    public let day: Double
    /// Perceived temperature at local midnight.
    public let night: Double
    /// Perceived temperature in the local evening.
    public let evening: Double
    /// Perceived temperature in the local morning.
    public let morning: Double

    private enum CodingKeys: String, CodingKey {
        case day
        case night
        case evening = "eve"
        case morning = "morn"
    }
}
