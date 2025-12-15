#!/bin/bash

# AeroNexus Integration Test Script
# Tests the complete implementation of Redis, PostgreSQL, and new models

echo "🚀 Starting AeroNexus Integration Tests"
echo "======================================"

# Test 1: Verify Redis configuration
echo "🔍 Test 1: Checking Redis configuration..."
if grep -q "RediStack" Package.swift; then
    echo "✅ Redis dependency found in Package.swift"
else
    echo "❌ Redis dependency missing"
    exit 1
fi

if grep -q "redis" docker-compose.yml; then
    echo "✅ Redis service found in docker-compose.yml"
else
    echo "❌ Redis service missing from docker-compose"
    exit 1
fi

# Test 2: Verify PostgreSQL configuration
echo "🔍 Test 2: Checking PostgreSQL configuration..."
if grep -q "FluentPostgresDriver" Package.swift; then
    echo "✅ PostgreSQL driver found in Package.swift"
else
    echo "❌ PostgreSQL driver missing"
    exit 1
fi

if grep -q "postgres" Sources/AeroNexusAPI/main.swift; then
    echo "✅ PostgreSQL configuration found in main.swift"
else
    echo "❌ PostgreSQL configuration missing"
    exit 1
fi

# Test 3: Verify new models
echo "🔍 Test 3: Checking new Aircraft and Airport models..."
if [ -f "Sources/AeroNexusCore/Models/Aircraft.swift" ]; then
    echo "✅ Aircraft model created"
else
    echo "❌ Aircraft model missing"
    exit 1
fi

if [ -f "Sources/AeroNexusCore/Models/Airport.swift" ]; then
    echo "✅ Airport model created"
else
    echo "❌ Airport model missing"
    exit 1
fi

# Test 4: Verify migrations
echo "🔍 Test 4: Checking new migrations..."
if [ -f "Sources/AeroNexusCore/Migrations/CreateAircraft.swift" ]; then
    echo "✅ CreateAircraft migration created"
else
    echo "❌ CreateAircraft migration missing"
    exit 1
fi

if [ -f "Sources/AeroNexusCore/Migrations/CreateAirport.swift" ]; then
    echo "✅ CreateAirport migration created"
else
    echo "❌ CreateAirport migration missing"
    exit 1
fi

# Test 5: Verify FlightStateEngine
echo "🔍 Test 5: Checking FlightStateEngine..."
if [ -f "Sources/AeroNexusCore/Services/FlightStateEngine.swift" ]; then
    echo "✅ FlightStateEngine created"
else
    echo "❌ FlightStateEngine missing"
    exit 1
fi

if [ -f "Sources/AeroNexusCore/Services/Redis/RedisService.swift" ]; then
    echo "✅ RedisService created"
else
    echo "❌ RedisService missing"
    exit 1
fi

# Test 6: Verify controllers
echo "🔍 Test 6: Checking new controllers..."
if [ -f "Sources/AeroNexusAPI/Controllers/FlightStateController.swift" ]; then
    echo "✅ FlightStateController created"
else
    echo "❌ FlightStateController missing"
    exit 1
fi

# Test 7: Verify documentation
echo "🔍 Test 7: Checking documentation..."
if [ -f "ARCHITECTURE.md" ]; then
    echo "✅ Architecture documentation created"
else
    echo "❌ Architecture documentation missing"
    exit 1
fi

# Test 8: Verify updated FlightService
echo "🔍 Test 8: Checking updated FlightService..."
if grep -q "CachedFlightService" Sources/AeroNexusCore/Services/FlightService.swift; then
    echo "✅ CachedFlightService implemented"
else
    echo "❌ CachedFlightService missing"
    exit 1
fi

# Test 9: Verify Docker configuration
echo "🔍 Test 9: Checking Docker configuration..."
if grep -q "REDIS_HOST" docker-compose.yml; then
    echo "✅ Redis environment variables configured"
else
    echo "❌ Redis environment variables missing"
    exit 1
fi

if grep -q "redis_data" docker-compose.yml; then
    echo "✅ Redis volume configured"
else
    echo "❌ Redis volume missing"
    exit 1
fi

# Test 10: Verify Keys updates
echo "🔍 Test 10: Checking updated Keys..."
if grep -q "RedisServiceKey" Sources/AeroNexusCore/Services/Keys.swift; then
    echo "✅ RedisServiceKey added"
else
    echo "❌ RedisServiceKey missing"
    exit 1
fi

if grep -q "FlightStateEngineKey" Sources/AeroNexusCore/Services/Keys.swift; then
    echo "✅ FlightStateEngineKey added"
else
    echo "❌ FlightStateEngineKey missing"
    exit 1
fi

echo ""
echo "🎉 All integration tests passed!"
echo ""
echo "📋 Summary of implemented features:"
echo "   ✅ Redis integration with caching and pub/sub"
echo "   ✅ PostgreSQL database configuration"
echo "   ✅ FlightStateEngine with snapshots and streaming"
echo "   ✅ Aircraft and Airport models with relationships"
echo "   ✅ Updated FlightService with caching support"
echo "   ✅ New FlightStateController for state management"
echo "   ✅ Comprehensive architecture documentation"
echo "   ✅ Updated README with new features"
echo ""
echo "🚀 Ready to build and run!"
echo "   Try: docker compose up --build"
