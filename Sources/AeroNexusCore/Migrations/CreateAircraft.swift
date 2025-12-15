import Fluent

struct CreateAircraft: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("aircrafts")
            .id()
            .field("registration_number", .string, .required)
            .field("manufacturer", .string, .required)
            .field("model", .string, .required)
            .field("type", .string, .required)
            .field("capacity", .int, .required)
            .field("year_built", .int, .required)
            .field("status", .string, .required)
            .field("current_airport", .string, .required)
            .field("last_maintenance", .datetime, .required)
            .field("next_maintenance", .datetime, .required)
            .field("flight_hours", .double, .required)
            .field("airline", .string, .required)
            .unique(on: "registration_number")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("aircrafts").delete()
    }
}