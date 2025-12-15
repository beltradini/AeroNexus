# AeroNexus

**Professional Flight & Airport Management API with Real-time Capabilities**

A modern flight tracking and management system built with Swift, Vapor, PostgreSQL, and Redis.

## Features

- **Real-time Flight Tracking**: Monitor flights with live updates
- **Comprehensive Data Model**: Aircraft, airports, flights, bookings, and more
- **Advanced Caching**: Redis-powered caching for high performance
- **State Management**: FlightStateEngine with snapshots and streaming
- **Timeline Generation**: Detailed flight event timelines
- **Modular Architecture**: Clean separation of concerns
- **Docker Support**: Easy deployment with PostgreSQL and Redis

## Architecture

```
┌───────────────────────────────────────────────────────────────┐
│                        AeroNexus Architecture                  │
├─────────────────┬─────────────────┬─────────────────┬─────────────┤
│  AeroNexusCore   │  AeroNexusAPI   │  AeroNexusCLI   │  Database   │
│  (Business Logic)│  (HTTP API)     │  (CLI Tools)    │  (PostgreSQL)│
└─────────────────┴─────────────────┴─────────────────┴─────────────┘
                                      │
                                      ▼
┌───────────────────────────────────────────────────────────────┐
│                            Redis Cache                          │
│  ┌─────────────┐    ┌─────────────┐    ┌───────────────────┐  │
│  │ Flight Cache │    │ Timeline    │    │ State Snapshots   │  │
│  │             │    │ Cache       │    │                   │  │
│  └─────────────┘    └─────────────┘    └───────────────────┘  │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │                 Pub/Sub Channels                       │  │
│  │  ┌─────────────────┐                                    │  │
│  │  │ flight:state:updates                              │  │
│  │  └─────────────────┘                                    │  │
│  └─────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘
```

## Technology Stack

- **Backend**: Swift 6, Vapor 4
- **Database**: PostgreSQL (production), SQLite (development)
- **Cache**: Redis with RediStack
- **API**: RESTful endpoints with JSON
- **Real-time**: Server-Sent Events (SSE)
- **Deployment**: Docker with multi-container setup
- **Containerization**: Docker & Docker Compose
- **Testing**: XCTest with XCTVapor

## API Endpoints

All endpoints are prefixed with `/v1/`:

### Flights
```
GET    /v1/flights              # List all flights
POST   /v1/flights              # Create flight
GET    /v1/flights/:id          # Get flight details
PUT    /v1/flights/:id          # Update flight
DELETE /v1/flights/:id          # Delete flight
GET    /v1/flights/:id/timeline # Get flight timeline
```

### Additional Resources
- Gates: `/v1/gates`
- Passengers: `/v1/passengers`
- Bookings: `/v1/bookings`
- Baggage: `/v1/baggage`

## Quick Start

### Local Development

```bash
# Clone repository
git clone https://github.com/your-username/AeroNexus.git
cd AeroNexus

# Configure database (or use defaults)
export DB_HOST=localhost
export DB_USER=vapor
export DB_PASS=vapor
export DB_NAME=aeronexus

# Build and run
swift build -c release
swift run
```

### Docker Deployment

```bash
# Build and start containers
docker compose build
docker compose up

# Access API at http://localhost:8080/v1/flights
```

## Testing

```bash
swift test
```

## License

**MIT License** © 2024 Alex Beltran

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Key Terms:
- **Free to use**: Anyone can use, modify, and distribute the software
- **Attribution required**: Must include copyright notice in all copies
- **No liability**: Software provided "AS IS" without warranty
- **Open source**: Encourages contribution and community use

### GitHub License Information:
- **License Type**: MIT (Most permissive open source license)
- **SPDX Identifier**: MIT
- **OSI Approved**: Yes
- **GitHub License Template**: Standard MIT License

For more information about open source licensing, visit:
- [GitHub License Guide](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
- [Choose a License](https://choosealicense.com/)

## Contact

Alex Beltran
Lead Developer, AeroNexus
alexbeltrn@icloud.com

---

Professional. Minimal. Production-Ready.
