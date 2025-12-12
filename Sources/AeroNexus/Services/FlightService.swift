import Vapor
import Fluent

protocol FlightService {
    func getFlight(_ flightId: UUID) async throws -> Flight
}

struct DatabaseFlightService: FlightService {
    private let db: any Database

    init(db: any Database) {
        self.db = db
    }

    func getFlight(_ flightId: UUID) async throws -> Flight {
        guard let flight = try await Flight.find(flightId, on: db) else {
            throw Abort(.notFound, reason: "Flight with ID \(flightId) not found")
        }
        return flight
    }
}