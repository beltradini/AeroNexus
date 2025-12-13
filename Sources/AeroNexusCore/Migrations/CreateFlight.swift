import Fluent

public struct CreateFlight: Migration {
    public func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("flights")
            .id()
            .field("number", .string, .required)
            .field("origin", .string, .required)
            .field("destination", .string, .required)
            .field("departure_at", .datetime, .required)
            .field("arrival_at", .datetime, .required)
            .field("status", .string, .required)
            .unique(on: "number")
            .create()
    }

    public func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("flights").delete()
    }
}
