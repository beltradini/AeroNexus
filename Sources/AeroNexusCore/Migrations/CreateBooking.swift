import Fluent

public struct CreateBooking: Migration {
    public func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("bookings")
            .id()
            .field("passenger_id", .uuid, .required, .references("passengers", "id", onDelete: .cascade))
            .field("flight_id", .uuid, .required, .references("flights", "id", onDelete: .cascade))
            .field("seat", .string, .required)
            .field("status", .string, .required)
            .create()
    }

    public func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("bookings").delete()
    }
}
