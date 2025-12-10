import Vapor 

struct FakeProvider: FlightProvider {
    let name = "fake-provider"

    func fetchUpdates(req: Request) async throws -> [Any] {
        let f1: [String: Any] = [
            "flight_number": "AX123",
            "airport": "SFO",
            "type": "statusChange",
            "status": ["status": "delayed", "reason": "weather"],
            "departure_at": ISO8601DateFormatter().string(from: Date().addingTimeInterval(3600)),
        ]
        let f2: [String: Any] = [
            "flight_number": "BX456",
            "airport": "LAX",
            "type": "gateChange",
            "gate": "22B",
        ]
        return [f1, f2]
    }

    func normalize(_ payload: Any, req: Request) throws -> FlightUpdatePacket {
        guard let dict = payload as? [String: Any] else {
            throw Abort(.badRequest)
        }
        let provider = name
        let flightNumber = dict["flight_number"] as? String
        let airport = dict["airport"] as? String
        let raw = dict
        let typeRaw = (dict["type"] as? String) ?? "unknown"
        let type = FlightUpdatePacket.UpdateType(rawValue: typeRaw) ?? .unknown
        let status = (dict["status"] as? [String: Any])?["status"] as? String ?? dict["status"] as? String
        let departureISO = dict["departure_at"] as? String
        let departure = departureISO.flatMap { ISO8601DateFormatter().date(from: $0) }

        let rawJSONData = try JSONSerialization.data(withJSONObject: raw, options: [])
        let rawJSON = String(data: rawJSONData, encoding: .utf8)
        return FlightUpdatePacket(provider: provider,
                      flightNumber: flightNumber,
                      flightId: nil,
                      airportCode: airport,
                      type: type,
                      status: status,
                      departureAt: departure,
                      arrivalAt: nil,
                      gate: dict["gate"] as? String,
                      rawPayload: rawJSON)
    }
}
