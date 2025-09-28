# Simple Debug Script
Write-Host "🔍 DEBUGGING API ISSUES" -ForegroundColor Red

# Test Gateway
Write-Host "`nTesting Gateway..." -ForegroundColor Blue
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -Method GET
    Write-Host "✅ Gateway OK: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Gateway FAIL: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Auth Service Direct
Write-Host "`nTesting Auth Service Direct..." -ForegroundColor Blue
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/actuator/health" -Method GET
    Write-Host "✅ Auth Service OK: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Auth Service FAIL: $($_.Exception.Message)" -ForegroundColor Red
}

# Test User Service Direct
Write-Host "`nTesting User Service Direct..." -ForegroundColor Blue
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8082/actuator/health" -Method GET
    Write-Host "✅ User Service OK: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ User Service FAIL: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Career Service Direct
Write-Host "`nTesting Career Service Direct..." -ForegroundColor Blue
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8084/actuator/health" -Method GET
    Write-Host "✅ Career Service OK: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Career Service FAIL: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Auth API
Write-Host "`nTesting Auth API..." -ForegroundColor Blue
$loginBody = @{
    email = "test@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "✅ Auth API OK: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Auth API FAIL: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Career API
Write-Host "`nTesting Career API..." -ForegroundColor Blue
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8084/career/1" -Method GET
    Write-Host "✅ Career API OK: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Career API FAIL: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nDebug Complete!" -ForegroundColor Yellow
