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
