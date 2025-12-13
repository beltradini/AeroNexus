import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor

// configures your application
// This file was a template / legacy configure helper from earlier scaffolding.
// Keeping it for reference, but it is not used by the main application entrypoint.
// Renamed to avoid conflicting symbols. Consider removing this file once you
// are happy with the main `Sources/AeroNexus/App/main.swift` bootstrap.
public func configureLegacy(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Use SQLite instead of PostgreSQL
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    // Note: Todo code was removed (no longer part of phase one). If you need
    // a Todo migration re-add a proper migration to Sources/AeroNexus/Migrations.

    // register routes
    try routes(app)
}
