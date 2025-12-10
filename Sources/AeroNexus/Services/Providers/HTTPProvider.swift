import Vapor

struct HTTPProvider: FlightProvider {
    let name: String
    let baseURL: URI
    init(name: String, baseURL: URI) {
        self.name = name
        self.baseURL = baseURL
    }

    func fetchUpdates(req: Request) async throws -> [Any] {
        let response = try await req.client.get("\(baseURL)")
        guard response.status == .ok else { return [] }
        // Attempt to parse the response body as generic JSON
        if var body = response.body, let data = body.readData(length: body.readableBytes) {
            let json = try JSONSerialization.jsonObject(with: data)
            if let arr = json as? [Any] {
                return arr
            } else if let obj = json as? [String: Any] {
                return [obj]
            }
        }
        return []
    }

    func normalize(_ payload: Any, req: Request) throws -> FlightUpdatePacket {
        // Implement mapping from provider-specific payloads into FlightUpdatePacket
        // This is a minimal skeleton — you’ll adapt this to provider schema
        if let dict = payload as? [String: Any] {
            let fn = dict["flight"] as? String ?? dict["flight_number"] as? String
            let rawJSONData = try JSONSerialization.data(withJSONObject: dict, options: [])
            let rawJSON = String(data: rawJSONData, encoding: .utf8)
            return FlightUpdatePacket(provider: name,
                                     flightNumber: fn,
                                     flightID: nil,
                                     airportCode: dict["airport"] as? String,
                                     type: .unknown,
                                     status: dict["status"] as? String,
                                     departureAt: nil,
                                     arrivalAt: nil,
                                     gate: dict["gate"] as? String,
                                     rawPayload: rawJSON)
        }
        throw Abort(.badRequest)
    }
}

