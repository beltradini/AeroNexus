import Fluent

public struct CreateFlightUpdates: Migration {
    public func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("flight_updates")
            .id()
            .field("flight_id", .uuid)
            .field("flight_number", .string)
            .field("airport_code", .string)
            .field("provider", .string, .required)
            .field("type", .string, .required)
            .field("status", .string)
            .field("departure_at", .datetime)
            .field("arrival_at", .datetime)
            .field("gate", .string)
            .field("raw_payload", .string, .required)
            .field("processed", .bool, .required)
            .field("created_at", .datetime)
            .create()
    }
    public func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("flight_updates").delete()
    }
}
