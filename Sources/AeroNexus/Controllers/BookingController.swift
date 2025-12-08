import Vapor
import Fluent

struct BookingController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let r = routes.grouped("")
        r.get(use: index)
        r.post(use: create)
        r.get(":bookingID", use: get)
        r.patch(":bookingID", use: update)
        r.delete(":bookingID", use: delete)
    }

    func index(req: Request) async throws -> [Booking] {
        try await Booking.query(on: req.db).all()
    }

    func create(req: Request) async throws -> Booking {
        let data = try req.content.decode(BookingCreateData.self)

        // Basic validation: ensure passenger and flight exist
        guard let _ = try await Passenger.find(data.passengerID, on: req.db) else {
            throw Abort(.badRequest, reason: "Passenger not found")
        }
        guard let _ = try await Flight.find(data.flightID, on: req.db) else {
            throw Abort(.badRequest, reason: "Flight not found")
        }

        let booking = Booking(passengerID: data.passengerID, flightID: data.flightID, seat: data.seat, status: data.status ?? "confirmed")
        try await booking.save(on: req.db)
        return booking
    }

    func get(req: Request) async throws -> Booking {
        guard let id = req.parameters.get("bookingID", as: UUID.self),
              let booking = try await Booking.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return booking
    }

    func update(req: Request) async throws -> Booking {
        guard let id = req.parameters.get("bookingID", as: UUID.self),
              let booking = try await Booking.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        let data = try req.content.decode(BookingCreateData.self)
        booking.seat = data.seat
        booking.status = data.status ?? booking.status
        try await booking.update(on: req.db)
        return booking
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("bookingID", as: UUID.self),
              let booking = try await Booking.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        try await booking.delete(on: req.db)
        return .noContent
    }
}

struct BookingCreateData: Content {
    var passengerID: UUID
    var flightID: UUID
    var seat: String
    var status: String?
}