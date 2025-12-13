import Foundation
import Vapor
import Fluent

public final class TimelineEvent: Model, Content, @unchecked Sendable {
    public static let schema = "timeline_events"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "flight_id")
    var flightId: UUID

    @Field(key: "event_type")
    var eventType: TimelineEventType

    @Field(key: "scheduled_time")
    var scheduledTime: Date

    @OptionalField(key: "actual_time")
    var actualTime: Date?

    @OptionalField(key: "estimated_time")
    var estimatedTime: Date?

    @Field(key: "location")
    var location: String

    @Field(key: "status")
    var status: TimelineEventStatus

    @OptionalField(key: "metadata")
    var metadata: [String: String]?

    public init() {}

    init(id: UUID? = nil,
         flightId: UUID,
         eventType: TimelineEventType,
         scheduledTime: Date,
         actualTime: Date? = nil,
         estimatedTime: Date? = nil,
         location: String,
         status: TimelineEventStatus,
         metadata: [String: String]? = nil) {
        self.id = id
        self.flightId = flightId
        self.eventType = eventType
        self.scheduledTime = scheduledTime
        self.actualTime = actualTime
        self.estimatedTime = estimatedTime
        self.location = location
        self.status = status
        self.metadata = metadata
    }
}

enum TimelineEventType: String, Codable, CaseIterable {
    case departureGateOpen
    case boardingStart
    case boardingComplete
    case pushback
    case taxiOut
    case takeoff
    case climb
    case cruise
    case descent
    case landing
    case taxiIn
    case arrivalGateOpen
    case baggageClaimStart
    case baggageClaimComplete
    case custom
}

enum TimelineEventStatus: String, Codable {
    case scheduled
    case estimated
    case actual
    case delayed
    case cancelled
}


