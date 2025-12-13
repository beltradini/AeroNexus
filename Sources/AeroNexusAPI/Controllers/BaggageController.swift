import Vapor
import AeroNexusCore
import Fluent

struct BaggageController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let r = routes.grouped("")
        r.get(use: index)
        r.post(use: create)
        r.get(":baggageID", use: get)
        r.patch(":baggageID", use: update)
        r.delete(":baggageID", use: delete)
    }

    func index(req: Request) async throws -> [Baggage] {
        try await Baggage.query(on: req.db).all()
    }

    func create(req: Request) async throws -> Baggage {
        let data = try req.content.decode(BaggageCreateData.self)
        guard let _ = try await Passenger.find(data.ownerID, on: req.db) else {
            throw Abort(.badRequest, reason: "Owner not found")
        }
        let bag = Baggage(tag: data.tag, ownerID: data.ownerID, flightID: data.flightID, status: data.status ?? "checked_in")
        try await bag.save(on: req.db)
        return bag
    }

    func get(req: Request) async throws -> Baggage {
        guard let id = req.parameters.get("baggageID", as: UUID.self),
              let bag = try await Baggage.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return bag
    }

    func update(req: Request) async throws -> Baggage {
        guard let id = req.parameters.get("baggageID", as: UUID.self),
              let bag = try await Baggage.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        let data = try req.content.decode(BaggageCreateData.self)
        bag.tag = data.tag
        bag.status = data.status ?? bag.status
        if let flightID = data.flightID { bag.$flight.id = flightID }
        try await bag.update(on: req.db)
        return bag
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("baggageID", as: UUID.self),
              let bag = try await Baggage.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        try await bag.delete(on: req.db)
        return .noContent
    }
}

struct BaggageCreateData: Content {
    var tag: String
    var ownerID: UUID
    var flightID: UUID?
    var status: String?
}
