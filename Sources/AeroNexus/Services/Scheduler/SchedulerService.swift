import Vapor 
import NIOCore
import NIOConcurrencyHelpers
import Fluent

final class SchedulerService: @unchecked Sendable {
    private var task: RepeatedTask? = nil
    let app: Application 
    let pipeline: IngestionPipeline

    init(app: Application, pipeline: IngestionPipeline) {
        self.app = app
        self.pipeline = pipeline
    }

    func start() {
        let eventLoop = app.eventLoopGroup.next()
        self.task = eventLoop.scheduleRepeatedAsyncTask(initialDelay: .seconds(5), delay: .seconds(5)) { [weak self] _ in
            guard let self = self else {
                return eventLoop.makeSucceededFuture(())
            }
            return self.checkAndRunSchedules()
        }
    }

    func stop() {
        self.task?.cancel()
    }
    
    private func checkAndRunSchedules() -> EventLoopFuture<Void> {
        let evLoop = app.eventLoopGroup.next()
        return FlightUpdateSchedule.query(on: app.db)
            .filter(\.$enabled == true)
            .all()
            .flatMapThrowing { schedules in
                schedules.filter { schedule in
                    if let next = schedule.nextRunAt {
                        return next <= Date()
                    }
                    
                    return true
                }
            }.flatMap { schedules in
                    let ingestionFutures = schedules.map { schedule in
                    Task {
                        let req = Request(application: self.app, on: evLoop)
                        do {
                            let allProviders = self.pipeline.providers.filter { $0.name == schedule.provider }
                            let pipelineForSchedule = IngestionPipeline(providers: allProviders)
                            let updates = try await pipelineForSchedule.ingestAll(req: req)
                            let scheduleId = schedule.id?.uuidString ?? "unknown"
                            req.logger.info("Scheduler triggered \(updates.count) updates for \(scheduleId)")
                            if schedule.intervalSeconds > 0 {
                                schedule.nextRunAt = Date().addingTimeInterval(TimeInterval(schedule.intervalSeconds))
                                try await schedule.save(on: self.app.db)
                            } else {
                                schedule.enabled = false
                                try await schedule.save(on: self.app.db)
                            }
                        } catch {
                            req.logger.error("Scheduler failed with: \(error.localizedDescription)")
                        }
                    }
                }
                return evLoop.makeSucceededFuture(())
            }
    }

    // MARK: Helpers
    // Schedule by flight
    func scheduleByFlight(flightID: UUID, provider: String, intervalSeconds: Int, initialDelay: TimeInterval? = nil) async throws -> FlightUpdateSchedule {
        let nextRun = initialDelay.map { Date().addingTimeInterval($0) }
        let row = FlightUpdateSchedule(flightID: flightID, airportCode: nil, provider: provider, intervalSeconds: intervalSeconds, enabled: true, nextRunAt: nextRun)
        try await row.save(on: app.db)
        return row
    }
    
    // Schedule by airport
    func scheduleByAirport(airport: String, provider: String, intervalSeconds: Int, initialDelay: TimeInterval? = nil) async throws -> FlightUpdateSchedule {
        let nextRun = initialDelay.map { Date().addingTimeInterval($0) }
        let row = FlightUpdateSchedule(flightID: nil, airportCode: airport, provider: provider, intervalSeconds: intervalSeconds, enabled: true, nextRunAt: nextRun)
        try await row.save(on: app.db)
        return row
    }
}

