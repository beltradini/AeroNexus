import Fluent

public struct CreateGate: Migration {
    public func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("gates")
            .id()
            .field("identifier", .string, .required)
            .field("terminal", .string, .required)
            .field("is_available", .bool, .required)
            .unique(on: "identifier")
            .create()
    }

    public func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("gates").delete()
    }
}
