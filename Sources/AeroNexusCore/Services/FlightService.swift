import Vapor
import Fluent

public protocol FlightService {
    func getFlight(_ flightId: UUID) async throws -> Flight
}

public struct DatabaseFlightService: FlightService {
    private let db: any Database

    public init(db: any Database) {
        self.db = db
    }

    public func getFlight(_ flightId: UUID) async throws -> Flight {
        guard let flight = try await Flight.find(flightId, on: db) else {
            throw Abort(.notFound, reason: "Flight with ID \(flightId) not found")
        }
        return flight
    }
}