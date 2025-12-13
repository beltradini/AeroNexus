@testable import AeroNexus
import XCTVapor
import Testing
import Fluent
import FluentSQLiteDriver

// Persistence Tests to demonstrate PostgreSQL functionality
final class PersistenceTests: XCTestCase {
    
    func testFullPersistenceWorkflow() throws {
        // Setup with SQLite for testing (PostgreSQL configuration is in main app)
        let app = Application(.testing)
        defer { app.shutdown() }
        
        // Configure SQLite for testing
        app.databases.use(.sqlite(.file("test.db")), as: .sqlite)
        
        // Set up migrations
        app.migrations.add(CreateFlight())
        app.migrations.add(CreatePassenger())
        app.migrations.add(CreateBooking())
        
        try app.autoMigrate().wait()
        
        // Test Flight persistence
        let flight = Flight(
            number: "TEST789",
            origin: "JFK",
            destination: "LAX",
            departureAt: Date(),
            arrivalAt: Date().addingTimeInterval(7200),
            status: "scheduled"
        )
        
        // Create and save flight
        try flight.save(on: app.db).wait()
        
        // Verify flight was saved
        let fetchedFlight = try Flight.query(on: app.db)
            .filter(\.$number == "TEST789")
            .first()
            .wait()
        
        XCTAssertNotNil(fetchedFlight)
        XCTAssertEqual(fetchedFlight?.number, "TEST789")
        XCTAssertEqual(fetchedFlight?.origin, "JFK")
        
        // Test Passenger persistence
        let passenger = Passenger(
            firstName: "John",
            lastName: "Doe",
            documentNumber: "ABC123456"
        )
        
        try passenger.save(on: app.db).wait()
        
        // Verify passenger was saved
        let fetchedPassenger = try Passenger.query(on: app.db)
            .filter(\.$documentNumber == "ABC123456")
            .first()
            .wait()
        
        XCTAssertNotNil(fetchedPassenger)
        XCTAssertEqual(fetchedPassenger?.firstName, "John")
        
        // Test Booking persistence with relationships
        let booking = Booking(
            passengerID: fetchedPassenger!.id!,
            flightID: fetchedFlight!.id!,
            seat: "12A",
            status: "confirmed"
        )
        
        try booking.save(on: app.db).wait()
        
        // Verify booking was saved and relationships work
        let fetchedBooking = try Booking.query(on: app.db)
            .with(\.$flight)
            .with(\.$passenger)
            .filter(\.$id == booking.id!)
            .first()
            .wait()
        
        XCTAssertNotNil(fetchedBooking)
        XCTAssertEqual(fetchedBooking?.seat, "12A")
        XCTAssertEqual(fetchedBooking?.flight.number, "TEST789")
        XCTAssertEqual(fetchedBooking?.passenger.firstName, "John")
        
        // Test update functionality
        fetchedFlight?.status = "boarding"
        try fetchedFlight?.save(on: app.db).wait()
        
        let updatedFlight = try Flight.find(fetchedFlight?.id, on: app.db).wait()
        XCTAssertEqual(updatedFlight?.status, "boarding")
        
        // Test delete functionality
        try fetchedFlight?.delete(on: app.db).wait()
        let deletedFlight = try Flight.find(fetchedFlight?.id, on: app.db).wait()
        XCTAssertNil(deletedFlight)
        
        print("All persistence tests passed!")
    }
    
    func testDatabaseMigrations() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        // Configure SQLite for testing
        app.databases.use(.sqlite(.file("test-migrate.db")), as: .sqlite)
        
        // Set up migrations
        app.migrations.add(CreateFlight())
        
        // Test that all migrations run successfully
        try app.autoMigrate().wait()
        
        // Verify we can create and save a flight (which proves tables exist)
        let testFlight = Flight(
            number: "MIGRATE_TEST",
            origin: "TEST",
            destination: "TEST",
            departureAt: Date(),
            arrivalAt: Date().addingTimeInterval(3600),
            status: "scheduled"
        )
        
        try testFlight.save(on: app.db).wait()
        
        let fetchedTestFlight = try Flight.query(on: app.db)
            .filter(\.$number == "MIGRATE_TEST")
            .first()
            .wait()
        
        XCTAssertNotNil(fetchedTestFlight)
        
        // Clean up
        try fetchedTestFlight?.delete(on: app.db).wait()
        
        print("All database migrations successful!")
    }
}