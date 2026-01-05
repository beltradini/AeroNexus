import Vapor
import AeroNexusCore
import Fluent

struct FlightController: RouteCollection {
    let timelineGenerator: TimelineGenerator

    init(timelineGenerator: TimelineGenerator) {
        self.timelineGenerator = timelineGenerator
    }

    func boot(routes: any RoutesBuilder) throws {
        let r = routes.grouped("")
        r.get(use: index)
        r.post(use: create)
        r.get(":flightID", use: get)
        r.put(":flightID", use: update)
        r.delete(":flightID", use: delete)
        r.get(":flightID", "timeline", use: getTimeline)
    }

    func index(req: Request) async throws -> [Flight] {
        try await Flight.query(on: req.db).all()
    }

    func create(req: Request) async throws -> Flight {
        let input = try req.content.decode(FlightCreateData.self)
        let flight = Flight(
            number: input.number,
            origin: input.origin,
            destination: input.destination,
            departureAt: input.departureAt,
            arrivalAt: input.arrivalAt,
            status: input.status ?? "scheduled",
            aircraftType: input.aircraftType,
            scheduledDeparture: input.scheduledDeparture,
            scheduledArrival: input.scheduledArrival,
            departureAirport: input.departureAirport,
            arrivalAirport: input.arrivalAirport
        )
        try await flight.save(on: req.db)
        return flight
    }

    func get(req: Request) async throws -> Flight {
        guard let id = req.parameters.get("flightID", as: UUID.self) else {
            throw Abort(.notFound)
        }
        
        // Use cached flight service if available
        if let flightService = req.application.storage[FlightStateEngineKey.self] {
            return try await flightService.flightService.getFlight(id)
        }
        
        // Fallback to direct database access
        guard let flight = try await Flight.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return flight
    }

    func update(req: Request) async throws -> Flight {
        guard let id = req.parameters.get("flightID", as: UUID.self),
        let flight = try await Flight.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        let input = try req.content.decode(FlightCreateData.self)
        flight.number = input.number
        flight.origin = input.origin
        flight.destination = input.destination
        flight.departureAt = input.departureAt
        flight.arrivalAt = input.arrivalAt
        flight.status = input.status ?? flight.status
        try await flight.save(on: req.db)
        return flight
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("flightID", as: UUID.self),
            let flight = try await Flight.find(id, on: req.db) else {
                throw Abort(.notFound)
            }
        try await flight.delete(on: req.db)
        return .noContent
    }

    func getTimeline(req: Request) async throws -> [TimelineEvent] {
        guard let flightId = req.parameters.get("flightID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid flight ID")
        }
        return try await timelineGenerator.generateTimeline(for: flightId)
    }
}

struct FlightCreateData: Content {
    let number: String
    let origin: String
    let destination: String
    let departureAt: Date
    let arrivalAt: Date
    let status: String?
    let aircraftType: String
    let scheduledDeparture: Date
    let scheduledArrival: Date
    let departureAirport: String
    let arrivalAirport: String
}

struct FlightUpdateData: Content {
    let number: String?
    let origin: String?
    let destination: String?
    let departureAt: Date?
    let arrivalAt: Date?
    let status: String?
}
