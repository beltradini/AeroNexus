import Vapor 
import Fluent
import FluentPostgresDriver
import RediStack
import AeroNexusCore

struct AppConfigurator {
    static func configure(_ app: Application) throws {
        // Environment 
        app.logger.logLevel = .info

        // Database - Using PostgreSQL
        let postgresConfig: PostgreSQLConfiguration
        if let host = Environment.get("DATABASE_HOST"),
           let username = Environment.get("DATABASE_USERNAME"),
           let password = Environment.get("DATABASE_PASSWORD"),
           let database = Environment.get("DATABASE_NAME") {
            postgresConfig = PostgreSQLConfiguration(
                hostname: host,
                port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 5432,
                username: username,
                password: password,
                database: database,
                tls: .prefer(try .make(configuration: .clientDefault()))
            )
        } else {
            // Fallback to SQLite for development
            app.logger.warning("Database environment variables not set, using SQLite fallback")
            app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
            return // Skip PostgreSQL configuration
        }
        
        app.databases.use(.postgres(configuration: postgresConfig), as: .psql)

        // Migrations
        app.migrations.add(CreateAircraft())
        app.migrations.add(CreateAirport())
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

        // Redis Configuration
        let redisConfig: RedisConfiguration
        if let redisHost = Environment.get("REDIS_HOST"),
           let redisPort = Environment.get("REDIS_PORT").flatMap(Int.init(_:)) {
            redisConfig = RedisConfiguration(hostname: redisHost, port: redisPort)
        } else {
            redisConfig = RedisConfiguration(hostname: "localhost", port: 6379)
        }
        
        let redis = try RedisClient(configuration: redisConfig, boundEventLoop: app.eventLoopGroup.next())
        let redisService = RedisService(redis: redis, logger: app.logger, eventLoopGroup: app.eventLoopGroup)
        app.storage[RedisServiceKey.self] = redisService

        // Flight State Engine
        let databaseFlightService = DatabaseFlightService(db: app.db)
        let cachedFlightService = CachedFlightService(
            databaseService: databaseFlightService,
            redisService: redisService,
            logger: app.logger
        )
        
        let flightStateEngine = FlightStateEngine(
            redisService: redisService,
            flightService: cachedFlightService,
            logger: app.logger
        )
        app.storage[FlightStateEngineKey.self] = flightStateEngine

        // Timeline Generator with cached service
        let timelineGenerator = TimelineGenerator(flightService: cachedFlightService)
        app.storage[TimelineGeneratorKey.self] = timelineGenerator

        // Middlewares
        app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
        app.middleware.use(ErrorMiddleware.default(environment: app.environment))

        // Register routes
        try routes(app)
    }

    }
}
