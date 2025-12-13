import Vapor
import Fluent

public final class Passenger: Model, Content, @unchecked Sendable {
    public static let schema = "passengers"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "first_name")
    var firstName: String

    @Field(key: "last_name")
    var lastName: String

    @Field(key: "document_number")
    var documentNumber: String

    @Children(for: \.$passenger)
    var bookings: [Booking]

    @Children(for: \.$owner)
    var baggage: [Baggage]

    public init() {}

    init(id: UUID? = nil, firstName: String, lastName: String, documentNumber: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.documentNumber = documentNumber
    }
}
