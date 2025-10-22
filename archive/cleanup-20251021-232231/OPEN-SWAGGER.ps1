# Quick Swagger Access Script
# Opens all Swagger UIs in browser tabs

Write-Host "🚀 Opening All Swagger UIs..." -ForegroundColor Cyan
Write-Host ""

$swaggerUrls = @{
    "Auth Service"     = "http://localhost:8081/swagger-ui.html"
    "User Service"     = "http://localhost:8082/swagger-ui.html"
    "Question Service" = "http://localhost:8085/swagger-ui.html"
    "Exam Service"     = "http://localhost:8086/swagger-ui.html"
    "Career Service"   = "http://localhost:8084/swagger-ui.html"
    "News Service"     = "http://localhost:8087/swagger-ui.html"
}

Write-Host "📋 Available Swagger UIs:" -ForegroundColor Yellow
Write-Host ""

foreach ($service in $swaggerUrls.Keys) {
    $url = $swaggerUrls[$service]
    Write-Host "   🔗 $service" -ForegroundColor Green
    Write-Host "      $url" -ForegroundColor White
    Write-Host ""
}

Write-Host "Do you want to open all in browser? (Y/N): " -ForegroundColor Cyan -NoNewline
$response = Read-Host

if ($response -eq 'Y' -or $response -eq 'y') {
    Write-Host ""
    Write-Host "Opening browsers..." -ForegroundColor Yellow
    
    foreach ($service in $swaggerUrls.Keys) {
        $url = $swaggerUrls[$service]
        Write-Host "   Opening $service..." -ForegroundColor Green
        Start-Process $url
        Start-Sleep -Milliseconds 500  # Small delay between opens
    }
    
    Write-Host ""
    Write-Host "✅ All Swagger UIs opened!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📝 Quick Steps:" -ForegroundColor Yellow
    Write-Host "1. Go to Auth Service tab" -ForegroundColor White
    Write-Host "2. POST /auth/login with credentials" -ForegroundColor White
    Write-Host "3. Copy the accessToken from response" -ForegroundColor White
    Write-Host "4. Click 'Authorize' button in each tab" -ForegroundColor White
    Write-Host "5. Paste: Bearer <your-token>" -ForegroundColor White
    Write-Host "6. Start testing!" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "❌ Cancelled. You can open URLs manually." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "💡 Tip: See SWAGGER-TESTING-GUIDE.md for detailed instructions" -ForegroundColor Cyan
Write-Host ""
