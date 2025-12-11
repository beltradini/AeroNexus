import Fluent
import Vapor

final class FlightUpdate: Model, Content, @unchecked Sendable {
    static let schema = "flight_updates"

    @ID(key: .id) var id: UUID?
    @OptionalField(key: "flight_id") var flightID: UUID?
    @OptionalField(key: "flight_number") var flightNumber: String?
    @OptionalField(key: "airport_code") var airportCode: String?
    @Field(key: "provider") var provider: String
    @Field(key: "type") var type: String
    @OptionalField(key: "status") var status: String?
    @OptionalField(key: "departure_at") var departureAt: Date?
    @OptionalField(key: "arrival_at") var arrivalAt: Date?
    @OptionalField(key: "gate") var gate: String?
    @Field(key: "raw_payload") var rawPayload: String
    @Field(key: "processed") var processed: Bool
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        flightID: UUID? = nil,
        flightNumber: String? = nil,
        airportCode: String? = nil,
        provider: String,
        type: String,
        status: String? = nil,
        departureAt: Date? = nil,
        arrivalAt: Date? = nil,
        gate: String? = nil,
        rawPayload: String,
        processed: Bool = false
    ) {
        self.id = id
        self.flightID = flightID
        self.flightNumber = flightNumber
        self.airportCode = airportCode
        self.provider = provider
        self.type = type
        self.status = status
        self.departureAt = departureAt
        self.arrivalAt = arrivalAt
        self.gate = gate
        self.rawPayload = rawPayload
        self.processed = processed
    }
}
