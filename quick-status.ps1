# Quick Status Script for Interview Microservice ABC
# Usage: .\quick-status.ps1

Write-Host "Quick Status Script for Interview Microservice ABC" -ForegroundColor Blue
Write-Host "====================================================" -ForegroundColor Blue

# Check Docker status
Write-Host "`nDocker Status:" -ForegroundColor Yellow
try {
    docker ps | Out-Null
    Write-Host "[OK] Docker is running" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Docker is not running" -ForegroundColor Red
    exit 1
}

# Check service status
Write-Host "`nService Status:" -ForegroundColor Yellow
docker-compose ps

# Check service health
Write-Host "`nService Health:" -ForegroundColor Yellow
Write-Host "=================" -ForegroundColor Yellow

$services = @(
    @{Name="Auth Service"; Port="8081"; Path="/actuator/health"},
    @{Name="User Service"; Port="8082"; Path="/actuator/health"},
    @{Name="Career Service"; Port="8084"; Path="/actuator/health"},
    @{Name="Question Service"; Port="8085"; Path="/actuator/health"},
    @{Name="Exam Service"; Port="8086"; Path="/actuator/health"},
    @{Name="News Service"; Port="8087"; Path="/actuator/health"},
    @{Name="NLP Service"; Port="8088"; Path="/health"},
    @{Name="Gateway Service"; Port="8080"; Path="/actuator/health"},
    @{Name="Discovery Service"; Port="8761"; Path="/actuator/health"},
    @{Name="Config Service"; Port="8888"; Path="/actuator/health"}
)

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$($service.Port)$($service.Path)" -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "[OK] $($service.Name): Healthy" -ForegroundColor Green
        } else {
            Write-Host "[WARN] $($service.Name): Unhealthy (Status: $($response.StatusCode))" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[ERROR] $($service.Name): Not responding" -ForegroundColor Red
    }
}

# Show service URLs
Write-Host "`nService URLs:" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host "[AUTH] Auth Service:     http://localhost:8081/swagger-ui.html" -ForegroundColor Cyan
Write-Host "[USER] User Service:     http://localhost:8082/swagger-ui.html" -ForegroundColor Cyan
Write-Host "[CAREER] Career Service:   http://localhost:8084/swagger-ui.html" -ForegroundColor Cyan
Write-Host "[QUESTION] Question Service: http://localhost:8085/swagger-ui.html" -ForegroundColor Cyan
Write-Host "[EXAM] Exam Service:     http://localhost:8086/swagger-ui.html" -ForegroundColor Cyan
Write-Host "[NEWS] News Service:     http://localhost:8087/swagger-ui.html" -ForegroundColor Cyan
Write-Host "[NLP] NLP Service:      http://localhost:8088/swagger-ui.html" -ForegroundColor Cyan
Write-Host "[GATEWAY] Gateway Service:  http://localhost:8080/swagger-ui.html" -ForegroundColor Cyan
Write-Host "[DISCOVERY] Discovery Service: http://localhost:8761" -ForegroundColor Cyan
Write-Host "[CONFIG] Config Service:   http://localhost:8888" -ForegroundColor Cyan

Write-Host "`nSwagger Aggregator: Open 'swagger-aggregator.html' in browser" -ForegroundColor Magenta
