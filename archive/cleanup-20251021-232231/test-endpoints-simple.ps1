# Test All System Endpoints - ABC Interview System
Write-Host "`n========================================"  -ForegroundColor Cyan
Write-Host "  ABC Interview - Endpoint Test"  -ForegroundColor Cyan
Write-Host "========================================`n"  -ForegroundColor Cyan

$baseUrl = "http://localhost:8080"
$passed = 0
$failed = 0

function Test-API {
    param(
        [string]$Name,
        [string]$Url,
        [string]$Method="GET",
        [string]$Body=$null,
        [hashtable]$Headers=@{},
        [int]$TimeoutSec=5
    )
    
    try {
    $params = @{Uri=$Url; Method=$Method; TimeoutSec=$TimeoutSec; ErrorAction="Stop"}
        if ($Headers.Count -gt 0) { $params.Headers = $Headers }
        if ($Body) { $params.Body = $Body; $params.ContentType = "application/json" }
        
        $response = Invoke-WebRequest @params
        Write-Host "[OK] $Name - $($response.StatusCode)" -ForegroundColor Green
        return $true
    }
    catch {
        $code = if ($_.Exception.Response) { $_.Exception.Response.StatusCode.value__ } else { "ERROR" }
        Write-Host "[FAIL] $Name - $code" -ForegroundColor Red
        return $false
    }
}

# 1. Infrastructure
Write-Host "`n[1] Infrastructure Services" -ForegroundColor Magenta
Write-Host "----------------------------" -ForegroundColor DarkGray
if (Test-API "Eureka Discovery" "http://localhost:8761/actuator/health") { $passed++ } else { $failed++ }
if (Test-API "Config Server" "http://localhost:8888/actuator/health") { $passed++ } else { $failed++ }
if (Test-API "API Gateway" "$baseUrl/actuator/health") { $passed++ } else { $failed++ }

# 2. Auth Service
Write-Host "`n[2] Auth Service" -ForegroundColor Magenta
Write-Host "----------------" -ForegroundColor DarkGray

try {
    $loginBody = '{"email":"admin@example.com","password":"admin123"}'
    $loginResp = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    
    if ($loginResp.accessToken) {
        $global:token = $loginResp.accessToken
        Write-Host "[OK] Auth Login (admin) - Got token" -ForegroundColor Green
        $passed++
    } else {
        Write-Host "[WARN] Auth Login (admin) - No token in response" -ForegroundColor Yellow
        $failed++
    }
}
catch {
    Write-Host "[FAIL] Auth Login (admin)" -ForegroundColor Red
    $failed++
}

$registerEmail = "testuser$(Get-Random -Max 99999)@example.com"
$registerBody = "{`"email`":`"$registerEmail`",`"password`":`"test123`",`"fullName`":`"Test User`",`"roleId`":1}"

# Register new user (capture verifyToken)
try {
    $registerResp = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method POST -Body $registerBody -ContentType "application/json" -TimeoutSec 20
    if ($registerResp -and $registerResp.verifyToken) {
        Write-Host "[OK] Auth Register - 201 (verifyToken received)" -ForegroundColor Green
        $passed++

        # Verify the account to activate it
        try {
            $verifyUrl = "$baseUrl/auth/verify?token=$($registerResp.verifyToken)"
            $verifyResp = Invoke-RestMethod -Uri $verifyUrl -Method GET -TimeoutSec 10
            Write-Host "[OK] Auth Verify - Account activated" -ForegroundColor Green
            $passed++
        }
        catch {
            Write-Host "[FAIL] Auth Verify - Activation failed" -ForegroundColor Red
            $failed++
        }
    } else {
        Write-Host "[WARN] Auth Register - No verifyToken in response" -ForegroundColor Yellow
        $failed++
    }
}
catch {
    Write-Host "[FAIL] Auth Register" -ForegroundColor Red
    $failed++
}

# Try login with the newly registered (and verified) user to obtain a token for secured endpoints
try {
    $loginBody2 = "{`"email`":`"$registerEmail`",`"password`":`"test123`"}"
    $loginResp2 = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginBody2 -ContentType "application/json" -TimeoutSec 20
    if ($loginResp2.accessToken) {
        $global:token = $loginResp2.accessToken
        Write-Host "[OK] Auth Login (new user) - Got token" -ForegroundColor Green
        $passed++
    } else {
        Write-Host "[WARN] Auth Login (new user) - No token in response" -ForegroundColor Yellow
        $failed++
    }
}
catch {
    Write-Host "[FAIL] Auth Login (new user)" -ForegroundColor Red
    $failed++
}

# 3. User Service
Write-Host "`n[3] User Service" -ForegroundColor Magenta
Write-Host "----------------" -ForegroundColor DarkGray

if ($global:token) {
    $authHeaders = @{"Authorization" = "Bearer $global:token"}
    if (Test-API "Get User By ID" "$baseUrl/users/1" "GET" $null $authHeaders) { $passed++ } else { $failed++ }
    if (Test-API "Get All Roles" "$baseUrl/users/roles") { $passed++ } else { $failed++ }
} else {
    Write-Host "[SKIP] User endpoints - No auth token" -ForegroundColor Yellow
    $failed += 2
}

# 4. Question Service
Write-Host "`n[4] Question Service" -ForegroundColor Magenta
Write-Host "--------------------" -ForegroundColor DarkGray
if (Test-API "Get All Fields" "$baseUrl/questions/fields") { $passed++ } else { $failed++ }
if (Test-API "Get All Topics" "$baseUrl/questions/topics") { $passed++ } else { $failed++ }
if (Test-API "Get All Levels" "$baseUrl/questions/levels") { $passed++ } else { $failed++ }
if (Test-API "Get All Question Types" "$baseUrl/questions/question-types") { $passed++ } else { $failed++ }

if ($global:token) {
    $authHeaders = @{"Authorization" = "Bearer $global:token"}
    if (Test-API "Get All Questions" "$baseUrl/questions?page=0&size=5" "GET" $null $authHeaders) { $passed++ } else { $failed++ }
} else {
    Write-Host "[SKIP] Questions list - No auth token" -ForegroundColor Yellow
    $failed++
}

# 5. Exam Service  
Write-Host "`n[5] Exam Service" -ForegroundColor Magenta
Write-Host "----------------" -ForegroundColor DarkGray

if ($global:token) {
    $authHeaders = @{"Authorization" = "Bearer $global:token"}
    if (Test-API "Get All Exams" "$baseUrl/exams?page=0&size=5" "GET" $null $authHeaders) { $passed++ } else { $failed++ }
    if (Test-API "Get Exam Types" "$baseUrl/exams/types") { $passed++ } else { $failed++ }
} else {
    Write-Host "[SKIP] Exam endpoints - No auth token" -ForegroundColor Yellow
    $failed += 2
}

# 6. News Service
Write-Host "`n[6] News Service" -ForegroundColor Magenta
Write-Host "----------------" -ForegroundColor DarkGray
if (Test-API "Get All News" "$baseUrl/news?page=0&size=5") { $passed++ } else { $failed++ }
if (Test-API "Get News Types" "$baseUrl/news/types") { $passed++ } else { $failed++ }

# 7. Career Service
Write-Host "`n[7] Career Service" -ForegroundColor Magenta
Write-Host "------------------" -ForegroundColor DarkGray

if ($global:token) {
    # /career endpoint requires userId path param; skip for now or use a valid userId
    # The main endpoint is /career/preferences/{userId}
    Write-Host "[SKIP] Career Preferences - Requires userId parameter" -ForegroundColor Yellow
} else {
    Write-Host "[SKIP] Career endpoints - No auth token" -ForegroundColor Yellow
}

# Summary
$total = $passed + $failed
$successRate = [math]::Round(($passed / $total) * 100, 1)

Write-Host "`n========================================"  -ForegroundColor Cyan
Write-Host "  Test Summary"  -ForegroundColor Cyan
Write-Host "========================================`n"  -ForegroundColor Cyan
Write-Host "Total Tests: $total" -ForegroundColor White
Write-Host "  Passed: $passed" -ForegroundColor Green
Write-Host "  Failed: $failed" -ForegroundColor Red
Write-Host "`nSuccess Rate: $successRate%" -ForegroundColor $(if($successRate -ge 80){"Green"}elseif($successRate -ge 60){"Yellow"}else{"Red"})
Write-Host ""
