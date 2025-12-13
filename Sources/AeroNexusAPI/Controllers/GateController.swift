import Vapor
import AeroNexusCore 
import Fluent

struct GateController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let r = routes.grouped("gates")
        r.get(use: index)
        r.post(use: create)
        r.get(":gateID", use: get)
        r.put(":gateID", use: update)
        r.delete(":gateID", use: delete)
    }

    func index(req: Request) async throws -> [Gate] {
        try await Gate.query(on: req.db).all()
    }

    func create(req: Request) async throws -> Gate {
        let data = try req.content.decode(GateCreateData.self)
        let gate = Gate(identifier: data.identifier, terminal: data.terminal, isAvailable: data.isAvailable ?? true)
        try await gate.save(on: req.db)
        return gate
    }

    func get(req: Request) async throws -> Gate {
        guard let id = req.parameters.get("gateID", as: UUID.self),
              let gate = try await Gate.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return gate
    }

    func update(req: Request) async throws -> Gate {
        guard let id = req.parameters.get("gateID", as: UUID.self),
        let gate = try await Gate.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        let data = try req.content.decode(GateCreateData.self)
        gate.identifier = data.identifier
        gate.terminal = data.terminal
        gate.isAvailable = data.isAvailable ?? gate.isAvailable
        try await gate.save(on: req.db)
        return gate
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("gateID", as: UUID.self),
              let gate = try await Gate.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        try await gate.delete(on: req.db)
        return .noContent
    }
}

struct GateCreateData: Content {
    let identifier: String
    let terminal: String
    let isAvailable: Bool?
}