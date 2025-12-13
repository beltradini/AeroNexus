@testable import AeroNexus
import XCTest
import Vapor
import AeroNexusCore
import Fluent

final class TimelineTests: XCTestCase {
    func testTimelineEventCreation() throws {
        // Test that TimelineEvent can be created and conforms to Model
        let event = TimelineEvent()
        event.flightId = UUID()
        event.eventType = .boardingStart
        event.scheduledTime = Date()
        event.location = "JFK"
        event.status = .scheduled
        
        XCTAssertNotNil(event)
        // event.id will be nil until saved to database, which is expected for new objects
        XCTAssertEqual(event.eventType, .boardingStart)
        XCTAssertEqual(event.status, .scheduled)
    }

    func testTimelineEventTypes() throws {
        // Test that all expected event types exist
        let allEventTypes: [TimelineEventType] = [
            .departureGateOpen, .boardingStart, .boardingComplete, .pushback, .taxiOut, .takeoff,
            .climb, .cruise, .descent, .landing, .taxiIn, .arrivalGateOpen,
            .baggageClaimStart, .baggageClaimComplete, .custom
        ]
        
        XCTAssertEqual(allEventTypes.count, 15)
        XCTAssertTrue(allEventTypes.contains(.boardingStart))
        XCTAssertTrue(allEventTypes.contains(.takeoff))
    }

    func testTimelineEventStatuses() throws {
        // Test that all expected statuses exist
        let statuses: [TimelineEventStatus] = [.scheduled, .estimated, .actual, .delayed, .cancelled]
        
        XCTAssertEqual(statuses.count, 5)
        XCTAssertTrue(statuses.contains(.scheduled))
        XCTAssertTrue(statuses.contains(.actual))
    }

    func testFlightServiceProtocol() throws {
        // Test that FlightService protocol is properly defined
        struct MockFlightService: FlightService {
            func getFlight(_ flightId: UUID) async throws -> Flight {
                return Flight(number: "TEST123", origin: "JFK", destination: "LAX", departureAt: Date(), arrivalAt: Date())
            }
        }
        
        let mockService = MockFlightService()
        XCTAssertNotNil(mockService)
    }

    func testTimelineGeneratorInitialization() throws {
        // Test that TimelineGenerator can be initialized
        struct MockFlightService: FlightService {
            func getFlight(_ flightId: UUID) async throws -> Flight {
                return Flight(number: "TEST123", origin: "JFK", destination: "LAX", departureAt: Date(), arrivalAt: Date())
            }
        }
        
        let mockService = MockFlightService()
        let generator = TimelineGenerator(flightService: mockService)
        
        XCTAssertNotNil(generator)
    }
}