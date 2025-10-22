# Rebuild All Services - Apply New Swagger Configuration
# Run this script after updating Swagger configs

Write-Host "🔨 Rebuilding All Services with New Swagger Configuration..." -ForegroundColor Cyan
Write-Host ""

$services = @(
    "auth-service",
    "user-service", 
    "question-service",
    "exam-service",
    "career-service",
    "news-service"
)

$successCount = 0
$failCount = 0

foreach ($service in $services) {
    Write-Host "📦 Building $service..." -ForegroundColor Yellow
    
    Push-Location $service
    
    # Clean and package (skip tests for faster build)
    $output = & .\mvnw.cmd clean package -DskipTests 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ $service built successfully" -ForegroundColor Green
        $successCount++
    } else {
        Write-Host "   ❌ $service build failed!" -ForegroundColor Red
        Write-Host "   Error: $output" -ForegroundColor Red
        $failCount++
    }
    
    Pop-Location
    Write-Host ""
}

Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "BUILD SUMMARY" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✅ Success: $successCount services" -ForegroundColor Green
Write-Host "❌ Failed:  $failCount services" -ForegroundColor Red
Write-Host ""

if ($failCount -eq 0) {
    Write-Host "🎉 All services built successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "1. Restart services: docker-compose down && docker-compose up -d" -ForegroundColor White
    Write-Host "2. Wait for all services to start (~30 seconds)" -ForegroundColor White
    Write-Host "3. Open Swagger UI: http://localhost:8081/swagger-ui.html" -ForegroundColor White
    Write-Host "4. Follow SWAGGER-TESTING-GUIDE.md for testing" -ForegroundColor White
} else {
    Write-Host "⚠️  Some services failed to build. Check errors above." -ForegroundColor Yellow
    Write-Host "Try rebuilding failed services individually:" -ForegroundColor Yellow
    Write-Host "  cd <service-name>" -ForegroundColor White
    Write-Host "  .\mvnw.cmd clean package -DskipTests" -ForegroundColor White
}

Write-Host ""
