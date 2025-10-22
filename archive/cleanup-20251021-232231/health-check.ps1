# System Health Validation Checklist
# Run this after `docker-compose up -d` to verify all services are healthy

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Interview Microservices Health Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Check Docker Containers
Write-Host "[1/7] Checking Docker containers..." -ForegroundColor Yellow
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | Select-String "interview-"
Write-Host ""

# 2. Config Server Health
Write-Host "[2/7] Checking Config Server..." -ForegroundColor Yellow
try {
    $config = Invoke-RestMethod -Uri "http://localhost:8888/actuator/health" -TimeoutSec 5
    Write-Host "✓ Config Server: $($config.status)" -ForegroundColor Green
} catch {
    Write-Host "✗ Config Server: FAILED" -ForegroundColor Red
}
Write-Host ""

# 3. Eureka Discovery
Write-Host "[3/7] Checking Eureka Discovery..." -ForegroundColor Yellow
try {
    $eureka = Invoke-RestMethod -Uri "http://localhost:8761/actuator/health" -TimeoutSec 5
    Write-Host "✓ Eureka Discovery: $($eureka.status)" -ForegroundColor Green
    Write-Host "   Registered services:" -ForegroundColor Gray
    try {
        $apps = Invoke-RestMethod -Uri "http://localhost:8761/eureka/apps" -Headers @{"Accept"="application/json"} -TimeoutSec 5
        if ($apps.applications.application) {
            $apps.applications.application | ForEach-Object {
                Write-Host "   - $($_.name) ($($_.instance.Count) instance(s))" -ForegroundColor Gray
            }
        } else {
            Write-Host "   No services registered yet" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   Could not retrieve registered services" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Eureka Discovery: FAILED" -ForegroundColor Red
}
Write-Host ""

# 4. API Gateway
Write-Host "[4/7] Checking API Gateway..." -ForegroundColor Yellow
try {
    $gateway = Invoke-RestMethod -Uri "http://localhost:8080/actuator/health" -TimeoutSec 5
    Write-Host "✓ API Gateway: $($gateway.status)" -ForegroundColor Green
    try {
        $routes = Invoke-RestMethod -Uri "http://localhost:8080/actuator/gateway/routes" -TimeoutSec 5
        Write-Host "   Configured routes: $($routes.Count)" -ForegroundColor Gray
    } catch {}
} catch {
    Write-Host "✗ API Gateway: FAILED" -ForegroundColor Red
}
Write-Host ""

# 5. Business Services
Write-Host "[5/7] Checking Business Services..." -ForegroundColor Yellow
$services = @(
    @{Name="Auth Service"; Port=8081},
    @{Name="User Service"; Port=8082},
    @{Name="Career Service"; Port=8084},
    @{Name="Question Service"; Port=8085},
    @{Name="Exam Service"; Port=8086},
    @{Name="News Service"; Port=8087}
)

foreach ($svc in $services) {
    try {
        $health = Invoke-RestMethod -Uri "http://localhost:$($svc.Port)/actuator/health" -TimeoutSec 3
        Write-Host "✓ $($svc.Name): $($health.status)" -ForegroundColor Green
    } catch {
        Write-Host "✗ $($svc.Name): FAILED" -ForegroundColor Red
    }
}
Write-Host ""

# 6. Database
Write-Host "[6/7] Checking PostgreSQL..." -ForegroundColor Yellow
try {
    $pgCheck = docker exec interview-postgres pg_isready -U postgres 2>&1
    if ($pgCheck -like "*accepting connections*") {
        Write-Host "✓ PostgreSQL: accepting connections" -ForegroundColor Green
    } else {
        Write-Host "✗ PostgreSQL: not ready" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ PostgreSQL: FAILED" -ForegroundColor Red
}
Write-Host ""

# 7. Redis
Write-Host "[7/7] Checking Redis..." -ForegroundColor Yellow
try {
    $redisCheck = docker exec interview-redis redis-cli ping 2>&1
    if ($redisCheck -eq "PONG") {
        Write-Host "✓ Redis: PONG" -ForegroundColor Green
    } else {
        Write-Host "✗ Redis: no response" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Redis: FAILED" -ForegroundColor Red
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Health Check Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Quick Links:" -ForegroundColor Yellow
Write-Host "  Eureka Dashboard: http://localhost:8761" -ForegroundColor Gray
Write-Host "  API Gateway:      http://localhost:8080/actuator/health" -ForegroundColor Gray
Write-Host "  Config Server:    http://localhost:8888/actuator/health" -ForegroundColor Gray
Write-Host ""
Write-Host "To view logs: docker-compose logs -f [service-name]" -ForegroundColor Gray
Write-Host "To restart:   docker-compose restart [service-name]" -ForegroundColor Gray
Write-Host ""
