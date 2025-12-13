import Foundation

public class TimelineValidator: @unchecked Sendable {

    enum ValidationError: Error {
        case eventsOutOfOrder
        case missingRequiredEvents
        case invalidTimeConstraints
        case airportRuleViolation(String)
    }

    func validate(timeline: [TimelineEvent], for flight: Flight) throws {
        try validateChronologicalOrder(timeline)
        try validateRequiredEvents(timeline)
        try validateTimeConstraints(timeline, flight: flight)
        try validateAirportRules(timeline, flight: flight)
    }

    private func validateChronologicalOrder(_ timeline: [TimelineEvent]) throws {
        for i in 1..<timeline.count {
            let previous = timeline[i-1]
            let current = timeline[i]

            if current.scheduledTime < previous.scheduledTime {
                throw ValidationError.eventsOutOfOrder
            }
        }
    }

    private func validateRequiredEvents(_ timeline: [TimelineEvent]) throws {
        let requiredEvents: [TimelineEventType] = [
            .departureGateOpen, .boardingStart, .boardingComplete,
            .pushback, .takeoff, .landing, .arrivalGateOpen
        ]

        let presentEvents = Set(timeline.map { $0.eventType })
        let missingEvents = requiredEvents.filter { !presentEvents.contains($0) }

        if !missingEvents.isEmpty {
            throw ValidationError.missingRequiredEvents
        }
    }

    private func validateTimeConstraints(_ timeline: [TimelineEvent], flight: Flight) throws {
        guard let firstEvent = timeline.first,
            let lastEvent = timeline.last else {
                throw ValidationError.invalidTimeConstraints
            }

            let flightStart = flight.scheduledDeparture.addingTimeInterval(-3 * 60 * 60)
            let flightEnd = flight.scheduledArrival.addingTimeInterval(3 * 60 * 60)

            if firstEvent.scheduledTime < flightStart || lastEvent.scheduledTime > flightEnd {
                throw ValidationError.invalidTimeConstraints
            }
    }

    private func validateAirportRules(_ timeline: [TimelineEvent], flight: Flight) throws {
        if let gateOpen = timeline.first(where: { $0.eventType == .departureGateOpen }),
        let boardingStart = timeline.first(where: { $0.eventType == .boardingStart }) {

            let gateTime = boardingStart.scheduledTime.timeIntervalSince(gateOpen.scheduledTime)
            let minGateTime: TimeInterval = 15 * 60

            if gateTime < minGateTime {
                throw ValidationError.airportRuleViolation("Minimum gate time violation")
            }
        }
    }
}
