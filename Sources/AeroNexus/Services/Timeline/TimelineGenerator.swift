import Foundation
import Vapor 

class TimelineGenerator: @unchecked Sendable {
    // Dependencies
    private let flightService: any FlightService
    private let calculator: TimelineCalculator
    private let validator: TimelineValidator

    init(flightService: any FlightService, calculator: TimelineCalculator = TimelineCalculator(), validator: TimelineValidator = TimelineValidator()) {
        self.flightService = flightService
        self.calculator = calculator
        self.validator = validator
    }

    func generateTimeline(for flightId: UUID) async throws -> [TimelineEvent] {
        
        let flight = try await flightService.getFlight(flightId)

        let eventTimes = calculator.calculateEventTimes(for: flight, departureTime: flight.scheduledDeparture, arrivalTime: flight.scheduledArrival)

        let adjustedEventTimes = calculator.applyAirportAdjustments(eventTimes, departureAirport: flight.departureAirport, arrivalAirport: flight.arrivalAirport)

        let timelineEvents = createTimelineEvents(from: adjustedEventTimes, for: flight)

        try validator.validate(timeline: timelineEvents, for: flight)

        return timelineEvents
    }

    private func createTimelineEvents(from eventTimes: [TimelineEventType: Date], for flight: Flight) -> [TimelineEvent] {
        var events: [TimelineEvent] = []

        for (eventType, scheduledTime) in eventTimes {
            let location = determineEventLocation(eventType, flight: flight)
            let status = TimelineEventStatus.scheduled

            let event = TimelineEvent(
                flightId: flight.id!,
                eventType: eventType,
                scheduledTime: scheduledTime,
                location: location,
                status: status
            )

            events.append(event)
        }

        return events.sorted { $0.scheduledTime < $1.scheduledTime }
    }
    
    private func determineEventLocation(_ eventType: TimelineEventType, flight: Flight) -> String {
        switch eventType {
        case .departureGateOpen, .boardingStart, .boardingComplete, .pushback, .taxiOut, .takeoff:
            return flight.departureAirport
        case .landing, .taxiIn, .arrivalGateOpen, .baggageClaimStart, .baggageClaimComplete:
            return flight.arrivalAirport
        case .climb, .cruise, .descent:
            return "On route"
        case .custom:
            return "Unknow"
        }
    }
    
    func updateTimeline(with actualEvent: TimelineEvent) async throws -> [TimelineEvent] {
        let existingTimeline = try await getExistingTimeline(for: actualEvent.flightId)
        
        var updatedTimeline = existingTimeline
        if let index = updatedTimeline.firstIndex(where: { $0.eventType == actualEvent.eventType }) {
            // Create a new event with actual status
            let updatedEvent = TimelineEvent(
                id: updatedTimeline[index].id,
                flightId: updatedTimeline[index].flightId,
                eventType: updatedTimeline[index].eventType,
                scheduledTime: updatedTimeline[index].scheduledTime,
                actualTime: actualEvent.actualTime,
                estimatedTime: updatedTimeline[index].estimatedTime,
                location: updatedTimeline[index].location,
                status: .actual,
                metadata: updatedTimeline[index].metadata
            )
            updatedTimeline[index] = updatedEvent
        }
        
        // 3. Recalculate
        let recalculatedTimeline = recalculateSubsequentEvents(after: actualEvent, in: updatedTimeline)
        
        // 4. Validate the updated timeline
        let flight = try await flightService.getFlight(actualEvent.flightId)
        try validator.validate(timeline: recalculatedTimeline, for: flight)
        return recalculatedTimeline
    }
    
    private func recalculateSubsequentEvents(after actualEvent: TimelineEvent, in timeline: [TimelineEvent]) -> [TimelineEvent] {
        // Find the index of the actual event
        guard let actualIndex = timeline.firstIndex(where: { $0.eventType == actualEvent.eventType && $0.status == .actual }) else {
            return timeline
        }
        
        var updatedTimeline = timeline
        
        // For events after the actual event, update their estimated times
        for i in (actualIndex + 1)..<updatedTimeline.count {
            if updatedTimeline[i].status != .actual {
                let timeDifference = actualEvent.actualTime!.timeIntervalSince(actualEvent.scheduledTime)
                
                // Create a new event with estimated status and time
                let estimatedEvent = TimelineEvent(
                    id: updatedTimeline[i].id,
                    flightId: updatedTimeline[i].flightId,
                    eventType: updatedTimeline[i].eventType,
                    scheduledTime: updatedTimeline[i].scheduledTime,
                    actualTime: updatedTimeline[i].actualTime,
                    estimatedTime: updatedTimeline[i].scheduledTime.addingTimeInterval(timeDifference),
                    location: updatedTimeline[i].location,
                    status: .estimated,
                    metadata: updatedTimeline[i].metadata
                )
                updatedTimeline[i] = estimatedEvent
            }
        }
        
        return updatedTimeline
    }
    
    private func getExistingTimeline(for flightId: UUID) async throws -> [TimelineEvent] {
        return try await generateTimeline(for: flightId)
    }
}
