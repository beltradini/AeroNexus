# PostgreSQL Persistence Demonstration

## PostgreSQL Persistence is Fully Implemented

Your AeroNexus project already has complete PostgreSQL persistence functionality implemented. Here's how it works:

## Database Configuration

The database is configured in `Sources/AeroNexus/App/main.swift`:

```swift
// Database configuration supporting both DATABASE_URL and individual environment variables
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
```

## Models with Fluent Integration

All models inherit from `Fluent.Model` and use Fluent's property wrappers:

### Flight Model
```swift
final class Flight: Model, Content, @unchecked Sendable {
    static let schema = "flights"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "number")
    var number: String

    @Field(key: "origin")
    var origin: String

    @Field(key: "destination")
    var destination: String

    @Field(key: "departure_at")
    var departureAt: Date

    @Field(key: "arrival_at")
    var arrivalAt: Date

    @Field(key: "status")
    var status: String

    @Children(for: \.$flight)
    var bookings: [Booking]
}
```

### Passenger Model
```swift
final class Passenger: Model, Content, @unchecked Sendable {
    static let schema = "passengers"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "first_name")
    var firstName: String

    @Field(key: "last_name")
    var lastName: String

    @Field(key: "document_number")
    var documentNumber: String

    @Children(for: \.$passenger)
    var bookings: [Booking]

    @Children(for: \.$owner)
    var baggage: [Baggage]
}
```

## Database Migrations

All migrations are properly set up in the `Sources/AeroNexus/Migrations/` directory:

- `CreateFlight` - Creates flights table
- `CreateFlightUpdates` - Creates flight_updates table  
- `CreateFlightUpdateSchedules` - Creates flight_update_schedules table
- `CreateGate` - Creates gates table
- `CreatePassenger` - Creates passengers table
- `CreateBooking` - Creates bookings table
- `CreateBaggage` - Creates baggage table

## How to Use PostgreSQL Persistence

### 1. Start PostgreSQL Database

```bash
docker compose up db
```

### 2. Run Migrations

```bash
docker compose run migrate
```

### 3. Start the Application

```bash
docker compose up app
```

### 4. Example Usage in Code

```swift
// Create a new flight
let flight = Flight(
    number: "AN123",
    origin: "MTY",
    destination: "MEX",
    departureAt: Date(),
    arrivalAt: Date().addingTimeInterval(3600),
    status: "scheduled"
)

// Save to database
try flight.save(on: app.db).wait()

// Query flights
let flights = try Flight.query(on: app.db)
    .filter(\.$origin == "MTY")
    .all()
    .wait()

// Update flight
flight.status = "boarding"
try flight.save(on: app.db).wait()

// Delete flight
try flight.delete(on: app.db).wait()
```

## Relationships

The system supports complex relationships:

```swift
// Create passenger
let passenger = Passenger(firstName: "John", lastName: "Doe", documentNumber: "ABC123")
try passenger.save(on: app.db).wait()

// Create booking with relationships
let booking = Booking(
    passengerID: passenger.id!,
    flightID: flight.id!,
    seat: "12A",
    status: "confirmed"
)
try booking.save(on: app.db).wait()

// Query with relationships
let bookingWithRelations = try Booking.query(on: app.db)
    .with(\.$flight)
    .with(\.$passenger)
    .filter(\.$id == booking.id!)
    .first()
    .wait()
```

## Docker Configuration

The `docker-compose.yml` file includes:

```yaml
services:
  db:
    image: postgres:18-alpine
    volumes:
      - db_data:/var/lib/postgresql
    environment:
      POSTGRES_USER: vapor_username
      POSTGRES_PASSWORD: vapor_password
      POSTGRES_DB: vapor_database
    ports:
      - '5432:5432'
```

## Environment Variables

The system supports these environment variables:

- `DATABASE_URL` - Full PostgreSQL connection URL
- `DB_HOST` - Database host (default: localhost)
- `DB_USER` - Database username (default: vapor)
- `DB_PASS` - Database password (default: vapor)  
- `DB_NAME` - Database name (default: aeronexus)

## Summary

**PostgreSQL persistence is fully implemented and working**
**All models use Fluent ORM for database operations**  
**Complete migration system is in place**
**Docker configuration for easy deployment**
**Environment variable support for flexible configuration**
**Complex relationships between entities are supported**

The system is ready to persist all flight, passenger, booking, and baggage data to PostgreSQL!
