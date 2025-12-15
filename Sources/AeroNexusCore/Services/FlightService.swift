import Vapor
import Fluent

public protocol FlightService {
    func getFlight(_ flightId: UUID) async throws -> Flight
    func updateFlight(_ flight: Flight) async throws -> Flight
    func getTimeline(for flightId: UUID) async throws -> [TimelineEvent]
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

    public func updateFlight(_ flight: Flight) async throws -> Flight {
        try await flight.save(on: db)
        return flight
    }

    public func getTimeline(for flightId: UUID) async throws -> [TimelineEvent] {
        return try await TimelineEvent.query(on: db)
            .filter(\TimelineEvent.$flightId == flightId)
            .all()
    }
}

public struct CachedFlightService: FlightService {
    private let databaseService: DatabaseFlightService
    private let redisService: RedisService
    private let logger: Logger

    public init(databaseService: DatabaseFlightService, redisService: RedisService, logger: Logger) {
        self.databaseService = databaseService
        self.redisService = redisService
        self.logger = logger
    }

    public func getFlight(_ flightId: UUID) async throws -> Flight {
        // Try cache first
        if let cachedFlight = try await redisService.getCachedFlight(id: flightId) {
            logger.info("Cache hit for flight \(flightId)")
            return cachedFlight
        }
        
        // Fall back to database
        logger.info("Cache miss for flight \(flightId), fetching from database")
        let flight = try await databaseService.getFlight(flightId)
        
        // Cache the result
        try await redisService.cacheFlight(flight)
        
        return flight
    }

    public func updateFlight(_ flight: Flight) async throws -> Flight {
        let updatedFlight = try await databaseService.updateFlight(flight)
        
        // Update cache
        try await redisService.cacheFlight(updatedFlight)
        
        return updatedFlight
    }

    public func getTimeline(for flightId: UUID) async throws -> [TimelineEvent] {
        // Try cache first
        if let cachedTimeline = try await redisService.getCachedTimeline(for: flightId) {
            logger.info("Cache hit for timeline \(flightId)")
            return cachedTimeline
        }
        
        // Fall back to database
        logger.info("Cache miss for timeline \(flightId), fetching from database")
        let timeline = try await databaseService.getTimeline(for: flightId)
        
        // Cache the result
        try await redisService.cacheTimeline(for: flightId, timeline: timeline)
        
        return timeline
    }
}