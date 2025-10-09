# Quick Logs Script for Interview Microservice ABC
# Usage: .\quick-logs.ps1 [service-name]

param(
    [string]$Service = ""
)

Write-Host "Quick Logs Script for Interview Microservice ABC" -ForegroundColor Blue
Write-Host "=================================================" -ForegroundColor Blue

if ($Service -eq "") {
    Write-Host "`nAvailable services:" -ForegroundColor Yellow
    Write-Host "=====================" -ForegroundColor Yellow
    Write-Host "auth-service" -ForegroundColor Cyan
    Write-Host "user-service" -ForegroundColor Cyan
    Write-Host "career-service" -ForegroundColor Cyan
    Write-Host "question-service" -ForegroundColor Cyan
    Write-Host "exam-service" -ForegroundColor Cyan
    Write-Host "news-service" -ForegroundColor Cyan
    Write-Host "gateway-service" -ForegroundColor Cyan
    Write-Host "discovery-service" -ForegroundColor Cyan
    Write-Host "config-service" -ForegroundColor Cyan
    Write-Host "postgres" -ForegroundColor Cyan
    Write-Host "redis" -ForegroundColor Cyan
    
    Write-Host "`nUsage: .\quick-logs.ps1 [service-name]" -ForegroundColor Green
    Write-Host "Example: .\quick-logs.ps1 auth-service" -ForegroundColor Green
    exit 0
}

Write-Host "`nShowing logs for: $Service" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop viewing logs" -ForegroundColor Cyan

docker-compose logs -f $Service





