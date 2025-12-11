import Vapor 

protocol FlightProvider {
    var name: String { get }

    func fetchUpdates(req: Request) async throws -> [Any]

    func normalize(_ payload: Any, req: Request) throws -> FlightUpdatePacket
}

