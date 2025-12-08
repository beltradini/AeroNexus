import Fluent

struct CreatePassenger: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("passengers")
            .id()
            .field("first_name", .string, .required)
            .field("last_name", .string, .required)
            .field("document_number", .string, .required)
            .unique(on: "document_number")
            .create()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("passengers").delete()
    }
}
