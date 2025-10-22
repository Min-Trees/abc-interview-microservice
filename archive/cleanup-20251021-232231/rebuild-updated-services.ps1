#!/usr/bin/env pwsh
# Script: Rebuild và restart các services đã sửa
# Purpose: Apply changes to Response DTOs and endpoint modifications

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  REBUILD & RESTART SERVICES" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$services = @(
    "interview-question-service",
    "interview-exam-service", 
    "interview-news-service",
    "interview-user-service",
    "interview-auth-service",
    "interview-career-service"
)

Write-Host "Services to restart:" -ForegroundColor Yellow
$services | ForEach-Object { Write-Host "  - $_" }
Write-Host ""

# Stop services
Write-Host "Stopping services..." -ForegroundColor Yellow
docker stop $services | Out-Null
Write-Host "Services stopped" -ForegroundColor Green
Write-Host ""

# Rebuild images
Write-Host "Rebuilding services (this may take a few minutes)..." -ForegroundColor Yellow
docker-compose build question-service exam-service news-service user-service auth-service career-service 2>&1 | Out-Null
Write-Host "Services rebuilt" -ForegroundColor Green
Write-Host ""

# Start services
Write-Host "Starting services..." -ForegroundColor Yellow
docker start $services | Out-Null
Start-Sleep -Seconds 10
Write-Host "Services started" -ForegroundColor Green
Write-Host ""

# Check service health
Write-Host "Checking service health..." -ForegroundColor Yellow
Write-Host ""
foreach ($service in $services) {
    $status = docker inspect --format '{{.State.Status}}' $service 2>$null
    if ($status -eq "running") {
        Write-Host "  OK: $service is running" -ForegroundColor Green
    } else {
        Write-Host "  ERROR: $service is $status" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "CHANGES APPLIED:" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "1. Added @JsonInclude(NON_NULL) to 15 Response DTOs" -ForegroundColor White
Write-Host "2. Changed endpoint /news/type/{type} to /news/type?type=X" -ForegroundColor White
Write-Host "3. Changed endpoint /exams/type/{type} to /exams/type?type=X" -ForegroundColor White
Write-Host "4. Updated Postman collections" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  - Test endpoints with new request param format" -ForegroundColor White
Write-Host "  - Verify null fields are not returned in JSON" -ForegroundColor White
Write-Host "  - Import updated Postman collections" -ForegroundColor White
Write-Host ""
