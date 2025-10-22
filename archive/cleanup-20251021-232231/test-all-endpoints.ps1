# Test All System Endpoints
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   ABC Interview System - Endpoint Test" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$baseUrl = "http://localhost:8080"
$testResults = @()

# Helper function to test endpoint
function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Url,
        [string]$Method = "GET",
        [string]$Body = $null,
        [hashtable]$Headers = @{},
        [int]$ExpectedStatus = 200
    )
    
    try {
        $params = @{
            Uri = $Url
            Method = $Method
            TimeoutSec = 10
            ErrorAction = "Stop"
        }
        
        if ($Headers.Count -gt 0) {
            $params.Headers = $Headers
        }
        
        if ($Body) {
            $params.Body = $Body
            $params.ContentType = "application/json"
        }
        
        $response = Invoke-WebRequest @params
        $status = $response.StatusCode
        
        if ($status -eq $ExpectedStatus) {
            Write-Host "✓ " -ForegroundColor Green -NoNewline
            Write-Host "$Name" -ForegroundColor White -NoNewline
            Write-Host " ($status)" -ForegroundColor Gray
            return @{Status="PASS";Name=$Name;Code=$status}
        } else {
            Write-Host "⚠ " -ForegroundColor Yellow -NoNewline
            Write-Host "$Name" -ForegroundColor White -NoNewline
            Write-Host " (Expected: $ExpectedStatus, Got: $status)" -ForegroundColor Yellow
            return @{Status="WARN";Name=$Name;Code=$status}
        }
    }
    catch {
        $statusCode = if ($_.Exception.Response) { 
            $_.Exception.Response.StatusCode.value__ 
        } else { 
            "ERROR" 
        }
        
        if ($statusCode -eq $ExpectedStatus) {
            Write-Host "✓ " -ForegroundColor Green -NoNewline
            Write-Host "$Name" -ForegroundColor White -NoNewline
            Write-Host " ($statusCode)" -ForegroundColor Gray
            return @{Status="PASS";Name=$Name;Code=$statusCode}
        } else {
            Write-Host "✗ " -ForegroundColor Red -NoNewline
            Write-Host "$Name" -ForegroundColor White -NoNewline
            Write-Host " ($statusCode)" -ForegroundColor Red
            return @{Status="FAIL";Name=$Name;Code=$statusCode;Error=$_.Exception.Message}
        }
    }
}

# 1. Infrastructure Services
Write-Host "`n[1] Infrastructure Services" -ForegroundColor Magenta
Write-Host "─────────────────────────────" -ForegroundColor DarkGray
$testResults += Test-Endpoint -Name "Eureka Discovery" -Url "http://localhost:8761/actuator/health"
$testResults += Test-Endpoint -Name "Config Server" -Url "http://localhost:8888/actuator/health"
$testResults += Test-Endpoint -Name "API Gateway" -Url "http://localhost:8080/actuator/health"

# 2. Auth Service (Public Endpoints)
Write-Host "`n[2] Auth Service - Public Endpoints" -ForegroundColor Magenta
Write-Host "─────────────────────────────────────" -ForegroundColor DarkGray

# Try to login
try {
    $loginBody = '{"email":"admin@example.com","password":"admin123"}'
    $loginResp = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginBody -ContentType "application/json" -ErrorAction Stop
    
    if ($loginResp.accessToken) {
        $global:token = $loginResp.accessToken
        Write-Host "✓ " -ForegroundColor Green -NoNewline
        Write-Host "Auth Login (Got Token)" -ForegroundColor White
        $testResults += @{Status="PASS";Name="Auth Login";Code=200}
    } else {
        Write-Host "⚠ " -ForegroundColor Yellow -NoNewline
        Write-Host "Auth Login (No Token in Response)" -ForegroundColor Yellow
        $testResults += @{Status="WARN";Name="Auth Login";Code=200}
    }
}
catch {
    Write-Host "✗ " -ForegroundColor Red -NoNewline
    Write-Host "Auth Login Failed" -ForegroundColor Red
    $testResults += @{Status="FAIL";Name="Auth Login";Code="ERROR"}
}

# Register test (expect 400 or 409 for duplicate)
$registerBody = '{"email":"testuser' + (Get-Random -Max 99999) + '@example.com","password":"test123","fullName":"Test User","roleId":1}'
$testResults += Test-Endpoint -Name "Auth Register" -Url "$baseUrl/auth/register" -Method "POST" -Body $registerBody -ExpectedStatus 201

# 3. User Service
Write-Host "`n[3] User Service" -ForegroundColor Magenta
Write-Host "─────────────────" -ForegroundColor DarkGray

if ($global:token) {
    $authHeaders = @{"Authorization" = "Bearer $global:token"}
    $testResults += Test-Endpoint -Name "Get All Users" -Url "$baseUrl/users?page=0&size=5" -Headers $authHeaders
    $testResults += Test-Endpoint -Name "Get User By ID" -Url "$baseUrl/users/1" -Headers $authHeaders
    $testResults += Test-Endpoint -Name "Get Roles" -Url "$baseUrl/users/roles" -Headers $authHeaders
} else {
    $testResults += Test-Endpoint -Name "Get All Users" -Url "$baseUrl/users?page=0&size=5" -ExpectedStatus 401
}

# 4. Question Service
Write-Host "`n[4] Question Service" -ForegroundColor Magenta
Write-Host "────────────────────" -ForegroundColor DarkGray
$testResults += Test-Endpoint -Name "Get All Fields" -Url "$baseUrl/questions/fields"
$testResults += Test-Endpoint -Name "Get All Topics" -Url "$baseUrl/questions/topics"
$testResults += Test-Endpoint -Name "Get All Levels" -Url "$baseUrl/questions/levels"
$testResults += Test-Endpoint -Name "Get All Question Types" -Url "$baseUrl/questions/types"

if ($global:token) {
    $authHeaders = @{"Authorization" = "Bearer $global:token"}
    $testResults += Test-Endpoint -Name "Get All Questions" -Url "$baseUrl/questions?page=0&size=5" -Headers $authHeaders
}

# 5. Exam Service  
Write-Host "`n[5] Exam Service" -ForegroundColor Magenta
Write-Host "────────────────" -ForegroundColor DarkGray

if ($global:token) {
    $authHeaders = @{"Authorization" = "Bearer $global:token"}
    $testResults += Test-Endpoint -Name "Get All Exams" -Url "$baseUrl/exams?page=0&size=5" -Headers $authHeaders
    $testResults += Test-Endpoint -Name "Get Exam Types" -Url "$baseUrl/exams/types" -Headers $authHeaders
}

# 6. News Service
Write-Host "`n[6] News Service" -ForegroundColor Magenta
Write-Host "────────────────" -ForegroundColor DarkGray
$testResults += Test-Endpoint -Name "Get All News" -Url "$baseUrl/news?page=0&size=5"
$testResults += Test-Endpoint -Name "Get News Types" -Url "$baseUrl/news/types"

# 7. Career Service
Write-Host "`n[7] Career Service" -ForegroundColor Magenta
Write-Host "──────────────────" -ForegroundColor DarkGray

if ($global:token) {
    $authHeaders = @{"Authorization" = "Bearer $global:token"}
    $testResults += Test-Endpoint -Name "Get Career Preferences" -Url "$baseUrl/career?page=0&size=5" -Headers $authHeaders
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$passed = ($testResults | Where-Object { $_.Status -eq "PASS" }).Count
$warned = ($testResults | Where-Object { $_.Status -eq "WARN" }).Count
$failed = ($testResults | Where-Object { $_.Status -eq "FAIL" }).Count
$total = $testResults.Count

Write-Host "`nTotal Tests: $total" -ForegroundColor White
Write-Host "  ✓ Passed: $passed" -ForegroundColor Green
if ($warned -gt 0) {
    Write-Host "  ⚠ Warnings: $warned" -ForegroundColor Yellow
}
if ($failed -gt 0) {
    Write-Host "  ✗ Failed: $failed" -ForegroundColor Red
}

$successRate = [math]::Round(($passed / $total) * 100, 1)
Write-Host "`nSuccess Rate: $successRate%" -ForegroundColor $(if($successRate -ge 80){"Green"}elseif($successRate -ge 60){"Yellow"}else{"Red"})

if ($failed -gt 0) {
    Write-Host "`nFailed Tests:" -ForegroundColor Red
    $testResults | Where-Object { $_.Status -eq "FAIL" } | ForEach-Object {
        Write-Host "  - $($_.Name): $($_.Code)" -ForegroundColor Red
        if ($_.Error) {
            Write-Host "    Error: $($_.Error)" -ForegroundColor DarkRed
        }
    }
}

Write-Host ""
