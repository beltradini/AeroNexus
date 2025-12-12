import Vapor 
import Fluent
import FluentPostgresDriver

public func configure(_ app: Application) throws {
    // Enviroment 
    app.logger.logLevel = .info

    // Database
    if let url = Environment.get("DATABASE_URL"), var config = PostgresConfiguration(url: url) {
        app.databases.use(.postgres(configuration: config), as: .psql)
    } else {
        app.databases.use(.postgres(
            hostname: Environment.get("DB_HOST") ?? "localhost",
            username: Environment.get("DB_USER") ?? "vapor",
            password: Environment.get("DB_PASS") ?? "vapor",
            database: Environment.get("DB_NAME") ?? "aeronexus"
        ), as: .psql)
    }

    // Migrations
    app.migrations.add(CreateFlight())
    app.migrations.add(CreateFlightUpdates())
    app.migrations.add(CreateFlightUpdateSchedules())
    app.migrations.add(CreateGate())
    app.migrations.add(CreatePassenger())
    app.migrations.add(CreateBooking())
    app.migrations.add(CreateBaggage())
    app.migrations.add(CreateTimelineEvents())

    // Providers
    var providers: [any FlightProvider] = [FakeProvider()]
    if let providersUrlStr = Environment.get("REMOTE_PROVIDER_URL") {
        let uri = URI(string: providersUrlStr)
        providers.append(HTTPProvider(name: "http-provider", baseURL: uri))
    }

    // Ingestion pipeline and scheduler 
    let pipeline = IngestionPipeline(providers: providers)
    app.storage[PipelineKey.self] = pipeline

    let scheduler = SchedulerService(app: app, pipeline: pipeline)
    app.storage[SchedulerKey.self] = scheduler

    // Start scheduler
    scheduler.start()

    // Services
    let flightService = DatabaseFlightService(db: app.db)
    let timelineGenerator = TimelineGenerator(flightService: flightService)
    app.storage[TimelineGeneratorKey.self] = timelineGenerator

    // Middlewares
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))

    // Register routes
    try routes(app)
}

var env = try Environment.detect()
let app = Application(env)
defer { app.shutdown() }

try configure(app)
try app.autoMigrate().wait()
try app.run()