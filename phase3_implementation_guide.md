# Phase 3 Implementation Guide: Timeline Generator

## Step-by-Step Implementation Plan

### Step 1: Create Directory Structure

```bash
mkdir -p Sources/AeroNexus/Services/Timeline
```

### Step 2: Implement TimelineEvent Model

**File**: `Sources/AeroNexus/Services/Timeline/TimelineEvent.swift`

```swift
import Foundation
import Vapor

struct TimelineEvent: Codable {
    let id: UUID
    let flightId: UUID
    let eventType: TimelineEventType
    let scheduledTime: Date
    let actualTime: Date?
    let estimatedTime: Date?
    let location: String
    let status: TimelineEventStatus
    let metadata: [String: String]?
    
    init(id: UUID = UUID(),
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

extension TimelineEvent: Content {}
extension TimelineEvent: Model {
    static let schema = "timeline_events"
}
```

### Step 3: Create TimelineCalculator

**File**: `Sources/AeroNexus/Services/Timeline/TimelineCalculator.swift`

```swift
import Foundation

class TimelineCalculator {
    
    // Standard durations in minutes for different aircraft types
    private let standardDurations: [String: [TimelineEventType: TimeInterval]] = [
        // Small aircraft (e.g., regional jets)
        "small": [
            .boardingStart: -45 * 60, // 45 minutes before departure
            .boardingComplete: -15 * 60, // 15 minutes before departure
            .pushback: 0, // at departure time
            .taxiOut: 10 * 60, // 10 minutes taxi
            .takeoff: 15 * 60, // 15 minutes after pushback
            // ... other events
        ],
        
        // Medium aircraft (e.g., A320, B737)
        "medium": [
            .boardingStart: -60 * 60,
            .boardingComplete: -20 * 60,
            .pushback: 0,
            .taxiOut: 15 * 60,
            .takeoff: 20 * 60,
            // ... other events
        ],
        
        // Large aircraft (e.g., A380, B747)
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
        
        // Get aircraft category (you'll need to add this to Flight model or determine it)
        let aircraftCategory = determineAircraftCategory(flight.aircraftType)
        
        // Get standard durations for this aircraft type
        let durations = standardDurations[aircraftCategory] ?? standardDurations["medium"]!
        
        // Calculate departure-related events
        for (eventType, offset) in durations {
            if offset < 0 {
                // Events before departure
                let eventTime = departureTime.addingTimeInterval(offset)
                eventTimes[eventType] = eventTime
            } else {
                // Events at or after departure
                let eventTime = departureTime.addingTimeInterval(offset)
                eventTimes[eventType] = eventTime
            }
        }
        
        // Calculate arrival-related events (simplified example)
        // You'll want to implement proper flight duration calculation
        let flightDuration = arrivalTime.timeIntervalSince(departureTime)
        
        // Example: landing is 10 minutes before arrival
        let landingTime = arrivalTime.addingTimeInterval(-10 * 60)
        eventTimes[.landing] = landingTime
        
        // Example: taxiIn is 5 minutes after landing
        let taxiInTime = landingTime.addingTimeInterval(5 * 60)
        eventTimes[.taxiIn] = taxiInTime
        
        return eventTimes
    }
    
    private func determineAircraftCategory(_ aircraftType: String) -> String {
        // Implement logic to categorize aircraft
        // This could be based on aircraft codes, sizes, etc.
        if aircraftType.contains("A380") || aircraftType.contains("B747") {
            return "large"
        } else if aircraftType.contains("A320") || aircraftType.contains("B737") {
            return "medium"
        } else {
            return "small"
        }
    }
    
    /// Airport-specific adjustments (to be implemented)
    func applyAirportAdjustments(_ eventTimes: [TimelineEventType: Date], 
                                departureAirport: String, 
                                arrivalAirport: String) -> [TimelineEventType: Date] {
        var adjustedTimes = eventTimes
        
        // Example: Some airports have longer taxi times
        if departureAirport == "JFK" {
            if let taxiOutTime = adjustedTimes[.taxiOut] {
                adjustedTimes[.taxiOut] = taxiOutTime.addingTimeInterval(10 * 60) // Add 10 minutes
            }
        }
        
        // Add more airport-specific rules as needed
        
        return adjustedTimes
    }
}
```

### Step 4: Implement TimelineValidator

**File**: `Sources/AeroNexus/Services/Timeline/TimelineValidator.swift`

```swift
import Foundation

class TimelineValidator {
    
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
            
            // Check that current event is after previous event
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
        // Ensure all events are within reasonable bounds
        // relative to flight departure and arrival times
        
        guard let firstEvent = timeline.first,
              let lastEvent = timeline.last else {
            throw ValidationError.invalidTimeConstraints
        }
        
        // Events should be around the flight times
        let flightStart = flight.scheduledDeparture.addingTimeInterval(-3 * 60 * 60) // 3 hours before
        let flightEnd = flight.scheduledArrival.addingTimeInterval(3 * 60 * 60) // 3 hours after
        
        if firstEvent.scheduledTime < flightStart || lastEvent.scheduledTime > flightEnd {
            throw ValidationError.invalidTimeConstraints
        }
    }
    
    private func validateAirportRules(_ timeline: [TimelineEvent], flight: Flight) throws {
        // Example: Some airports have minimum gate times
        if let gateOpen = timeline.first(where: { $0.eventType == .departureGateOpen }),
           let boardingStart = timeline.first(where: { $0.eventType == .boardingStart }) {
            
            let gateTime = boardingStart.scheduledTime.timeIntervalSince(gateOpen.scheduledTime)
            let minGateTime: TimeInterval = 15 * 60 // 15 minutes minimum
            
            if gateTime < minGateTime {
                throw ValidationError.airportRuleViolation("Minimum gate time violation")
            }
        }
        
        // Add more airport-specific validation rules
    }
}
```

### Step 5: Implement TimelineGenerator

**File**: `Sources/AeroNexus/Services/Timeline/TimelineGenerator.swift`

```swift
import Foundation
import Vapor

class TimelineGenerator {
    
    private let flightService: FlightService
    private let calculator: TimelineCalculator
    private let validator: TimelineValidator
    
    init(flightService: FlightService,
         calculator: TimelineCalculator = TimelineCalculator(),
         validator: TimelineValidator = TimelineValidator()) {
        self.flightService = flightService
        self.calculator = calculator
        self.validator = validator
    }
    
    /// Generate complete timeline for a flight
    func generateTimeline(for flightId: UUID) async throws -> [TimelineEvent] {
        // 1. Fetch flight details
        let flight = try await flightService.getFlight(flightId)
        
        // 2. Calculate event times
        let eventTimes = calculator.calculateEventTimes(
            for: flight,
            departureTime: flight.scheduledDeparture,
            arrivalTime: flight.scheduledArrival
        )
        
        // 3. Apply airport-specific adjustments
        let adjustedEventTimes = calculator.applyAirportAdjustments(
            eventTimes,
            departureAirport: flight.departureAirport,
            arrivalAirport: flight.arrivalAirport
        )
        
        // 4. Create timeline events
        let timelineEvents = createTimelineEvents(from: adjustedEventTimes, for: flight)
        
        // 5. Validate timeline
        try validator.validate(timeline: timelineEvents, for: flight)
        
        return timelineEvents
    }
    
    private func createTimelineEvents(from eventTimes: [TimelineEventType: Date], 
                                    for flight: Flight) -> [TimelineEvent] {
        var events: [TimelineEvent] = []
        
        for (eventType, scheduledTime) in eventTimes {
            let location = determineEventLocation(eventType, flight: flight)
            let status: TimelineEventStatus = .scheduled
            
            let event = TimelineEvent(
                flightId: flight.id!,
                eventType: eventType,
                scheduledTime: scheduledTime,
                location: location,
                status: status
            )
            
            events.append(event)
        }
        
        // Sort events chronologically
        return events.sorted { $0.scheduledTime < $1.scheduledTime }
    }
    
    private func determineEventLocation(_ eventType: TimelineEventType, flight: Flight) -> String {
        switch eventType {
        case .departureGateOpen, .boardingStart, .boardingComplete, .pushback, .taxiOut, .takeoff:
            return flight.departureAirport
        case .landing, .taxiIn, .arrivalGateOpen, .baggageClaimStart, .baggageClaimComplete:
            return flight.arrivalAirport
        case .climb, .cruise, .descent:
            return "En route"
        case .custom:
            return "Unknown"
        }
    }
    
    /// Update timeline with actual event data
    func updateTimeline(with actualEvent: TimelineEvent) async throws -> [TimelineEvent] {
        // 1. Get existing timeline
        let existingTimeline = try await getExistingTimeline(for: actualEvent.flightId)
        
        // 2. Find and update the specific event
        var updatedTimeline = existingTimeline
        if let index = updatedTimeline.firstIndex(where: { $0.eventType == actualEvent.eventType }) {
            updatedTimeline[index] = actualEvent
            updatedTimeline[index].status = .actual
        }
        
        // 3. Recalculate subsequent events if needed
        let recalculatedTimeline = recalculateSubsequentEvents(after: actualEvent, in: updatedTimeline)
        
        // 4. Validate the updated timeline
        let flight = try await flightService.getFlight(actualEvent.flightId)
        try validator.validate(timeline: recalculatedTimeline, for: flight)
        
        return recalculatedTimeline
    }
    
    private func recalculateSubsequentEvents(after actualEvent: TimelineEvent, 
                                           in timeline: [TimelineEvent]) -> [TimelineEvent] {
        // Find the index of the actual event
        guard let actualIndex = timeline.firstIndex(where: { 
            $0.eventType == actualEvent.eventType && 
            $0.status == .actual 
        }) else {
            return timeline
        }
        
        var updatedTimeline = timeline
        
        // For events after the actual event, update their estimated times
        // based on the actual performance
        for i in (actualIndex + 1)..<updatedTimeline.count {
            if updatedTimeline[i].status != .actual {
                // Simple example: shift subsequent events by the same delay
                // You'll want to implement more sophisticated logic
                let timeDifference = actualEvent.actualTime!.timeIntervalSince(actualEvent.scheduledTime)
                updatedTimeline[i].estimatedTime = updatedTimeline[i].scheduledTime.addingTimeInterval(timeDifference)
                updatedTimeline[i].status = .estimated
            }
        }
        
        return updatedTimeline
    }
    
    private func getExistingTimeline(for flightId: UUID) async throws -> [TimelineEvent] {
        // Implement this method to fetch existing timeline from database
        // For now, generate a fresh one
        return try await generateTimeline(for: flightId)
    }
}
```

### Step 6: Create Database Migration

**File**: `Sources/AeroNexus/Migrations/CreateTimelineEvents.swift`

```swift
import Fluent

struct CreateTimelineEvents: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(TimelineEvent.schema)
            .id()
            .field("flight_id", .uuid, .required, .references("flights", "id"))
            .field("event_type", .string, .required)
            .field("scheduled_time", .datetime, .required)
            .field("actual_time", .datetime)
            .field("estimated_time", .datetime)
            .field("location", .string, .required)
            .field("status", .string, .required)
            .field("metadata", .dictionary)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(TimelineEvent.schema).delete()
    }
}
```

### Step 7: Add to Configure

**File**: `Sources/AeroNexus/configure.swift`

Add the migration to the migrations array:
```swift
migrations.add(CreateTimelineEvents())
```

And register the timeline generator service:
```swift
// Add after flight service registration
let timelineGenerator = TimelineGenerator(flightService: flightService)
services.register(timelineGenerator)
```

### Step 8: Add Timeline Endpoints

**File**: `Sources/AeroNexus/Controllers/FlightController.swift`

Add the timeline generator dependency:
```swift
let timelineGenerator: TimelineGenerator

init(timelineGenerator: TimelineGenerator) {
    self.timelineGenerator = timelineGenerator
}
```

Add the timeline endpoint:
```swift
// Add to boot method
flightsGroup.get(":flightId", "timeline") { req async throws -> [TimelineEvent] in
    let flightId = try UUID(req.parameters.get("flightId"))
    return try await self.timelineGenerator.generateTimeline(for: flightId)
}
```

### Step 9: Update Flight Model (if needed)

**File**: `Sources/AeroNexus/Models/Flight.swift`

Add any necessary properties for timeline generation:
```swift
// Add aircraftType if not already present
var aircraftType: String

// Add convenience method
func standardTimelineEvents() -> [TimelineEventType] {
    return [
        .departureGateOpen, .boardingStart, .boardingComplete,
        .pushback, .taxiOut, .takeoff, .climb, .cruise,
        .descent, .landing, .taxiIn, .arrivalGateOpen
    ]
}
```

### Step 10: Add to Routes

**File**: `Sources/AeroNexus/routes.swift`

Ensure the flight controller is properly initialized with the timeline generator:
```swift
let flightController = FlightController(
    flightService: flightService,
    timelineGenerator: timelineGenerator
)
```

## Testing the Implementation

### Unit Tests

Create test file: `Tests/AeroNexusTests/TimelineGeneratorTests.swift`

```swift
import XCTest
@testable import AeroNexus

class TimelineGeneratorTests: XCTestCase {
    
    var flightService: MockFlightService!
    var timelineGenerator: TimelineGenerator!
    var testFlight: Flight!
    
    override func setUp() {
        super.setUp()
        flightService = MockFlightService()
        timelineGenerator = TimelineGenerator(flightService: flightService)
        
        let departureTime = Date().addingTimeInterval(3600) // 1 hour from now
        let arrivalTime = departureTime.addingTimeInterval(7200) // 2 hours later
        
        testFlight = Flight(
            id: UUID(),
            flightNumber: "AA123",
            departureAirport: "JFK",
            arrivalAirport: "LAX",
            scheduledDeparture: departureTime,
            scheduledArrival: arrivalTime,
            aircraftType: "A320"
        )
    }
    
    func testGenerateTimeline() async throws {
        // Mock the flight service
        flightService.mockFlight = testFlight
        
        // Generate timeline
        let timeline = try await timelineGenerator.generateTimeline(for: testFlight.id!)
        
        // Basic assertions
        XCTAssertFalse(timeline.isEmpty, "Timeline should not be empty")
        XCTAssertEqual(timeline.count, 12, "Should have 12 standard events")
        
        // Check chronological order
        for i in 1..<timeline.count {
            XCTAssertLessThanOrEqual(timeline[i-1].scheduledTime, timeline[i].scheduledTime)
        }
        
        // Check required events are present
        let eventTypes = Set(timeline.map { $0.eventType })
        XCTAssertTrue(eventTypes.contains(.departureGateOpen))
        XCTAssertTrue(eventTypes.contains(.takeoff))
        XCTAssertTrue(eventTypes.contains(.landing))
    }
    
    func testTimelineValidation() async throws {
        // Test that invalid timelines are caught
        // You'll need to create test cases that should fail validation
    }
}

class MockFlightService: FlightService {
    var mockFlight: Flight?
    
    func getFlight(_ id: UUID) async throws -> Flight {
        guard let flight = mockFlight else {
            throw Abort(.notFound)
        }
        return flight
    }
    
    // Implement other required methods
}
```

## Implementation Tips

1. **Start Small**: Implement the basic timeline generation first, then add complexity
2. **Test Frequently**: Write tests as you go to ensure each component works
3. **Use Real Data**: Test with actual flight data to ensure realistic timelines
4. **Performance**: Monitor performance, especially with many flights
5. **Error Handling**: Implement comprehensive error handling
6. **Logging**: Add logging for debugging and monitoring
7. **Documentation**: Document each component as you implement it

## Next Steps for Phase 3

Once the basic timeline generator is working, you can expand to:

1. **Real-time Updates**: Integrate with flight update system
2. **Predictive Analytics**: Add machine learning for better estimates
3. **Delay Handling**: Implement sophisticated delay propagation
4. **Visualization**: Create timeline visualization endpoints
5. **Alerts**: Add notification system for timeline changes
6. **Historical Analysis**: Store and analyze past timelines

This implementation guide provides a complete roadmap for building the timeline generator. You can implement it step by step, testing each component as you go.