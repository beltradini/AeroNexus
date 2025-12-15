import Fluent
import Vapor

func routes(_ app: Application) throws {
    let api = app.grouped("v1")

    let timelineGenerator = app.storage[TimelineGeneratorKey.self]!
    try api.grouped("flights").register(collection: FlightController(timelineGenerator: timelineGenerator))
    try api.grouped("flights").register(collection: FlightStateController())
    try api.grouped("gates").register(collection: GateController())
    try api.grouped("passengers").register(collection: PassengerController())
    try api.grouped("bookings").register(collection: BookingController())
    try api.grouped("baggage").register(collection: BaggageController())
    try api.register(collection: IngestionController())
}
