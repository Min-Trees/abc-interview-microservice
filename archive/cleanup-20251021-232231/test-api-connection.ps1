# Test API Connection Script
# Kiểm tra kết nối API và khắc phục lỗi "Socket Hang Up"

Write-Host "🔍 Testing API Connection..." -ForegroundColor Green

# 1. Test Gateway Health
Write-Host "`n1. Testing Gateway Health..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -Method GET -TimeoutSec 30
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Gateway is healthy" -ForegroundColor Green
    } else {
        Write-Host "❌ Gateway health check failed: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Gateway connection failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 2. Test Auth Service
Write-Host "`n2. Testing Auth Service..." -ForegroundColor Yellow
try {
    $loginBody = @{
        email = "admin@example.com"
        password = "123456"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost:8080/auth/login" -Method POST -Body $loginBody -ContentType "application/json" -TimeoutSec 30
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Auth Service is working" -ForegroundColor Green
        $token = ($response.Content | ConvertFrom-Json).accessToken
        Write-Host "🔑 Token received: $($token.Substring(0, 20))..." -ForegroundColor Cyan
    } else {
        Write-Host "❌ Auth Service failed: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Auth Service connection failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Test Question Service
Write-Host "`n3. Testing Question Service..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/questions/fields" -Method GET -TimeoutSec 30
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Question Service is working" -ForegroundColor Green
    } else {
        Write-Host "❌ Question Service failed: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Question Service connection failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. Test User Service
Write-Host "`n4. Testing User Service..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/users" -Method GET -TimeoutSec 30
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ User Service is working" -ForegroundColor Green
    } else {
        Write-Host "❌ User Service failed: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ User Service connection failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. Test Direct Service Access
Write-Host "`n5. Testing Direct Service Access..." -ForegroundColor Yellow

# Test Auth Service directly
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/actuator/health" -Method GET -TimeoutSec 30
    Write-Host "✅ Auth Service direct access: OK" -ForegroundColor Green
} catch {
    Write-Host "❌ Auth Service direct access failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Question Service directly
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8085/actuator/health" -Method GET -TimeoutSec 30
    Write-Host "✅ Question Service direct access: OK" -ForegroundColor Green
} catch {
    Write-Host "❌ Question Service direct access failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test User Service directly
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8082/actuator/health" -Method GET -TimeoutSec 30
    Write-Host "✅ User Service direct access: OK" -ForegroundColor Green
} catch {
    Write-Host "❌ User Service direct access failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 6. Check Docker Services
Write-Host "`n6. Checking Docker Services..." -ForegroundColor Yellow
$containers = docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host $containers

# 7. Check Ports
Write-Host "`n7. Checking Ports..." -ForegroundColor Yellow
$ports = @(8080, 8081, 8082, 8085)
foreach ($port in $ports) {
    $connection = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue
    if ($connection.TcpTestSucceeded) {
        Write-Host "✅ Port $port is open" -ForegroundColor Green
    } else {
        Write-Host "❌ Port $port is closed" -ForegroundColor Red
    }
}

Write-Host "`n🎯 Troubleshooting Tips:" -ForegroundColor Cyan
Write-Host "1. Nếu Gateway fail: docker restart interview-gateway-service" -ForegroundColor White
Write-Host "2. Nếu services fail: docker-compose restart" -ForegroundColor White
Write-Host "3. Kiểm tra Postman timeout settings" -ForegroundColor White
Write-Host "4. Kiểm tra firewall/antivirus" -ForegroundColor White
Write-Host "5. Test với cURL thay vì Postman" -ForegroundColor White

Write-Host "`n✅ Test completed!" -ForegroundColor Green
