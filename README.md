# AeroNexus — Intelligent Flight & Airport Management API ✈️

AeroNexus is a modern, minimal, production-ready REST API for managing flights, gates, passengers, bookings, and baggage. Built with Swift, Vapor, and Fluent (Postgres), it demonstrates clean API design, database modeling, migrations, and container-friendly deployment — perfect for your backend portfolio.

Key highlights:

- Swift 6 + Vapor 4 web framework
- Fluent ORM with Postgres migrations
- Clear, well-tested route collections (v1 API)
- Docker + Docker Compose for easy local or CI testing

Table of contents
- Features
- Tech & Architecture
- Data models
- API reference (v1)
- Quick start (Local)
- Quick start (Docker)
- Testing
- Contributing
- License

---

## Features ✅

- Full CRUD endpoints for Flights, Gates, Passengers, Bookings and Baggage
- Relations modeled with Fluent: bookings -> flight/passenger, baggage -> owner/flight
- Automatic database migrations at startup (or run separately in Docker)
- Clear request/response payloads, error handling and validation

---

## Tech & Architecture 🔧

- Language: Swift 6
- Web framework: Vapor 4
- Database: PostgreSQL via Fluent
- Containerized builds: Docker (multi-stage) + docker-compose
- Tests: XCTVapor-based test target (AeroNexusTests)

The app boots in `Sources/AeroNexus/App/main.swift`, registers migrations, middleware and the API routes.

---

## Data models (high level)

- Flight — number, origin, destination, departure/arrival dates, status
- Gate — identifier, terminal, availability
- Passenger — firstName, lastName, documentNumber
- Booking — passengerId, flightId, seat, status
- Baggage — tag, ownerId, (optional) flightId, status

See `Sources/AeroNexus/Models/` for full model definitions and migrations.

---

## API Reference — v1

All endpoints are mounted under `/v1`.

Common behavior:
- All endpoints return JSON
- Status codes: 200 for success, 201 on resource creation where applicable, 204 for delete, 404 when missing, 400 for validation errors

### Flights
- GET  /v1/flights — list flights
- POST /v1/flights — create flight
- GET  /v1/flights/:flightID — get a flight
- PUT  /v1/flights/:flightID — replace/update a flight
- DELETE /v1/flights/:flightID — delete a flight

Example create payload:
```json
{
	"number": "AN123",
	"origin": "SFO",
	"destination": "LAX",
	"departureAt": "2026-01-01T14:30:00Z",
	"arrivalAt": "2026-01-01T16:00:00Z",
	"status": "scheduled"
}
```

### Gates
- GET  /v1/gates
- POST /v1/gates
- GET  /v1/gates/:gateID
- PUT  /v1/gates/:gateID
- DELETE /v1/gates/:gateID

### Passengers
- GET  /v1/passengers
- POST /v1/passengers
- GET  /v1/passengers/:passengerID
- PATCH /v1/passengers/:passengerID
- DELETE /v1/passengers/:passengerID

### Bookings
- GET  /v1/bookings
- POST /v1/bookings
- GET  /v1/bookings/:bookingID
- PATCH /v1/bookings/:bookingID
- DELETE /v1/bookings/:bookingID

Booking creation validates that the passenger and flight exist.

Example booking payload:
```json
{
	"passengerID": "<uuid>",
	"flightID": "<uuid>",
	"seat": "12A",
	"status": "confirmed"
}
```

### Baggage
- GET  /v1/baggage
- POST /v1/baggage
- GET  /v1/baggage/:baggageID
- PATCH /v1/baggage/:baggageID
- DELETE /v1/baggage/:baggageID

Baggage creation verifies the `ownerID` belongs to an existing passenger.

Example baggage payload:
```json
{
	"tag": "BG-1001",
	"ownerID": "<uuid>",
	"flightID": "<optional-uuid>",
	"status": "checked_in"
}
```

---

## Quickstart — Local (macOS / Linux)

Prerequisites:
- Swift 6 (recommended) — matches this project's Package.swift
- PostgreSQL server (local) — or set DATABASE_URL

1) Clone the repo
```bash
git clone https://github.com/<your-username>/AeroNexus.git
cd AeroNexus
```

2) Configure environment variables (or rely on defaults)
```bash
export DB_HOST=localhost
export DB_USER=vapor
export DB_PASS=vapor
export DB_NAME=aeronexus
# Or set DATABASE_URL to a full postgres URL
```

3) Build & run
```bash
swift build -c release
swift run
```

The app runs and will automatically execute migrations when it starts.

---

## Quickstart — Docker & Docker Compose

1) Build & run PostgreSQL + app via docker compose
```bash
# Build image
docker compose build

# Start DB and app (app will listen on 8080)
docker compose up --build

# Run migrations separately (if needed)
docker compose run migrate
```

2) Open http://localhost:8080/v1/flights to see endpoints.

---

## Testing

Run tests with:
```bash
swift test
```

See `Tests/AeroNexusTests` for sample test coverage using XCTVapor.

---

## Contributing 🤝

Contributions, ideas and bug reports are welcome — open an issue or a pull request. Some ways to contribute:

- Suggest new features or improvements
- Add unit/integration tests
- Improve API documentation

When submitting a PR, please include tests and a short description of the change.

---

## License

This project is open source — include your preferred license (e.g., MIT) or update to your organization policy.

---

Thanks for checking out AeroNexus — a fast, pragmatic Swift backend for airport and flight operations. If you want, I can also add an OpenAPI/Swagger spec, Postman collection or sample Postgres data to include in the repo.

