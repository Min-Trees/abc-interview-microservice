# Quick Stop Script for Interview Microservice ABC
# Usage: .\quick-stop.ps1

Write-Host "Quick Stop Script for Interview Microservice ABC" -ForegroundColor Red
Write-Host "=================================================" -ForegroundColor Red

# Stop all services
Write-Host "`nStopping all services..." -ForegroundColor Yellow
docker-compose down

# Remove containers and networks
Write-Host "`nRemoving containers and networks..." -ForegroundColor Yellow
docker-compose down --remove-orphans

# Optional: Remove volumes (uncomment if you want to reset database)
# Write-Host "`nRemoving volumes..." -ForegroundColor Yellow
# docker-compose down -v

Write-Host "`n[OK] All services stopped successfully!" -ForegroundColor Green





