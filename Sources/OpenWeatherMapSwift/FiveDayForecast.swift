/// A five-day forecast containing ordered three-hour entries and city metadata.
public struct FiveDayForecast: Decodable, Sendable {
    /// OpenWeather's response status.
    public let status: String
    /// Internal response message value.
    public let message: Double
    /// Number of entries reported by OpenWeather.
    public let entryCount: Int
    /// Forecast entries in service-provided order.
    public let entries: [ThreeHourForecastEntry]
    /// Metadata for the forecast location.
    public let city: ForecastCity

    private enum CodingKeys: String, CodingKey {
        case status = "cod"
        case message
        case entryCount = "cnt"
        case entries = "list"
        case city
    }
}

/// Weather forecast for one three-hour timestamp.
public struct ThreeHourForecastEntry: Decodable, Sendable {
    /// Forecast timestamp as Unix seconds.
    public let forecastTime: Int
    /// Temperature, pressure, and humidity measurements.
    public let measurements: ThreeHourForecastMeasurements
    /// Conditions in service-provided order.
    public let conditions: [WeatherCondition]
    /// Forecast cloud coverage.
    public let clouds: Clouds
    /// Forecast wind measurements.
    public let wind: Wind
    /// Visibility in meters.
    public let visibility: Int
    /// Probability of precipitation from zero through one.
    public let precipitationProbability: Double
    /// Three-hour rain volume when reported.
    public let rain: ThreeHourPrecipitation?
    /// Three-hour snow volume when reported.
    public let snow: ThreeHourPrecipitation?
    /// Day or night metadata.
    public let partOfDay: ForecastPartOfDay
    /// Service-provided UTC timestamp text.
    public let forecastTimeText: String

    private enum CodingKeys: String, CodingKey {
        case forecastTime = "dt"
        case measurements = "main"
        case conditions = "weather"
        case clouds
        case wind
        case visibility
        case precipitationProbability = "pop"
        case rain
        case snow
        case partOfDay = "sys"
        case forecastTimeText = "dt_txt"
    }
}

/// Temperature, pressure, and humidity values for a three-hour forecast.
public struct ThreeHourForecastMeasurements: Decodable, Sendable {
    /// Forecast temperature in the requested unit system.
    public let temperature: Double
    /// Human-perceived temperature in the requested unit system.
    public let feelsLike: Double
    /// Minimum forecast temperature when available.
    public let minimumTemperature: Double?
    /// Maximum forecast temperature when available.
    public let maximumTemperature: Double?
    /// Atmospheric pressure in hPa.
    public let pressure: Int
    /// Sea-level pressure in hPa.
    public let seaLevelPressure: Int
    /// Ground-level pressure in hPa.
    public let groundLevelPressure: Int
    /// Relative humidity percentage.
    public let humidity: Int
    /// OpenWeather's internal temperature adjustment.
    public let temperatureAdjustment: Double

    private enum CodingKeys: String, CodingKey {
        case temperature = "temp"
        case feelsLike = "feels_like"
        case minimumTemperature = "temp_min"
        case maximumTemperature = "temp_max"
        case pressure
        case seaLevelPressure = "sea_level"
        case groundLevelPressure = "grnd_level"
        case humidity
        case temperatureAdjustment = "temp_kf"
    }
}

/// Rain or snow volume for a three-hour period.
public struct ThreeHourPrecipitation: Decodable, Sendable {
    /// Volume during the three-hour period in millimeters.
    public let threeHourVolume: Double

    private enum CodingKeys: String, CodingKey {
        case threeHourVolume = "3h"
    }
}

/// Day or night metadata for a forecast timestamp.
public struct ForecastPartOfDay: Decodable, Sendable {
    /// Service value identifying day (`d`) or night (`n`).
    public let part: String

    private enum CodingKeys: String, CodingKey {
        case part = "pod"
    }
}

/// Location metadata returned with a five-day forecast.
public struct ForecastCity: Decodable, Sendable {
    /// OpenWeather's internal city identifier.
    public let id: Int
    /// Location name returned by OpenWeather.
    public let name: String
    /// Geographic coordinates for the location.
    public let coordinates: WeatherCoordinates
    /// ISO 3166 country code.
    public let country: String
    /// Reported population.
    public let population: Int
    /// Offset from UTC in seconds.
    public let timezoneOffset: Int
    /// Sunrise time as Unix seconds.
    public let sunrise: Int
    /// Sunset time as Unix seconds.
    public let sunset: Int

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case coordinates = "coord"
        case country
        case population
        case timezoneOffset = "timezone"
        case sunrise
        case sunset
    }
}
