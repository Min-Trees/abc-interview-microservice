# Simple NLP Service Test
Write-Host "Testing NLP Service" -ForegroundColor Blue
Write-Host "===================" -ForegroundColor Blue

# Test health endpoint
Write-Host "Testing health endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8088/health" -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "Health check successful" -ForegroundColor Green
        $healthData = $response.Content | ConvertFrom-Json
        Write-Host "Status: $($healthData.status)" -ForegroundColor White
        Write-Host "Service: $($healthData.service)" -ForegroundColor White
        Write-Host "Version: $($healthData.version)" -ForegroundColor White
    }
} catch {
    Write-Host "Health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test root endpoint
Write-Host "Testing root endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8088/" -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "Root endpoint successful" -ForegroundColor Green
        $rootData = $response.Content | ConvertFrom-Json
        Write-Host "Message: $($rootData.message)" -ForegroundColor White
    }
} catch {
    Write-Host "Root endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "NLP Service testing completed!" -ForegroundColor Green
Write-Host "Service URLs:" -ForegroundColor Yellow
Write-Host "- Health: http://localhost:8088/health" -ForegroundColor Cyan
Write-Host "- Root: http://localhost:8088/" -ForegroundColor Cyan
