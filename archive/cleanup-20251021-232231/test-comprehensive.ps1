# ============================================
# ABC Interview - COMPREHENSIVE Endpoint Test
# Tests 50+ critical endpoints across all services
# ============================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  ABC Interview - Complete Endpoint Test" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$baseUrl = "http://localhost:8080"
$passed = 0
$failed = 0
$token = ""

function Test-API {
    param(
        [string]$Name,
        [string]$Url,
        [string]$Method="GET",
        [string]$Body=$null,
        [bool]$UseAuth=$false,
        [int]$TimeoutSec=10
    )
    
    try {
        $headers = @{}
        if ($UseAuth -and $script:token) {
            $headers["Authorization"] = "Bearer $script:token"
        }
        
        $params = @{
            Uri = $Url
            Method = $Method
            TimeoutSec = $TimeoutSec
            ErrorAction = "Stop"
        }
        
        if ($headers.Count -gt 0) { $params.Headers = $headers }
        if ($Body) { 
            $params.Body = $Body
            $params.ContentType = "application/json"
        }
        
        $response = Invoke-WebRequest @params
        Write-Host "[✓] $Name - $($response.StatusCode)" -ForegroundColor Green
        $script:passed++
        return $response.Content | ConvertFrom-Json
    }
    catch {
        $code = if ($_.Exception.Response) { $_.Exception.Response.StatusCode.value__ } else { "ERR" }
        Write-Host "[✗] $Name - $code" -ForegroundColor Red
        $script:failed++
        return $null
    }
}

# ==================== INFRASTRUCTURE ====================
Write-Host "`n[1] Infrastructure" -ForegroundColor Yellow
Write-Host "----------------------------"
Test-API "Eureka Discovery" "http://localhost:8761/actuator/health"
Test-API "Config Server" "http://localhost:8888/actuator/health"
Test-API "API Gateway" "$baseUrl/actuator/health"

# ==================== AUTH SERVICE ====================
Write-Host "`n[2] Auth Service" -ForegroundColor Yellow
Write-Host "----------------------------"

# Login
$loginBody = "{`"email`":`"admin@example.com`"`,`"password`":`"admin123`"}"
$loginResp = Test-API "Login as Admin" "$baseUrl/auth/login" "POST" $loginBody $false
if ($loginResp) {
    $script:token = $loginResp.accessToken
    Write-Host "  -> Token saved" -ForegroundColor DarkGray
}

# Get user info
Test-API "Get User Info" "$baseUrl/auth/user-info" "GET" $null $true

# ==================== USER SERVICE ====================
Write-Host "`n[3] User Service" -ForegroundColor Yellow
Write-Host "----------------------------"
Test-API "Get All Roles (Public)" "$baseUrl/users/roles" "GET" $null $false
Test-API "Get User By ID" "$baseUrl/users/1" "GET" $null $true
Test-API "Get All Users" "$baseUrl/users?page=0`&size=10" "GET" $null $true
Test-API "Get Users By Role" "$baseUrl/users/role/1?page=0`&size=5" "GET" $null $true
Test-API "Get Users By Status" "$baseUrl/users/status/ACTIVE?page=0`&size=5" "GET" $null $true

# ==================== QUESTION SERVICE ====================
Write-Host "`n[4] Question Service" -ForegroundColor Yellow
Write-Host "----------------------------"

# Fields
Test-API "Get All Fields" "$baseUrl/questions/fields?page=0`&size=10" "GET" $null $false
Test-API "Get Field By ID" "$baseUrl/questions/fields/1" "GET" $null $false

# Create Field
$fieldBody = "{`"name`":`"Test Field $((Get-Random))`"`,`"description`":`"Auto test`"}"
$fieldResp = Test-API "Create Field (Admin)" "$baseUrl/questions/fields" "POST" $fieldBody $true
if ($fieldResp -and $fieldResp.id) {
    $fieldId = $fieldResp.id
    $updateBody = "{`"name`":`"Updated Field`"`,`"description`":`"Updated`"}"
    Test-API "Update Field" "$baseUrl/questions/fields/$fieldId" "PUT" $updateBody $true
    Test-API "Delete Field" "$baseUrl/questions/fields/$fieldId" "DELETE" $null $true
}

# Topics
Test-API "Get All Topics" "$baseUrl/questions/topics?page=0`&size=10" "GET" $null $false
Test-API "Get Topic By ID" "$baseUrl/questions/topics/1" "GET" $null $false

# Levels
Test-API "Get All Levels" "$baseUrl/questions/levels?page=0`&size=10" "GET" $null $false
Test-API "Get Level By ID" "$baseUrl/questions/levels/1" "GET" $null $false

# Question Types
Test-API "Get All Question Types" "$baseUrl/questions/question-types?page=0`&size=10" "GET" $null $false
Test-API "Get Question Type By ID" "$baseUrl/questions/question-types/1" "GET" $null $false

# Questions
Test-API "Get All Questions" "$baseUrl/questions?page=0`&size=10" "GET" $null $false
Test-API "Get Question By ID" "$baseUrl/questions/1" "GET" $null $false
Test-API "Get Questions By Topic" "$baseUrl/questions/topics/1/questions?page=0`&size=5" "GET" $null $false

# Create Question (with correct DTO)
$questionBody = "{`"userId`":1`,`"topicId`":1`,`"fieldId`":1`,`"levelId`":1`,`"questionTypeId`":1`,`"content`":`"What is PowerShell?`"`,`"answer`":`"A task automation framework`"`,`"language`":`"Vietnamese`"}"
$questionResp = Test-API "Create Question" "$baseUrl/questions" "POST" $questionBody $true
if ($questionResp -and $questionResp.id) {
    $qId = $questionResp.id
    Test-API "Approve Question" "$baseUrl/questions/$qId/approve?adminId=1" "POST" $null $true
}

# Answers
Test-API "Get All Answers" "$baseUrl/questions/answers?page=0`&size=10" "GET" $null $false
Test-API "Get Answers By Question" "$baseUrl/questions/1/answers?page=0`&size=5" "GET" $null $false

# ==================== EXAM SERVICE ====================
Write-Host "`n[5] Exam Service" -ForegroundColor Yellow
Write-Host "----------------------------"
Test-API "Get Exam Types" "$baseUrl/exams/types" "GET" $null $false
Test-API "Get All Exams" "$baseUrl/exams?page=0`&size=10" "GET" $null $false
Test-API "Get Exam By ID" "$baseUrl/exams/1" "GET" $null $false
Test-API "Get Exams By User" "$baseUrl/exams/user/1?page=0`&size=5" "GET" $null $true
Test-API "Get Exams By Type" "$baseUrl/exams/type?type=VIRTUAL`&page=0`&size=5" "GET" $null $false

# Create Exam (with correct DTO - topics and questionTypes as arrays)
$examBody = "{`"userId`":1`,`"examType`":`"VIRTUAL`"`,`"title`":`"Test Exam`"`,`"position`":`"Developer`"`,`"topics`":[1]`,`"questionTypes`":[1]`,`"questionCount`":5`,`"duration`":30`,`"language`":`"Vietnamese`"}"
$examResp = Test-API "Create Exam" "$baseUrl/exams" "POST" $examBody $true
if ($examResp -and $examResp.id) {
    $examId = $examResp.id
    Test-API "Publish Exam" "$baseUrl/exams/$examId/publish?userId=1" "POST" $null $true
    Test-API "Start Exam" "$baseUrl/exams/$examId/start" "POST" $null $true
    
    # Registration
    $regBody = "{`"examId`":$examId`,`"userId`":1}"
    $regResp = Test-API "Register For Exam" "$baseUrl/exams/registrations" "POST" $regBody $true
    if ($regResp -and $regResp.id) {
        $regId = $regResp.id
        Test-API "Get Registration By ID" "$baseUrl/exams/registrations/$regId" "GET" $null $true
        Test-API "Get Registrations By Exam" "$baseUrl/exams/$examId/registrations?page=0`&size=5" "GET" $null $true
        Test-API "Get Registrations By User" "$baseUrl/exams/registrations/user/1?page=0`&size=5" "GET" $null $true
    }
    
    Test-API "Complete Exam" "$baseUrl/exams/$examId/complete" "POST" $null $true
    Test-API "Delete Exam" "$baseUrl/exams/$examId" "DELETE" $null $true
}

# ==================== NEWS SERVICE ====================
Write-Host "`n[6] News Service" -ForegroundColor Yellow
Write-Host "----------------------------"
Test-API "Get News Types" "$baseUrl/news/types" "GET" $null $false
Test-API "Get All News" "$baseUrl/news?page=0`&size=10" "GET" $null $false
Test-API "Get News By ID" "$baseUrl/news/1" "GET" $null $false
Test-API "Get News By Type" "$baseUrl/news/type?type=NEWS`&page=0`&size=5" "GET" $null $false
Test-API "Get News By User" "$baseUrl/news/user/1?page=0`&size=5" "GET" $null $true
Test-API "Get News By Field" "$baseUrl/news/field/1?page=0`&size=5" "GET" $null $false
Test-API "Get Published News" "$baseUrl/news/published/NEWS?page=0`&size=5" "GET" $null $false

# Create News
$newsBody = "{`"userId`":1`,`"title`":`"Test News`"`,`"content`":`"Content`"`,`"fieldId`":1`,`"newsType`":`"NEWS`"}"
$newsResp = Test-API "Create News" "$baseUrl/news" "POST" $newsBody $true
if ($newsResp -and $newsResp.id) {
    $newsId = $newsResp.id
    Test-API "Approve News" "$baseUrl/news/$newsId/approve?adminId=1" "POST" $null $true
    Test-API "Publish News" "$baseUrl/news/$newsId/publish" "POST" $null $true
    Test-API "Vote News" "$baseUrl/news/$newsId/vote?voteType=UPVOTE" "POST" $null $true
    Test-API "Delete News" "$baseUrl/news/$newsId" "DELETE" $null $true
}

# ==================== RECRUITMENT ====================
Write-Host "`n[7] Recruitment" -ForegroundColor Yellow
Write-Host "----------------------------"
Test-API "Get All Recruitments" "$baseUrl/recruitments?page=0`&size=10" "GET" $null $false

$recBody = "{`"userId`":1`,`"title`":`"Job`"`,`"content`":`"Desc`"`,`"fieldId`":1`,`"newsType`":`"RECRUITMENT`"`,`"companyName`":`"Co`"`,`"location`":`"HN`"`,`"salary`":`"1000`"`,`"experience`":`"2y`"`,`"position`":`"Dev`"}"
Test-API "Create Recruitment" "$baseUrl/recruitments" "POST" $recBody $true

# ==================== CAREER SERVICE ====================
Write-Host "`n[8] Career Service" -ForegroundColor Yellow
Write-Host "----------------------------"
Test-API "Get Career Prefs By User" "$baseUrl/career/preferences/1?page=0`&size=5" "GET" $null $true

$careerBody = "{`"userId`":1`,`"fieldId`":1`,`"levelId`":2`,`"desiredPosition`":`"Dev`"`,`"desiredSalary`":`"1500`"`,`"desiredLocation`":`"HN`"}"
$careerResp = Test-API "Create Career Preference" "$baseUrl/career" "POST" $careerBody $true
if ($careerResp -and $careerResp.id) {
    $careerId = $careerResp.id
    Test-API "Get Career By ID" "$baseUrl/career/$careerId" "GET" $null $true
    $updateCareer = "{`"userId`":1`,`"fieldId`":1`,`"levelId`":3`,`"desiredPosition`":`"Senior`"`,`"desiredSalary`":`"2000`"`,`"desiredLocation`":`"HN`"}"
    Test-API "Update Career" "$baseUrl/career/update/$careerId" "PUT" $updateCareer $true
    Test-API "Delete Career" "$baseUrl/career/$careerId" "DELETE" $null $true
}

# ==================== SUMMARY ====================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$total = $passed + $failed
$successRate = if ($total -gt 0) { [math]::Round(($passed / $total) * 100, 1) } else { 0 }

Write-Host "`nTotal Tests: $total" -ForegroundColor White
Write-Host "  Passed: $passed" -ForegroundColor Green
Write-Host "  Failed: $failed" -ForegroundColor Red
Write-Host "`nSuccess Rate: $successRate%" -ForegroundColor $(if ($successRate -ge 90) { "Green" } elseif ($successRate -ge 70) { "Yellow" } else { "Red" })

if ($successRate -eq 100) {
    Write-Host "`n[OK] ALL TESTS PASSED!" -ForegroundColor Green
} elseif ($successRate -ge 90) {
    Write-Host "`n[WARN] Most tests passed" -ForegroundColor Yellow
} else {
    Write-Host "`n[ERROR] Multiple failures" -ForegroundColor Red
}

Write-Host "`n========================================`n" -ForegroundColor Cyan
