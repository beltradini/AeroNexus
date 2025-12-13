import Vapor
import Fluent

public final class Baggage: Model, Content, @unchecked Sendable {
    public static let schema = "baggage"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "tag")
    var tag: String

    @Parent(key: "owner_id")
    var owner: Passenger

    @OptionalParent(key: "flight_id")
    var flight: Flight?

    @Field(key: "status")
    var status: String

    public init() {}

    init(id: UUID? = nil, tag: String, ownerID: UUID, flightID: UUID?, status: String = "checked_in") {
        self.id = id
        self.tag = tag
        self.$owner.id = ownerID
        if let f = flightID { self.$flight.id = f }
        self.status = status
    }
}
