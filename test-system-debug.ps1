# SYSTEM DEBUG AND FIX SCRIPT
# This script will debug and fix the Interview Microservice ABC system

Write-Host "INTERVIEW MICROSERVICE ABC - SYSTEM DEBUG AND FIX" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# 1. Check if Docker is running
Write-Host "`n1. Checking Docker status..." -ForegroundColor Yellow
try {
    docker --version | Out-Null
    Write-Host "Docker is running" -ForegroundColor Green
} catch {
    Write-Host "Docker is not running. Please start Docker first." -ForegroundColor Red
    exit 1
}

# 2. Stop existing containers
Write-Host "`n2. Stopping existing containers..." -ForegroundColor Yellow
docker-compose down -v

# 3. Clean up and rebuild
Write-Host "`n3. Cleaning up and rebuilding..." -ForegroundColor Yellow
docker system prune -f
docker-compose build --no-cache

# 4. Start services in order
Write-Host "`n4. Starting services in order..." -ForegroundColor Yellow

# Start database first
Write-Host "Starting PostgreSQL..." -ForegroundColor Cyan
docker-compose up -d postgres
Start-Sleep -Seconds 10

# Check database
Write-Host "Checking database connection..." -ForegroundColor Cyan
$dbCheck = docker exec interview-postgres psql -U postgres -c "\l" 2>&1
if ($dbCheck -match "List of databases") {
    Write-Host "Database is running" -ForegroundColor Green
} else {
    Write-Host "Database connection failed" -ForegroundColor Red
    Write-Host $dbCheck
}

# Start Redis
Write-Host "Starting Redis..." -ForegroundColor Cyan
docker-compose up -d redis
Start-Sleep -Seconds 5

# Start Config Service
Write-Host "Starting Config Service..." -ForegroundColor Cyan
docker-compose up -d config-service
Start-Sleep -Seconds 10

# Start Discovery Service
Write-Host "Starting Discovery Service..." -ForegroundColor Cyan
docker-compose up -d discovery-service
Start-Sleep -Seconds 15

# Start Gateway Service
Write-Host "Starting Gateway Service..." -ForegroundColor Cyan
docker-compose up -d gateway-service
Start-Sleep -Seconds 10

# Start Auth Service
Write-Host "Starting Auth Service..." -ForegroundColor Cyan
docker-compose up -d auth-service
Start-Sleep -Seconds 15

# Start User Service
Write-Host "Starting User Service..." -ForegroundColor Cyan
docker-compose up -d user-service
Start-Sleep -Seconds 15

# Start other services
Write-Host "Starting other services..." -ForegroundColor Cyan
docker-compose up -d career-service question-service exam-service news-service nlp-service

# 5. Wait for all services to be ready
Write-Host "`n5. Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# 6. Check service status
Write-Host "`n6. Checking service status..." -ForegroundColor Yellow
docker-compose ps

# 7. Check service logs for errors
Write-Host "`n7. Checking service logs..." -ForegroundColor Yellow

Write-Host "`n--- AUTH SERVICE LOGS ---" -ForegroundColor Cyan
docker-compose logs --tail=20 auth-service

Write-Host "`n--- USER SERVICE LOGS ---" -ForegroundColor Cyan
docker-compose logs --tail=20 user-service

Write-Host "`n--- GATEWAY SERVICE LOGS ---" -ForegroundColor Cyan
docker-compose logs --tail=20 gateway-service

# 8. Test basic connectivity
Write-Host "`n8. Testing basic connectivity..." -ForegroundColor Yellow

# Test Gateway health
Write-Host "Testing Gateway health..." -ForegroundColor Cyan
try {
    $gatewayHealth = Invoke-RestMethod -Uri "http://localhost:8080/actuator/health" -Method GET -TimeoutSec 10
    Write-Host "Gateway is healthy: $($gatewayHealth.status)" -ForegroundColor Green
} catch {
    Write-Host "Gateway health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Auth Service directly
Write-Host "Testing Auth Service directly..." -ForegroundColor Cyan
try {
    $authHealth = Invoke-RestMethod -Uri "http://localhost:8081/actuator/health" -Method GET -TimeoutSec 10
    Write-Host "Auth Service is healthy: $($authHealth.status)" -ForegroundColor Green
} catch {
    Write-Host "Auth Service health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test User Service directly
Write-Host "Testing User Service directly..." -ForegroundColor Cyan
try {
    $userHealth = Invoke-RestMethod -Uri "http://localhost:8082/actuator/health" -Method GET -TimeoutSec 10
    Write-Host "User Service is healthy: $($userHealth.status)" -ForegroundColor Green
} catch {
    Write-Host "User Service health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 9. Test API endpoints
Write-Host "`n9. Testing API endpoints..." -ForegroundColor Yellow

# Test Auth Service registration
Write-Host "Testing Auth Service registration..." -ForegroundColor Cyan
$registerData = @{
    email = "testuser@example.com"
    password = "password123"
    fullName = "Test User"
    roleId = 1
    dateOfBirth = "1995-01-15"
    address = "123 Main Street"
    isStudying = $false
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "http://localhost:8080/auth/register" -Method POST -Body $registerData -ContentType "application/json" -TimeoutSec 10
    Write-Host "Registration successful: $($registerResponse.email)" -ForegroundColor Green
} catch {
    Write-Host "Registration failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
}

# Test Auth Service login
Write-Host "Testing Auth Service login..." -ForegroundColor Cyan
$loginData = @{
    email = "testuser@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/auth/login" -Method POST -Body $loginData -ContentType "application/json" -TimeoutSec 10
    Write-Host "Login successful: $($loginResponse.accessToken.Substring(0, 20))..." -ForegroundColor Green
} catch {
    Write-Host "Login failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
}

Write-Host "`nDEBUG COMPLETE!" -ForegroundColor Green
Write-Host "Check the logs above for any errors and fix them accordingly." -ForegroundColor Yellow