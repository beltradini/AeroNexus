import Fluent
import Vapor
import Foundation

public final class FlightUpdated: Model, Content, @unchecked Sendable {
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

    @Parent(key: "aircraft_id")
    var aircraft: Aircraft

    @Parent(key: "departure_airport_id")
    var departureAirport: Airport

    @Parent(key: "arrival_airport_id")
    var arrivalAirport: Airport

    @Field(key: "scheduled_departure")
    var scheduledDeparture: Date

    @Field(key: "scheduled_arrival")
    var scheduledArrival: Date

    @Children(for: \.$flight)
    var bookings: [Booking]

    public init() {}

    public init(
        id: UUID? = nil,
        number: String,
        origin: String,
        destination: String,
        departureAt: Date,
        arrivalAt: Date,
        status: String = "scheduled",
        aircraftId: UUID,
        departureAirportId: UUID,
        arrivalAirportId: UUID,
        scheduledDeparture: Date,
        scheduledArrival: Date
    ) {
        self.id = id
        self.number = number
        self.origin = origin
        self.destination = destination
        self.departureAt = departureAt
        self.arrivalAt = arrivalAt
        self.status = status
        self.$aircraft.id = aircraftId
        self.$departureAirport.id = departureAirportId
        self.$arrivalAirport.id = arrivalAirportId
        self.scheduledDeparture = scheduledDeparture
        self.scheduledArrival = scheduledArrival
    }
}