import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
// This file was a template / legacy configure helper from earlier scaffolding.
// Keeping it for reference, but it is not used by the main application entrypoint.
// Renamed to avoid conflicting symbols. Consider removing this file once you
// are happy with the main `Sources/AeroNexus/App/main.swift` bootstrap.
public func configureLegacy(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    // Note: Todo code was removed (no longer part of phase one). If you need
    // a Todo migration re-add a proper migration to Sources/AeroNexus/Migrations.

    // register routes
    try routes(app)
}
