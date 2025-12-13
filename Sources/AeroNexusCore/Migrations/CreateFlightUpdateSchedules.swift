import Fluent

public struct CreateFlightUpdateSchedules: Migration {
    public func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("flight_update_schedules")
            .id()
            .field("flight_id", .uuid)
            .field("airport_code", .string)
            .field("provider", .string, .required)
            .field("interval_seconds", .int, .required)
            .field("enabled", .bool, .required)
            .field("next_run_at", .datetime)
            .field("created_at", .datetime)
            .create()
    }

    public func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("flight_update_schedules").delete()
    }
}
