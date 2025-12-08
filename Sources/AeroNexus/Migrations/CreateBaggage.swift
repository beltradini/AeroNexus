import Fluent

struct CreateBaggage: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("baggage")
            .id()
            .field("tag", .string, .required)
            .field("owner_id", .uuid, .required, .references("passengers", "id", onDelete: .cascade))
            .field("flight_id", .uuid, .references("flights", "id", onDelete: .setNull))
            .field("status", .string, .required)
            .unique(on: "tag")
            .create()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("baggage").delete()
    }
}
