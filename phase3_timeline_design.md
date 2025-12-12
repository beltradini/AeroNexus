# Phase 3: Timeline Generator Design

## Overview
The timeline generator will create detailed flight timelines that can be used for predictions, monitoring, and operational planning. This system will integrate with the existing flight data and provide a foundation for predictive analytics.

## Architecture Components

### 1. Timeline Generator Service

**Location**: `Sources/AeroNexus/Services/Timeline/`

**Key Files**:
- `TimelineGenerator.swift` - Main generator logic
- `TimelineEvent.swift` - Event model
- `TimelineCalculator.swift` - Time calculations
- `TimelineValidator.swift` - Validation logic

### 2. Core Data Models

#### TimelineEvent Model
```swift
struct TimelineEvent: Codable {
    let id: UUID
    let flightId: UUID
    let eventType: TimelineEventType
    let scheduledTime: Date
    let actualTime: Date?
    let estimatedTime: Date?
    let location: String
    let status: TimelineEventStatus
    let metadata: [String: Any]?
}

enum TimelineEventType: String, Codable {
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
```

### 3. Generator Logic

#### TimelineGenerator Class
```swift
class TimelineGenerator {
    
    // Dependencies
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
        
        // 2. Generate standard events
        let standardEvents = generateStandardEvents(for: flight)
        
        // 3. Add custom events if any
        let customEvents = generateCustomEvents(for: flight)
        
        // 4. Combine and sort
        let allEvents = (standardEvents + customEvents).sorted { 
            $0.scheduledTime < $1.scheduledTime 
        }
        
        // 5. Validate timeline
        try validator.validate(timeline: allEvents, for: flight)
        
        return allEvents
    }
    
    private func generateStandardEvents(for flight: Flight) -> [TimelineEvent] {
        // Implementation will use calculator to determine times
        // based on flight schedule, aircraft type, airport procedures, etc.
    }
    
    private func generateCustomEvents(for flight: Flight) -> [TimelineEvent] {
        // Implementation for any flight-specific custom events
    }
}
```

### 4. Timeline Calculator

```swift
class TimelineCalculator {
    
    /// Calculate event times based on flight parameters
    func calculateEventTimes(for flight: Flight) -> [TimelineEventType: Date] {
        // Base calculation logic:
        // 1. Start with scheduled departure/arrival times
        // 2. Apply standard durations for each phase
        // 3. Adjust for airport-specific procedures
        // 4. Factor in aircraft type performance
        
        var eventTimes: [TimelineEventType: Date] = [:]
        
        // Example calculation for departure gate open
        let departureGateOpenTime = flight.scheduledDeparture.addingTimeInterval(-standardBoardingDuration)
        eventTimes[.departureGateOpen] = departureGateOpenTime
        
        // Continue with other events...
        
        return eventTimes
    }
    
    /// Standard durations for different aircraft types
    private func standardBoardingDuration(for aircraftType: String) -> TimeInterval {
        // Return appropriate duration based on aircraft size
    }
    
    /// Airport-specific adjustments
    private func airportProcedureAdjustments(for airportCode: String, eventType: TimelineEventType) -> TimeInterval {
        // Return time adjustments based on airport procedures
    }
}
```

### 5. Timeline Validator

```swift
class TimelineValidator {
    
    func validate(timeline: [TimelineEvent], for flight: Flight) throws {
        // 1. Check chronological order
        try validateChronologicalOrder(timeline)
        
        // 2. Check required events are present
        try validateRequiredEvents(timeline)
        
        // 3. Check time constraints
        try validateTimeConstraints(timeline, flight: flight)
        
        // 4. Check airport-specific rules
        try validateAirportRules(timeline, flight: flight)
    }
    
    private func validateChronologicalOrder(_ timeline: [TimelineEvent]) throws {
        // Ensure events are in proper sequence
    }
    
    private func validateRequiredEvents(_ timeline: [TimelineEvent]) throws {
        // Ensure all required events are present
    }
    
    private func validateTimeConstraints(_ timeline: [TimelineEvent], flight: Flight) throws {
        // Ensure times are within reasonable bounds
    }
    
    private func validateAirportRules(_ timeline: [TimelineEvent], flight: Flight) throws {
        // Validate against airport-specific operational rules
    }
}
```

## Integration Points

### 1. Flight Controller Integration

Add to `FlightController.swift`:
```swift
// Add timeline generator dependency
let timelineGenerator: TimelineGenerator

// Add endpoint
app.get("flights", ":flightId", "timeline") { req async throws -> [TimelineEvent] in
    let flightId = try UUID(req.parameters.get("flightId"))
    return try await timelineGenerator.generateTimeline(for: flightId)
}
```

### 2. Flight Model Extension

Extend `Flight.swift` to include timeline-related properties:
```swift
extension Flight {
    func standardTimelineEvents() -> [TimelineEventType] {
        // Return the standard set of events for this flight type
    }
}
```

### 3. Database Integration

Create migration for timeline events:
```swift
// CreateTimelineEvents.swift in Migrations/
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
            .field("metadata", .json)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(TimelineEvent.schema).delete()
    }
}
```

## Implementation Phases

### Phase 1: Basic Timeline Generation
- Implement core TimelineGenerator class
- Create standard event generation
- Basic calculator with fixed durations
- Simple validation

### Phase 2: Advanced Calculations
- Airport-specific procedure adjustments
- Aircraft type performance factors
- Historical data integration for better estimates
- Weather impact calculations

### Phase 3: Real-time Updates
- Integration with flight update system
- Real-time event tracking
- Predictive adjustments based on live data
- Delay propagation logic

### Phase 4: Machine Learning Integration
- Predictive models for event timing
- Anomaly detection
- Pattern recognition for improved estimates
- Continuous learning from actual vs predicted

## Key Algorithms

### 1. Event Time Calculation
```
function calculateEventTimes(departureTime, arrivalTime, aircraftType, airports):
    baseTimeline = getStandardTimelineTemplate(aircraftType)
    
    // Adjust for specific airports
    departureAdjustments = getAirportAdjustments(airports.departure)
    arrivalAdjustments = getAirportAdjustments(airports.arrival)
    
    // Calculate each event time
    timeline = []
    currentTime = departureTime
    
    for event in baseTimeline.events:
        duration = event.standardDuration + 
                  departureAdjustments[event.type] + 
                  arrivalAdjustments[event.type]
        
        eventTime = currentTime + duration
        timeline.append({type: event.type, time: eventTime})
        currentTime = eventTime
    
    return timeline
```

### 2. Delay Propagation
```
function propagateDelays(timeline, delayedEvent, delayDuration):
    delayedIndex = findEventIndex(timeline, delayedEvent)
    
    for i from delayedIndex to timeline.length:
        if shouldPropagateDelay(timeline[i]):
            timeline[i].estimatedTime += delayDuration
            timeline[i].status = .delayed
        else:
            break  // Stop propagation at certain events
    
    return timeline
```

### 3. Real-time Adjustment
```
function adjustTimelineWithRealData(timeline, actualEvent):
    actualIndex = findEventIndex(timeline, actualEvent)
    
    // Update current event
    timeline[actualIndex].actualTime = actualEvent.time
    timeline[actualIndex].status = .actual
    
    // Recalculate subsequent events based on actual performance
    for i from actualIndex+1 to timeline.length:
        if timeline[i].status != .actual:
            timeline[i].estimatedTime = recalculateBasedOnActuals(timeline, i)
            timeline[i].status = .estimated
    
    return timeline
```

## Data Flow

```
1. Request comes in for flight timeline
2. FlightController receives request
3. TimelineGenerator fetches flight data
4. TimelineCalculator computes event times
5. TimelineValidator ensures quality
6. Timeline is returned to client
7. (Optional) Timeline is stored in database
```

## Error Handling

- **InvalidFlightError**: When flight doesn't exist
- **TimelineGenerationError**: When timeline cannot be generated
- **ValidationError**: When timeline fails validation
- **DataInconsistencyError**: When flight data is inconsistent

## Testing Strategy

1. **Unit Tests**: Test individual components in isolation
2. **Integration Tests**: Test complete timeline generation flow
3. **Edge Case Tests**: Test with unusual flight scenarios
4. **Performance Tests**: Ensure generation is fast enough
5. **Validation Tests**: Ensure all validation rules work correctly

## Future Enhancements

1. **Machine Learning Integration**: Use historical data to improve predictions
2. **External Data Sources**: Integrate with weather, ATC, and other systems
3. **What-if Scenarios**: Allow simulation of different conditions
4. **Multi-flight Coordination**: Handle dependencies between flights
5. **Resource Optimization**: Suggest optimal resource allocation

This design provides a comprehensive foundation for the timeline generator that you can implement step by step. The architecture is modular, allowing for gradual enhancement as you move through Phase 3.