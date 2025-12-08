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

struct CreateFlight: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema(Flight.schema)
            .id()
            .field("number", .string, .required)
            .field("origin", .string, .required)
            .field("destination", .string, .required)
            .field("departure_at", .datetime, .required)
            .field("arrival_at", .datetime, .required)
            .field("status", .string, .required)
            .unique(on: "number")
            .create()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema(Flight.schema).delete()
    }
}
