# Quick Restart Script for Interview Microservice ABC
# Usage: .\quick-restart.ps1

Write-Host "Quick Restart Script for Interview Microservice ABC" -ForegroundColor Blue
Write-Host "====================================================" -ForegroundColor Blue

# Stop all services
Write-Host "`nStopping all services..." -ForegroundColor Yellow
docker-compose down

# Start services again
Write-Host "`nStarting services..." -ForegroundColor Yellow
docker-compose up -d

# Wait for services to be ready
Write-Host "`nWaiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Check service status
Write-Host "`nChecking service status..." -ForegroundColor Yellow
docker-compose ps

Write-Host "`n[OK] Restart completed!" -ForegroundColor Green





