import Vapor
import Fluent

final class Passenger: Model, Content, @unchecked Sendable {
    static let schema = "passengers"

    @ID(key: .id)
    var id: UUID?

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

    init() {}

    init(id: UUID? = nil, firstName: String, lastName: String, documentNumber: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.documentNumber = documentNumber
    }
}
