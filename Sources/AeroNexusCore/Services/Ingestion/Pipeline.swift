import Vapor
import Fluent

public enum IngestionError: Error, LocalizedError {
    case providerError(String, any Error)
    case fetchError(String, any Error)
    case allProvidersFailed([any Error])
    
    public var errorDescription: String? {
        switch self {
        case .providerError(let provider, let error):
            return "Provider '\(provider)' processing error: \(error.localizedDescription)"
        case .fetchError(let provider, let error):
            return "Provider '\(provider)' fetch error: \(error.localizedDescription)"
        case .allProvidersFailed(let errors):
            return "All providers failed with \(errors.count) errors"
        }
    }
}

public final class IngestionPipeline: @unchecked Sendable {
    let providers: [any FlightProvider]

    public init(providers: [any FlightProvider]) {
        self.providers = providers
    }

    func ingestAll(req: Request) async throws -> [FlightUpdate] {
        var results: [FlightUpdate] = []
        var errors: [any Error] = []
        
        for provider in providers {
            do {
                let raw = try await provider.fetchUpdates(req: req)
                for p in raw {
                    do {
                        let packet = try provider.normalize(p, req: req)
                        let row = try await persist(packet: packet, req: req)
                        results.append(row)
                    } catch {
                        let providerError = IngestionError.providerError(provider.name, error)
                        req.logger.error("Failed to process packet from provider \(provider.name): \(error)")
                        errors.append(providerError)
                    }
                }
            } catch {
                let fetchError = IngestionError.fetchError(provider.name, error)
                req.logger.error("Failed to fetch updates from provider \(provider.name): \(error)")
                errors.append(fetchError)
            }
        }
        
        if !errors.isEmpty && results.isEmpty {
            throw IngestionError.allProvidersFailed(errors)
        }
        
        return results
    }

    func persist(packet: FlightUpdatePacket, req: Request) async throws -> FlightUpdate {
        // The packet.rawPayload is now a pre-serialized JSON string (or nil),
        // so we can use it directly instead of trying to encode AnyCodable.
        let rawJSON: String = packet.rawPayload ?? "{}"

        var flightID: UUID? = nil
        if let number = packet.flightNumber {
            if let flight = try await Flight.query(on: req.db).filter(\.$number == number).first() {
                flightID = flight.id
            }
        }

        let update = FlightUpdate(
            flightID: flightID,
            flightNumber: packet.flightNumber,
            airportCode: packet.airportCode,
            provider: packet.provider,
            type: packet.type.rawValue,
            status: packet.status,
            departureAt: packet.departureAt,
            arrivalAt: packet.arrivalAt,
            gate: packet.gate,
            rawPayload: rawJSON,
            processed: false)
        
        try await update.save(on: req.db)
        return update
    }
}

