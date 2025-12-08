import Vapor 
import Fluent

struct PassengerController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let r = routes.grouped("")
        r.get(use: index)
        r.post(use: create)
        r.get(":passengerID", use: get)
        r.patch(":passengerID", use: update)
        r.delete(":passengerID", use: delete)
    }

    func index(req: Request) async throws -> [Passenger] {
        try await Passenger.query(on: req.db).all()
    }

    func create(req: Request) async throws -> Passenger {
        let data = try req.content.decode(PassengerCreateData.self)
        let p = Passenger(firstName: data.firstName, lastName: data.lastName, documentNumber: data.documentNumber)
        try await p.save(on: req.db)
        return p
    }

    func get(req: Request) async throws -> Passenger {
        guard let id = req.parameters.get("passengerID", as: UUID.self),
              let passenger = try await Passenger.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return passenger
    }

    func update(req: Request) async throws -> Passenger {
        guard let id = req.parameters.get("passengerID", as: UUID.self),
              let passenger = try await Passenger.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        let data = try req.content.decode(PassengerCreateData.self)
        passenger.firstName = data.firstName
        passenger.lastName = data.lastName
        passenger.documentNumber = data.documentNumber
        try await passenger.save(on: req.db)
        return passenger
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("passengerID", as: UUID.self),
              let passenger = try await Passenger.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        try await passenger.delete(on: req.db)
        return .noContent
    }
}

struct PassengerCreateData: Content {
    let firstName: String
    let lastName: String
    let documentNumber: String
}