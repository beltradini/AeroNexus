import Fluent
import Vapor
import Foundation

public final class Flight: Model, Content, @unchecked Sendable {
    public static let schema = "flights"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "number")
    var number: String
    
    @Field(key: "origin")
    var origin: String
    
    @Field(key: "destination")
    var destination: String
    
    @Field(key: "departure_at")
    var departureAt: Date
    
    @Field(key: "arrival_at")
    var arrivalAt: Date
    
    @Field(key: "status")
    var status: String
    
    @Field(key: "aircraft_type")
    var aircraftType: String
    
    @Field(key: "scheduled_departure")
    var scheduledDeparture: Date
    
    @Field(key: "scheduled_arrival")
    var scheduledArrival: Date
    
    @Field(key: "departure_airport")
    var departureAirport: String
    
    @Field(key: "arrival_airport")
    var arrivalAirport: String
    
    @Children(for: \.$flight)
    var bookings: [Booking]
    
    public init() {}
    
    init(id: UUID? = nil,
         number: String,
         origin: String,
         destination: String,
         departureAt: Date,
         arrivalAt: Date,
         status: String = "scheduled",
         aircraftType: String,
         scheduledDeparture: Date,
         scheduledArrival: Date,
         departureAirport: String = "",
         arrivalAirport: String = "") {
        self.id = id
        self.number = number
        self.origin = origin
        self.destination = destination
        self.departureAt = departureAt
        self.arrivalAt = arrivalAt
        self.status = status
        self.aircraftType = aircraftType
        self.scheduledDeparture = scheduledDeparture
        self.scheduledArrival = scheduledArrival
        self.departureAirport = departureAirport
        self.arrivalAirport = arrivalAirport
    }
}
