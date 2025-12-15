import RediStack
import Vapor
import Logging

public final class RedisService: @unchecked Sendable {
    private let redis: RedisClient
    private let logger: Logger
    private let eventLoopGroup: any EventLoopGroup

    public init(redis: RedisClient, logger: Logger, eventLoopGroup: any EventLoopGroup) {
        self.redis = redis
        self.logger = logger
        self.eventLoopGroup = eventLoopGroup
    }

    // Cache for flights
    public func cacheFlight(_ flight: Flight) async throws {
        let key = "flight:cache:flight:{"flight.id?.uuidString ?? flight.number}"
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(flight)
        let jsonString = String(data: data, encoding: .utf8) ?? ""
        
        try await redis.set(jsonString, forKey: key, expiration: .seconds(300)).get()
        logger.info("Cached flight: {\(flight.id?.uuidString ?? flight.number)}")
    }

    public func getCachedFlight(id: UUID) async throws -> Flight? {
        let key = "flight:cache:flight:{\(id.uuidString)}"
        guard let cached = try await redis.get(key, as: String.self).get() else {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let data = cached.data(using: .utf8) ?? Data()
        let flight = try decoder.decode(Flight.self, from: data)
        logger.info("Retrieved cached flight: {\(id.uuidString)}")
        return flight
    }

    public func cacheTimeline(for flightId: UUID, timeline: [TimelineEvent]) async throws {
        let key = "flight:cache:timeline:{\(flightId.uuidString)}"
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(timeline)
        let jsonString = String(data: data, encoding: .utf8) ?? ""
        
        try await redis.set(jsonString, forKey: key, expiration: .seconds(60)).get()
        logger.info("Cached timeline for flight: {\(flightId.uuidString)}")
    }

    public func getCachedTimeline(for flightId: UUID) async throws -> [TimelineEvent]? {
        let key = "flight:cache:timeline:{\(flightId.uuidString)}"
        guard let cached = try await redis.get(key, as: String.self).get() else {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let data = cached.data(using: .utf8) ?? Data()
        let timeline = try decoder.decode([TimelineEvent].self, from: data)
        logger.info("Retrieved cached timeline for flight: {\(flightId.uuidString)}")
        return timeline
    }

    // Flight state streaming
    public func publishFlightStateUpdate(flightId: UUID, state: String) async throws {
        let channel = "flight:state:updates"
        let message = "{\"flightId\": \"{\(flightId.uuidString)}\", \"state\": \"{\(state)}\"}"
        try await redis.publish(message, to: channel).get()
        logger.info("Published state update for flight {\(flightId.uuidString)}: {\(state)}")
    }

    public func subscribeToFlightStateUpdates() -> RedisPubSub {
        return redis.pubSub
    }

    // Cache invalidation
    public func invalidateFlightCache(flightId: UUID) async throws {
        let flightKey = "flight:cache:flight:{\(flightId.uuidString)}"
        let timelineKey = "flight:cache:timeline:{\(flightId.uuidString)}"
        
        try await redis.delete([flightKey, timelineKey]).get()
        logger.info("Invalidated cache for flight: {\(flightId.uuidString)}")
    }
}