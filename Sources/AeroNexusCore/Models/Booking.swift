import Vapor
import Fluent

public final class Booking: Model, Content, @unchecked Sendable {
    public static let schema = "bookings"

    @ID(key: .id)
    public var id: UUID?

    @Parent(key: "passenger_id")
    var passenger: Passenger

    @Parent(key: "flight_id")
    var flight: Flight

    @Field(key: "seat")
    var seat: String

    @Field(key: "status")
    var status: String

    public init() {}

    init(id: UUID? = nil, passengerID: UUID, flightID: UUID, seat: String, status: String = "confirmed") {
        self.id = id
        self.$passenger.id = passengerID
        self.$flight.id = flightID
        self.seat = seat
        self.status = status
    }
}
