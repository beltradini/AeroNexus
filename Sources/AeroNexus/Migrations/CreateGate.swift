import Fluent

struct CreateGate: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("gates")
            .id()
            .field("identifier", .string, .required)
            .field("terminal", .string, .required)
            .field("is_available", .bool, .required, .sql(.default(true)))
            .unique(on: "identifier")
            .create()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("gates").delete()
    }
}
