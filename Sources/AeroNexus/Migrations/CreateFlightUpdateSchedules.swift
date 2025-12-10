import Fluent

struct CreateFlightUpdateSchedules: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("flight_update_schedules")
            .id()
            .field("flight_id", .uuid)
            .field("airport_code", .string)
            .field("provider", .string, .required)
            .field("interval_seconds", .int, .required)
            .field("enabled", .bool, .required, .sql(.default(true)))
            .field("next_run_at", .datetime)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("flight_update_schedules").delete()
    }
}
