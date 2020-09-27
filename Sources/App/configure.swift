import Fluent
import FluentPostgresDriver
import Vapor

public func configure(_ app: Application) throws {
    
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)
    
    // Add migration
    app.migrations.add(CreateAcronym())
    
    // Set log level
    app.logger.logLevel = .debug
    
    // Attempt to migrate
    try app.autoMigrate().wait()

    // Register routes
    try routes(app)
}
