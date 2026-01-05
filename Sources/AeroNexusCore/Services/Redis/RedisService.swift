@preconcurrency import RediStack
import Vapor
import Logging

public enum RedisError: Error, LocalizedError {
    case cacheFailed(String, any Error)
    case connectionFailed(any Error)
    case operationFailed(String, any Error)
    
    public var errorDescription: String? {
        switch self {
        case .cacheFailed(let key, let error):
            return "Cache operation failed for key '\(key)': \(error.localizedDescription)"
        case .connectionFailed(let error):
            return "Redis connection failed: \(error.localizedDescription)"
        case .operationFailed(let operation, let error):
            return "Redis operation '\(operation)' failed: \(error.localizedDescription)"
        }
    }
}

public final class RedisService: @unchecked Sendable {
    private let redis: any RedisClient
    private let logger: Logger
    private let eventLoopGroup: any EventLoopGroup

    public init(redis: any RedisClient, logger: Logger, eventLoopGroup: any EventLoopGroup) {
        self.redis = redis
        self.logger = logger
        self.eventLoopGroup = eventLoopGroup
    }

    // Cache for flights
    public func cacheFlight(_ flight: Flight) async throws {
        let key = RedisKey("flight:cache:flight:\(flight.id?.uuidString ?? flight.number)")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(flight)
        let jsonString = String(data: data, encoding: .utf8) ?? ""
        
        do {
            try await redis.set(RedisValue(bulkString: jsonString), to: key, onCondition: .none, expiration: .seconds(300)).get()
            logger.info("Cached flight: \(flight.id?.uuidString ?? flight.number)")
        } catch {
            logger.error("Failed to cache flight \(flight.id?.uuidString ?? flight.number): \(error)")
            throw RedisError.cacheFailed(key.description, error)
        }
    }

    public func getCachedFlight(id: UUID) async throws -> Flight? {
        let key = RedisKey("flight:cache:flight:\(id.uuidString)")
        let cached = try await redis.get(key).get()
        
        switch cached {
        case .null:
            return nil
        case .simpleString(let buffer):
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let data = Data(buffer: buffer)
            let flight = try decoder.decode(Flight.self, from: data)
            logger.info("Retrieved cached flight: \(id.uuidString)")
            return flight
        default:
            throw RedisError.operationFailed("getCachedFlight", RedisError.connectionFailed(NSError(domain: "Redis", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected Redis response type"])))
        }
    }

    public func cacheTimeline(for flightId: UUID, timeline: [TimelineEvent]) async throws {
        let key = RedisKey("flight:cache:timeline:\(flightId.uuidString)")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(timeline)
        let jsonString = String(data: data, encoding: .utf8) ?? ""
        
        do {
            try await redis.set(jsonString, to: key, expiration: .seconds(60), onCondition: .none).get()
            logger.info("Cached timeline for flight: \(flightId.uuidString)")
        } catch {
            logger.error("Failed to cache timeline for flight \(flightId.uuidString): \(error)")
            throw RedisError.cacheFailed(key.description, error)
        }
    }

    public func getCachedTimeline(for flightId: UUID) async throws -> [TimelineEvent]? {
        let key = RedisKey("flight:cache:timeline:\(flightId.uuidString)")
        let cached = try await redis.get(key).get()
        
        switch cached {
        case .null:
            return nil
        case .simpleString(let buffer):
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let data = Data(buffer: buffer)
            let timeline = try decoder.decode([TimelineEvent].self, from: data)
            logger.info("Retrieved cached timeline for flight: \(flightId.uuidString)")
            return timeline
        default:
            throw RedisError.operationFailed("getCachedTimeline", RedisError.connectionFailed(NSError(domain: "Redis", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected Redis response type"])))
        }
    }

    // Flight state streaming
    public func publishFlightStateUpdate(flightId: UUID, state: String) async throws {
        let channel = RedisChannelName("flight:state:updates")
        let message = "{\"flightId\": \"\(flightId.uuidString)\", \"state\": \"\(state)\"}"
        _ = try await redis.publish(message, to: channel).get()
        logger.info("Published state update for flight \(flightId.uuidString): \(state)")
    }

    public func subscribeToFlightStateUpdates() -> RedisPubSub {
        return redis.pubSub
    }

    // Cache invalidation
    public func invalidateFlightCache(flightId: UUID) async throws {
        let flightKey = RedisKey("flight:cache:flight:\(flightId.uuidString)")
        let timelineKey = RedisKey("flight:cache:timeline:\(flightId.uuidString)")
        
        _ = try await redis.delete(flightKey, timelineKey).get()
        logger.info("Invalidated cache for flight: \(flightId.uuidString)")
    }
}