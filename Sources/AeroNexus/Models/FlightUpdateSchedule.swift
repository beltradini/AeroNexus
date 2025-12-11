import Fluent
import Vapor 

final class FlightUpdateSchedule: Model, Content, @unchecked Sendable {
    static let schema = "flight_update_schedules"

    @ID(key: .id) var id: UUID?
    @OptionalField(key: "flight_id") var flightID: UUID?
    @OptionalField(key: "airport_code") var airportCode: String?
    @Field(key: "provider") var provider: String
    @Field(key: "interval_seconds") var intervalSeconds: Int
    @Field(key: "enabled") var enabled: Bool
    @Field(key: "next_run_at") var nextRunAt: Date?
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?

    init() {}

    init(id: UUID? = nil, flightID: UUID? = nil, airportCode: String? = nil, provider: String, intervalSeconds: Int, enabled: Bool = true, nextRunAt: Date? = nil) {
        self.id = id
        self.flightID = flightID
        self.airportCode = airportCode
        self.provider = provider
        self.intervalSeconds = intervalSeconds
        self.enabled = enabled
        self.nextRunAt = nextRunAt
    }
}
