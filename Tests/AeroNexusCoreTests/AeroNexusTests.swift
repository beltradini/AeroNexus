@testable import AeroNexus
import XCTVapor
import Testing
import Fluent

// Flights Case Tests
final class FlightTests: XCTestCase {
    func testFlightCRUD() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        try app.autoMigrate().wait()

        let create = FlightCreateData(
            number: "AN123",
            origin: "MTY",
            destination: "MEX",
            departureAt: Date(),
            arrivalAt: Date().addingTimeInterval(3600),
            status: "scheduled"
        )
        try app.test(.POST, "/v1/flights", beforeRequest: { req in
            try req.content.encode(create)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .created)
            let flight = try res.content.decode(Flight.self)
            XCTAssertEqual(flight.number, "AN123")
        })
    }
}
