import Fluent
import Vapor

func routes(_ app: Application) throws {
    let api = app.grouped("v1")

    try api.grouped("flights").register(collection: FlightController())
    try api.grouped("gates").register(collection: GateController())
    try api.grouped("passengers").register(collection: PassengerController())
    try api.grouped("bookings").register(collection: BookingController())
    try api.grouped("baggage").register(collection: BaggageController())
}
