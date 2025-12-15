import Vapor
import AeroNexusCore

struct FlightStateController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let r = routes.grouped("flights", "state")
        r.get(":flightID", "snapshot", use: getSnapshot)
        r.post(":flightID", "snapshot", use: takeSnapshot)
        r.post(":flightID", "update", use: updateState)
        r.get("stream", use: streamUpdates)
    }

    func getSnapshot(req: Request) async throws -> FlightStateSnapshot {
        guard let flightId = req.parameters.get("flightID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid flight ID")
        }
        
        guard let stateEngine = req.application.storage[FlightStateEngineKey.self] else {
            throw Abort(.internalServerError, reason: "State engine not configured")
        }
        
        if let snapshot = try await stateEngine.getSnapshot(flightId: flightId) {
            return snapshot
        }
        
        // If no cached snapshot, create one
        return try await stateEngine.takeSnapshot(flightId: flightId)
    }

    func takeSnapshot(req: Request) async throws -> FlightStateSnapshot {
        guard let flightId = req.parameters.get("flightID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid flight ID")
        }
        
        guard let stateEngine = req.application.storage[FlightStateEngineKey.self] else {
            throw Abort(.internalServerError, reason: "State engine not configured")
        }
        
        return try await stateEngine.takeSnapshot(flightId: flightId)
    }

    func updateState(req: Request) async throws -> FlightStateUpdate {
        guard let flightId = req.parameters.get("flightID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid flight ID")
        }
        
        let input = try req.content.decode(StateUpdateInput.self)
        
        guard let stateEngine = req.application.storage[FlightStateEngineKey.self] else {
            throw Abort(.internalServerError, reason: "State engine not configured")
        }
        
        try await stateEngine.updateFlightState(flightId: flightId, newStatus: input.state)
        
        return FlightStateUpdate(flightId: flightId, state: input.state)
    }

    func streamUpdates(req: Request) async throws -> Response {
        guard let stateEngine = req.application.storage[FlightStateEngineKey.self] else {
            throw Abort(.internalServerError, reason: "State engine not configured")
        }
        
        let stream = stateEngine.streamStateUpdates()
        
        return req.eventLoop.makeCompletedFuture {
            var response = Response()
            response.headers = HTTPHeaders([("Content-Type", "text/event-stream"), ("Cache-Control", "no-cache"), ("Connection", "keep-alive")])
            response.status = .ok
            
            response.body = .init(stream: { writer in
                Task {
                    for await update in stream {
                        let data = "data: {\"flightId\": \"{\(update.flightId.uuidString)}\", \"state\": \"{\(update.state)}\", \"timestamp\": \"{\(ISO8601DateFormatter().string(from: update.timestamp))}\"}\n\n"
                        writer.write(.buffer(.init(string: data)))
                        try await Task.sleep(nanoseconds: 100_000_000) // 100ms delay
                    }
                }
                
                return req.eventLoop.makeSucceededFuture(())
            })
            
            return response
        }
    }
}

struct StateUpdateInput: Content {
    let state: String
}