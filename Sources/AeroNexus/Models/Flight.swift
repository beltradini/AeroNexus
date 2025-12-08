import Vapor
import Fluent

final class Flight: Model, Content, @unchecked Sendable {
    static let schema = "flights"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "number")
    var number: String

    @Field(key: "origin")
    var origin: String

    @Field(key: "destination")
    var destination: String

    @Field(key: "departure_at")
    var departureAt: Date

    @Field(key: "arrival_at")
    var arrivalAt: Date

    @Field(key: "status")
    var status: String

    @Children(for: \.$flight)
    var bookings: [Booking]

    init() {}

    init(id: UUID? = nil, number: String, origin: String, destination: String, departureAt: Date, arrivalAt: Date, status: String = "scheduled") {
        self.id = id
        self.number = number
        self.origin = origin
        self.destination = destination
        self.departureAt = departureAt
        self.arrivalAt = arrivalAt
        self.status = status
    }
}
