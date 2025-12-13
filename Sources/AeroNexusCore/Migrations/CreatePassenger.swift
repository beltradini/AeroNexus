import Fluent

public struct CreatePassenger: Migration {
    public func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("passengers")
            .id()
            .field("first_name", .string, .required)
            .field("last_name", .string, .required)
            .field("document_number", .string, .required)
            .unique(on: "document_number")
            .create()
    }

    public func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("passengers").delete()
    }
}
