import Vapor
import Foundation
import RediStack

public final class FlightStateEngine: @unchecked Sendable {
    private let redisService: RedisService
    private let flightService: any FlightService
    private let logger: Logger

    public init(redisService: RedisService, flightService: any FlightService, logger: Logger) {
        self.redisService = redisService
        self.flightService = flightService
        self.logger = logger
    }

    // Take snapshot of current flight state
    public func takeSnapshot(flightId: UUID) async throws -> FlightStateSnapshot {
        let flight = try await flightService.getFlight(flightId)
        let timeline = try await flightService.getTimeline(for: flightId)
        
        let snapshot = FlightStateSnapshot(
            flightId: flightId,
            flightNumber: flight.number,
            currentStatus: flight.status,
            departureTime: flight.departureAt,
            arrivalTime: flight.arrivalAt,
            timelineEvents: timeline,
            timestamp: Date()
        )
        
        // Cache the snapshot
        try await cacheSnapshot(snapshot)
        
        return snapshot
    }

    private func cacheSnapshot(_ snapshot: FlightStateSnapshot) async throws {
        let key = "flight:snapshot:{\(snapshot.flightId.uuidString)}"
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(snapshot)
        let jsonString = String(data: data, encoding: .utf8) ?? ""
        
        try await redisService.redis.set(jsonString, forKey: key, expiration: .seconds(3600)).get()
        logger.info("Cached flight snapshot: {\(snapshot.flightId.uuidString)}")
    }

    public func getSnapshot(flightId: UUID) async throws -> FlightStateSnapshot? {
        let key = "flight:snapshot:{\(flightId.uuidString)}"
        guard let cached = try await redisService.redis.get(key, as: String.self).get() else {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let data = cached.data(using: .utf8) ?? Data()
        let snapshot = try decoder.decode(FlightStateSnapshot.self, from: data)
        logger.info("Retrieved cached snapshot: {\(flightId.uuidString)}")
        return snapshot
    }

    // Stream flight state updates
    public func streamStateUpdates() -> AsyncStream<FlightStateUpdate> {
        AsyncStream { continuation in
            let pubSub = redisService.subscribeToFlightStateUpdates()
            
            Task {
                do {
                    let channel = "flight:state:updates"
                    let subscription = try await pubSub.subscribe(to: channel).get()
                    
                    for try await message in subscription {
                        if let data = message.payload.string {
                            let decoder = JSONDecoder()
                            if let updateData = try? decoder.decode(FlightStateUpdate.self, from: Data(data.utf8)) {
                                continuation.yield(updateData)
                            }
                        }
                    }
                } catch {
                    logger.error("Error in state streaming: {\(error)}")
                    continuation.finish()
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                Task {
                    try? await pubSub.unsubscribe(from: "flight:state:updates").get()
                }
            }
        }
    }

    // Update flight state and publish
    public func updateFlightState(flightId: UUID, newStatus: String) async throws {
        // Update in database
        var flight = try await flightService.getFlight(flightId)
        flight.status = newStatus
        try await flightService.updateFlight(flight)
        
        // Publish update
        try await redisService.publishFlightStateUpdate(flightId: flightId, state: newStatus)
        
        // Invalidate cache
        try await redisService.invalidateFlightCache(flightId: flightId)
        
        logger.info("Updated flight {\(flightId.uuidString)} state to {\(newStatus)}")
    }
}

// MARK: - Data Models

public struct FlightStateSnapshot: Codable {
    public let flightId: UUID
    public let flightNumber: String
    public let currentStatus: String
    public let departureTime: Date
    public let arrivalTime: Date
    public let timelineEvents: [TimelineEvent]
    public let timestamp: Date
}

public struct FlightStateUpdate: Codable {
    public let flightId: UUID
    public let state: String
    public let timestamp: Date
    
    public init(flightId: UUID, state: String, timestamp: Date = Date()) {
        self.flightId = flightId
        self.state = state
        self.timestamp = timestamp
    }
}