import Vapor
import Fluent

final class Gate: Model, Content, @unchecked Sendable {
    static let schema = "gates"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "identifier")
    var identifier: String

    @Field(key: "terminal")
    var terminal: String

    @Field(key: "is_available")
    var isAvailable: Bool

    init() {}

    init(id: UUID? = nil, identifier: String, terminal: String, isAvailable: Bool = true) {
        self.id = id
        self.identifier = identifier
        self.terminal = terminal
        self.isAvailable = isAvailable
    }
}

struct CreateGate: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema(Gate.schema)
            .id()
            .field("identifier", .string, .required)
            .field("terminal", .string, .required)
            .field("is_available", .bool, .required, .sql(.default(true)))
            .unique(on: "identifier")
            .create()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema(Gate.schema).delete()
    }
}
