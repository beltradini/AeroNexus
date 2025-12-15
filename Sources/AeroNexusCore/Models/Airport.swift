import Fluent
import Vapor

public final class Airport: Model, Content, @unchecked Sendable {
    public static let schema = "airports"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "iata_code")
    var iataCode: String

    @Field(key: "icao_code")
    var icaoCode: String

    @Field(key: "name")
    var name: String

    @Field(key: "city")
    var city: String

    @Field(key: "country")
    var country: String

    @Field(key: "latitude")
    var latitude: Double

    @Field(key: "longitude")
    var longitude: Double

    @Field(key: "altitude")
    var altitude: Double

    @Field(key: "timezone")
    var timezone: String

    @Field(key: "runways")
    var runways: Int

    @Field(key: "terminals")
    var terminals: Int

    @Field(key: "gates")
    var gates: Int

    @Field(key: "status")
    var status: String

    @Field(key: "weather_station")
    var weatherStation: String

    @Children(for: \.$departureAirport)
    var departingFlights: [Flight]

    @Children(for: \.$arrivalAirport)
    var arrivingFlights: [Flight]

    public init() {}

    public init(
        id: UUID? = nil,
        iataCode: String,
        icaoCode: String,
        name: String,
        city: String,
        country: String,
        latitude: Double,
        longitude: Double,
        altitude: Double,
        timezone: String,
        runways: Int,
        terminals: Int,
        gates: Int,
        status: String = "operational",
        weatherStation: String
    ) {
        self.id = id
        self.iataCode = iataCode
        self.icaoCode = icaoCode
        self.name = name
        self.city = city
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.timezone = timezone
        self.runways = runways
        self.terminals = terminals
        self.gates = gates
        self.status = status
        self.weatherStation = weatherStation
    }
}

extension Airport {
    public enum AirportStatus: String, Codable {
        case operational = "operational"
        case closed = "closed"
        case maintenance = "maintenance"
        case limited = "limited"
    }
}