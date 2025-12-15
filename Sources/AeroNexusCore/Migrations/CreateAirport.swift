import Fluent

struct CreateAirport: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("airports")
            .id()
            .field("iata_code", .string, .required)
            .field("icao_code", .string, .required)
            .field("name", .string, .required)
            .field("city", .string, .required)
            .field("country", .string, .required)
            .field("latitude", .double, .required)
            .field("longitude", .double, .required)
            .field("altitude", .double, .required)
            .field("timezone", .string, .required)
            .field("runways", .int, .required)
            .field("terminals", .int, .required)
            .field("gates", .int, .required)
            .field("status", .string, .required)
            .field("weather_station", .string, .required)
            .unique(on: "iata_code")
            .unique(on: "icao_code")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("airports").delete()
    }
}