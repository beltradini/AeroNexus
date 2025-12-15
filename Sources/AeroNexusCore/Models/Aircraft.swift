import Fluent
import Vapor

public final class Aircraft: Model, Content, @unchecked Sendable {
    public static let schema = "aircrafts"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "registration_number")
    var registrationNumber: String

    @Field(key: "manufacturer")
    var manufacturer: String

    @Field(key: "model")
    var model: String

    @Field(key: "type")
    var type: String

    @Field(key: "capacity")
    var capacity: Int

    @Field(key: "year_built")
    var yearBuilt: Int

    @Field(key: "status")
    var status: String

    @Field(key: "current_airport")
    var currentAirport: String

    @Field(key: "last_maintenance")
    var lastMaintenance: Date

    @Field(key: "next_maintenance")
    var nextMaintenance: Date

    @Field(key: "flight_hours")
    var flightHours: Double

    @Field(key: "airline")
    var airline: String

    @Children(for: \.$aircraft)
    var flights: [Flight]

    public init() {}

    public init(
        id: UUID? = nil,
        registrationNumber: String,
        manufacturer: String,
        model: String,
        type: String,
        capacity: Int,
        yearBuilt: Int,
        status: String = "active",
        currentAirport: String,
        lastMaintenance: Date,
        nextMaintenance: Date,
        flightHours: Double = 0,
        airline: String
    ) {
        self.id = id
        self.registrationNumber = registrationNumber
        self.manufacturer = manufacturer
        self.model = model
        self.type = type
        self.capacity = capacity
        self.yearBuilt = yearBuilt
        self.status = status
        self.currentAirport = currentAirport
        self.lastMaintenance = lastMaintenance
        self.nextMaintenance = nextMaintenance
        self.flightHours = flightHours
        self.airline = airline
    }
}

extension Aircraft {
    public enum AircraftStatus: String, Codable {
        case active = "active"
        case maintenance = "maintenance"
        case reserved = "reserved"
        case inactive = "inactive"
    }
    
    public enum AircraftType: String, Codable {
        case narrowBody = "narrow_body"
        case wideBody = "wide_body"
        case regional = "regional"
        case cargo = "cargo"
        case privateJet = "private_jet"
    }
}