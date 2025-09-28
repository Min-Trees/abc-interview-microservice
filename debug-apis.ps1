# Debug API Script - Tìm nguyên nhân chính xác tại sao APIs trả về false
# Test từng bước để xác định vấn đề

param(
    [string]$BaseUrl = "http://localhost:8080"
)

Write-Host "🔍 DEBUGGING API ISSUES - Tìm nguyên nhân chính xác" -ForegroundColor Red
Write-Host "=================================================" -ForegroundColor Red

# Function to test API with detailed error info
function Test-APIDebug {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Url,
        [hashtable]$Headers = @{},
        [string]$Body = $null
    )
    
    Write-Host "`n🔍 Testing: $Name" -ForegroundColor Yellow
    Write-Host "URL: $Url" -ForegroundColor Cyan
    Write-Host "Method: $Method" -ForegroundColor Cyan
    
    try {
        $requestParams = @{
            Uri = $Url
            Method = $Method
            Headers = $Headers
            TimeoutSec = 10
        }
        
        if ($Body) {
            $requestParams.Body = $Body
            $requestParams.ContentType = "application/json"
        }
        
        $response = Invoke-RestMethod @requestParams -ErrorAction Stop
        
        Write-Host "✅ SUCCESS: $Name" -ForegroundColor Green
        Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ FAILED: $Name" -ForegroundColor Red
        Write-Host "Error Type: $($_.Exception.GetType().Name)" -ForegroundColor Red
        Write-Host "Error Message: $($_.Exception.Message)" -ForegroundColor Red
        
        if ($_.Exception.Response) {
            Write-Host "HTTP Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
            Write-Host "HTTP Description: $($_.Exception.Response.StatusDescription)" -ForegroundColor Red
        }
        
        return $false
    }
}

# Test 1: Kiểm tra Gateway Service
Write-Host "`n📡 STEP 1: Testing Gateway Service" -ForegroundColor Blue
Test-APIDebug -Name "Gateway Health" -Method "GET" -Url "$BaseUrl/actuator/health"

# Test 2: Kiểm tra Auth Service trực tiếp
Write-Host "`n🔐 STEP 2: Testing Auth Service Direct" -ForegroundColor Blue
Test-APIDebug -Name "Auth Service Health" -Method "GET" -Url "http://localhost:8081/actuator/health"

# Test 3: Kiểm tra User Service trực tiếp
Write-Host "`n👤 STEP 3: Testing User Service Direct" -ForegroundColor Blue
Test-APIDebug -Name "User Service Health" -Method "GET" -Url "http://localhost:8082/actuator/health"

# Test 4: Kiểm tra Career Service trực tiếp
Write-Host "`n🎯 STEP 4: Testing Career Service Direct" -ForegroundColor Blue
Test-APIDebug -Name "Career Service Health" -Method "GET" -Url "http://localhost:8084/actuator/health"

# Test 5: Test Auth Service APIs
Write-Host "`n🔑 STEP 5: Testing Auth Service APIs" -ForegroundColor Blue
$loginBody = @{
    email = "test@example.com"
    password = "password123"
} | ConvertTo-Json

Test-APIDebug -Name "Auth Login" -Method "POST" -Url "http://localhost:8081/auth/login" -Body $loginBody

# Test 6: Test User Service APIs
Write-Host "`n👥 STEP 6: Testing User Service APIs" -ForegroundColor Blue
Test-APIDebug -Name "User Get" -Method "GET" -Url "http://localhost:8082/users/1"

# Test 7: Test Career Service APIs
Write-Host "`n🎯 STEP 7: Testing Career Service APIs" -ForegroundColor Blue
Test-APIDebug -Name "Career Get" -Method "GET" -Url "http://localhost:8084/career/1"

# Test 8: Test Gateway Routing
Write-Host "`n🌐 STEP 8: Testing Gateway Routing" -ForegroundColor Blue
Test-APIDebug -Name "Gateway Auth" -Method "GET" -Url "$BaseUrl/auth/users/1"
Test-APIDebug -Name "Gateway User" -Method "GET" -Url "$BaseUrl/users/1"
Test-APIDebug -Name "Gateway Career" -Method "GET" -Url "$BaseUrl/career/1"

Write-Host "`n📊 DEBUG SUMMARY:" -ForegroundColor Blue
Write-Host "=================" -ForegroundColor Blue
Write-Host "Kiểm tra từng bước để tìm ra nguyên nhân chính xác tại sao APIs trả về false" -ForegroundColor Yellow
