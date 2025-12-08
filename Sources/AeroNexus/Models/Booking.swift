import Vapor
import Fluent

final class Booking: Model, Content, @unchecked Sendable {
    static let schema = "bookings"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "passenger_id")
    var passenger: Passenger

    @Parent(key: "flight_id")
    var flight: Flight

    @Field(key: "seat")
    var seat: String

    @Field(key: "status")
    var status: String

    init() {}

    init(id: UUID? = nil, passengerID: UUID, flightID: UUID, seat: String, status: String = "confirmed") {
        self.id = id
        self.$passenger.id = passengerID
        self.$flight.id = flightID
        self.seat = seat
        self.status = status
    }
}

struct CreateBooking: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema(Booking.schema)
            .id()
            .field("passenger_id", .uuid, .required, .references(Passenger.schema, "id", onDelete: .cascade))
            .field("flight_id", .uuid, .required, .references(Flight.schema, "id", onDelete: .cascade))
            .field("seat", .string, .required)
            .field("status", .string, .required)
            .create()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema(Booking.schema).delete()
    }
}
