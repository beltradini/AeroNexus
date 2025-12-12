import Foundation

class TimelineCalculator {

    private let standardDurations: [String: [TimelineEventType: TimeInterval]] = [
        "small": [
            .boardingStart: -45 * 60, // 45 minutes before departure
            .boardingComplete: -15 * 60, // 15 minutes before departure
            .pushback: 0, // at departure time
            .taxiOut: 10 * 60, // 10 minutes taxi
            .takeoff: 15 * 60, // 15 minutes after pushback
            // ... other events
        ],

        "medium": [
            .boardingStart: -60 * 60,
            .boardingComplete: -20 * 60,
            .pushback: 0,
            .taxiOut: 15 * 60,
            .takeoff: 20 * 60,
            // ... other events
        ],

        "large": [
            .boardingStart: -90 * 60,
            .boardingComplete: -30 * 60,
            .pushback: 0,
            .taxiOut: 20 * 60,
            .takeoff: 25 * 60,
            // ... other events
        ]
    ]

    func calculateEventTimes(for flight: Flight, departureTime: Date, arrivalTime: Date) -> [TimelineEventType: Date] {
        var eventTimes: [TimelineEventType: Date] = [:]

        let aircraftCategory = determineAircraftCategory(flight.aircraftType)

        let durations = standardDurations[aircraftCategory] ?? standardDurations["medium"]!

        for(eventType, offset) in durations {
            if offset < 0 {
                let eventTime = departureTime.addingTimeInterval(offset)
                eventTimes[eventType] = eventTime
            } else {
                let eventTime = departureTime.addingTimeInterval(offset)
                eventTimes[eventType] = eventTime
            }
        }

        let landingTime = arrivalTime.addingTimeInterval(-10 * 60)
        eventTimes[.landing] = landingTime

        let taxiInTime = landingTime.addingTimeInterval(5 * 60)
        eventTimes[.taxiIn] = taxiInTime

        return eventTimes
    }

    private func determineAircraftCategory(_ aircraftType: String) -> String {

        if aircraftType.contains("A380") || aircraftType.contains("B747") {
            return "large"
        } else if aircraftType.contains("A320") || aircraftType.contains("B737") {
            return "medium"
        } else {
            return "small"
        }
    }

    func applyAirportAdjustments(_ eventTimes: [TimelineEventType: Date], departureAirport: String, arrivalAirport: String) -> [TimelineEventType: Date] {
        var adjustedTimes = eventTimes

        if departureAirport == "JFK" {
            if let taxiOutTime = adjustedTimes[.taxiOut] {
                adjustedTimes[.taxiOut] = taxiOutTime.addingTimeInterval(10 * 60)
            }
        }

        if arrivalAirport == "JFK" {
            if let taxiInTime = adjustedTimes[.taxiIn] {
                adjustedTimes[.taxiIn] = taxiInTime.addingTimeInterval(10 * 60)
            }
        }

        return adjustedTimes
    }
}
