import Vapor

public struct FlightUpdatePacket: Content, Sendable {
    enum UpdateType: String, Codable {
        case statusChange, scheduleChange, gateChange, estimatedTime, unknown
    }

    var provider: String
    var flightNumber: String?
    var flightID: UUID?
    var airportCode: String?
    var type: UpdateType
    var status: String?
    var departureAt: Date?
    var arrivalAt: Date?
    var gate: String?
    var rawPayload: String?

    init(provider: String,
         flightNumber: String? = nil,
         flightID: UUID? = nil,
         airportCode: String? = nil,
         type: UpdateType,
         status: String? = nil,
         departureAt: Date? = nil,
         arrivalAt: Date? = nil,
         gate: String? = nil,
         rawPayload: String? = nil) {
        self.provider = provider
        self.flightNumber = flightNumber
        self.flightID = flightID
        self.airportCode = airportCode
        self.type = type
        self.status = status
        self.departureAt = departureAt
        self.arrivalAt = arrivalAt
        self.gate = gate
        self.rawPayload = rawPayload
    }
}
