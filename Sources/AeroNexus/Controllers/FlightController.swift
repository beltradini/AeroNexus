import Vapor
import Fluent

struct FlightController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let r = routes.grouped("")
        r.get(use: index)
        r.post(use: create)
        r.get(":flightID", use: get)
        r.put(":flightID", use: update)
        r.delete(":flightID", use: delete)
    }

    func index(req: Request) async throws -> [Flight] {
        try await Flight.query(on: req.db).all()
    }

    func create(req: Request) async throws -> Flight {
        let input = try req.content.decode(FlightCreateData.self)
        let flight = Flight(number: input.number, origin: input.origin, destination: input.destination, departureAt: input.departureAt, arrivalAt: input.arrivalAt, status: input.status ?? "scheduled")
        try await flight.save(on: req.db)
        return flight
    }

    func get(req: Request) async throws -> Flight {
        guard let id = req.parameters.get("flightID", as: UUID.self),
            let flight = try await Flight.find(id, on: req.db) else {
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
}

struct FlightCreateData: Content {
    let number: String
    let origin: String
    let destination: String
    let departureAt: Date
    let arrivalAt: Date
    let status: String?
}

struct FlightUpdateData: Content {
    let number: String?
    let origin: String?
    let destination: String?
    let departureAt: Date?
    let arrivalAt: Date?
    let status: String?
}
