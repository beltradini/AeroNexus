import Vapor

struct IngestionController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let r = routes.grouped("ingest")
        r.post("run", use: runNow)
        r.post("schedule", use: createSchedule)
        r.post("schedule", "flight", use: scheduleByFlight)
        r.post("schedule", "airport", use: scheduleByAirport)
    }

    // Run ingestion now for all providers
    func runNow(req: Request) async throws -> [FlightUpdate] {
        guard let pipeline = req.application.storage[PipelineKey.self] else {
            throw Abort(.internalServerError)
        }
        return try await pipeline.ingestAll(req: req)
    }

    func createSchedule(req: Request) async throws -> FlightUpdateSchedule {
        let input = try req.content.decode(ScheduleCreateData.self)
        guard let scheduler = req.application.storage[SchedulerKey.self] else {
            throw Abort(.internalServerError)
        }
        if let flightID = input.flightID {
            return try await scheduler.scheduleByFlight(flightID: flightID, provider: input.provider, intervalSeconds: input.intervalSeconds)
        } else if let airport = input.airport {
            return try await scheduler.scheduleByAirport(airport: airport, provider: input.provider, intervalSeconds: input.intervalSeconds)
        } else {
            throw Abort(.badRequest)
        }
    }

    func scheduleByFlight(req: Request) async throws -> FlightUpdateSchedule {
        let data = try req.content.decode(ScheduleCreateData.self)
        guard let flightID = data.flightID else { throw Abort(.badRequest) }
        guard let scheduler = req.application.storage[SchedulerKey.self] else { throw Abort(.internalServerError) }
        return try await scheduler.scheduleByFlight(flightID: flightID, provider: data.provider, intervalSeconds: data.intervalSeconds)
    }

    func scheduleByAirport(req: Request) async throws -> FlightUpdateSchedule {
        let data = try req.content.decode(ScheduleCreateData.self)
        guard let airport = data.airport else { throw Abort(.badRequest) }
        guard let scheduler = req.application.storage[SchedulerKey.self] else { throw Abort(.internalServerError) }
        return try await scheduler.scheduleByAirport(airport: airport, provider: data.provider, intervalSeconds: data.intervalSeconds)
    }
}

struct ScheduleCreateData: Content {
    var flightID: UUID?
    var airport: String?
    var provider: String
    var intervalSeconds: Int
}
