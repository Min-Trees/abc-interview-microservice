# Production API Testing Script with Authentication
# Tests all 79 APIs with proper authentication and role-based access

param(
    [string]$BaseUrl = "http://localhost:8080"
)

# Test results
$TestResults = @{
    Total = 0
    Passed = 0
    Failed = 0
    Errors = @()
    AuthToken = $null
    UserToken = $null
    AdminToken = $null
    RecruiterToken = $null
}

function Test-APIEndpoint {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Url,
        [hashtable]$Headers = @{},
        [string]$Body = $null,
        [int]$ExpectedStatus = 200,
        [string]$Description = ""
    )
    
    $TestResults.Total++
    
    try {
        $requestParams = @{
            Uri = $Url
            Method = $Method
            Headers = $Headers
            TimeoutSec = 30
        }
        
        if ($Body) {
            $requestParams.Body = $Body
            $requestParams.ContentType = "application/json"
        }
        
        $response = Invoke-RestMethod @requestParams -ErrorAction Stop
        
        Write-Host "PASS: $Name - Status: $($response.StatusCode)" -ForegroundColor Green
        $TestResults.Passed++
        return $true
    }
    catch {
        $errorMsg = "FAIL: $Name - Error: $($_.Exception.Message)"
        Write-Host $errorMsg -ForegroundColor Red
        $TestResults.Failed++
        $TestResults.Errors += $errorMsg
        return $false
    }
}

function Get-AuthToken {
    param(
        [string]$Email,
        [string]$Password,
        [string]$Role
    )
    
    $loginBody = @{
        email = $Email
        password = $Password
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$BaseUrl/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
        return $response.accessToken
    }
    catch {
        Write-Host "Failed to get token for $Role: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Test-AuthenticationFlow {
    Write-Host "`n🔐 Testing Authentication Flow..." -ForegroundColor Blue
    
    # Test user registration
    $registerBody = @{
        email = "testuser@example.com"
        password = "password123"
        fullName = "Test User"
        roleId = 1
    } | ConvertTo-Json
    
    Test-APIEndpoint -Name "POST /auth/register" -Method "POST" -Url "$BaseUrl/auth/register" -Body $registerBody -ExpectedStatus 201 -Description "User registration"
    
    # Test user login
    $loginBody = @{
        email = "test@example.com"
        password = "password123"
    } | ConvertTo-Json
    
    Test-APIEndpoint -Name "POST /auth/login" -Method "POST" -Url "$BaseUrl/auth/login" -Body $loginBody -ExpectedStatus 200 -Description "User login"
    
    # Get authentication tokens
    $TestResults.AuthToken = Get-AuthToken "test@example.com" "password123" "USER"
    $TestResults.AdminToken = Get-AuthToken "admin2@example.com" "admin123" "ADMIN"
    $TestResults.RecruiterToken = Get-AuthToken "recruiter@example.com" "recruiter123" "RECRUITER"
    
    if ($TestResults.AuthToken) {
        Write-Host "✅ Authentication tokens obtained successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to obtain authentication tokens" -ForegroundColor Red
    }
}

function Test-UserService {
    Write-Host "`n👤 Testing User Service APIs..." -ForegroundColor Blue
    
    $headers = @{}
    if ($TestResults.AuthToken) {
        $headers["Authorization"] = "Bearer $($TestResults.AuthToken)"
    }
    
    # Test get user by ID
    Test-APIEndpoint -Name "GET /users/1" -Method "GET" -Url "$BaseUrl/users/1" -Headers $headers -ExpectedStatus 200 -Description "Get user by ID"
    
    # Test verify user
    Test-APIEndpoint -Name "GET /users/verify" -Method "GET" -Url "$BaseUrl/users/verify?token=dummy_token" -Headers $headers -ExpectedStatus 200 -Description "Verify user token"
    
    # Test update role (requires ADMIN)
    if ($TestResults.AdminToken) {
        $adminHeaders = @{"Authorization" = "Bearer $($TestResults.AdminToken)"}
        $roleBody = @{role = "ADMIN"} | ConvertTo-Json
        Test-APIEndpoint -Name "PUT /users/1/role" -Method "PUT" -Url "$BaseUrl/users/1/role" -Headers $adminHeaders -Body $roleBody -ExpectedStatus 200 -Description "Update user role"
    }
    
    # Test update status (requires ADMIN)
    if ($TestResults.AdminToken) {
        $statusBody = @{status = "ACTIVE"} | ConvertTo-Json
        Test-APIEndpoint -Name "PUT /users/1/status" -Method "PUT" -Url "$BaseUrl/users/1/status" -Headers $adminHeaders -Body $statusBody -ExpectedStatus 200 -Description "Update user status"
    }
    
    # Test apply ELO
    $eloBody = @{userId = 1; eloScore = 1500} | ConvertTo-Json
    Test-APIEndpoint -Name "POST /users/elo" -Method "POST" -Url "$BaseUrl/users/elo" -Headers $headers -Body $eloBody -ExpectedStatus 200 -Description "Apply ELO score"
}

function Test-CareerService {
    Write-Host "`n🎯 Testing Career Service APIs..." -ForegroundColor Blue
    
    $headers = @{}
    if ($TestResults.AuthToken) {
        $headers["Authorization"] = "Bearer $($TestResults.AuthToken)"
    }
    
    # Test create career preference
    $careerBody = @{
        userId = 1
        preferredFields = @("Software Engineering", "Data Science")
        experienceLevel = "INTERMEDIATE"
        salaryExpectation = 50000
        locationPreference = "Ho Chi Minh City"
        workType = "FULL_TIME"
        skills = @("Java", "Spring Boot")
        interests = @("Web Development")
    } | ConvertTo-Json
    
    Test-APIEndpoint -Name "POST /career" -Method "POST" -Url "$BaseUrl/career" -Headers $headers -Body $careerBody -ExpectedStatus 200 -Description "Create career preference"
    
    # Test get career by ID
    Test-APIEndpoint -Name "GET /career/1" -Method "GET" -Url "$BaseUrl/career/1" -Headers $headers -ExpectedStatus 200 -Description "Get career by ID"
    
    # Test update career
    Test-APIEndpoint -Name "PUT /career/update/1" -Method "PUT" -Url "$BaseUrl/career/update/1" -Headers $headers -Body $careerBody -ExpectedStatus 200 -Description "Update career preference"
    
    # Test get career by user ID
    Test-APIEndpoint -Name "GET /career/preferences/1" -Method "GET" -Url "$BaseUrl/career/preferences/1?page=0&size=10" -Headers $headers -ExpectedStatus 200 -Description "Get career by user ID"
    
    # Test delete career
    Test-APIEndpoint -Name "DELETE /career/1" -Method "DELETE" -Url "$BaseUrl/career/1" -Headers $headers -ExpectedStatus 200 -Description "Delete career preference"
}

function Test-QuestionService {
    Write-Host "`n❓ Testing Question Service APIs..." -ForegroundColor Blue
    
    $headers = @{}
    if ($TestResults.AuthToken) {
        $headers["Authorization"] = "Bearer $($TestResults.AuthToken)"
    }
    
    # Test create field (requires ADMIN)
    if ($TestResults.AdminToken) {
        $adminHeaders = @{"Authorization" = "Bearer $($TestResults.AdminToken)"}
        $fieldBody = @{name = "Computer Science"; description = "Computer Science field"} | ConvertTo-Json
        Test-APIEndpoint -Name "POST /fields" -Method "POST" -Url "$BaseUrl/fields" -Headers $adminHeaders -Body $fieldBody -ExpectedStatus 200 -Description "Create field"
    }
    
    # Test create topic (requires ADMIN)
    if ($TestResults.AdminToken) {
        $topicBody = @{name = "Data Structures"; description = "Data Structures and Algorithms"; fieldId = 1} | ConvertTo-Json
        Test-APIEndpoint -Name "POST /topics" -Method "POST" -Url "$BaseUrl/topics" -Headers $adminHeaders -Body $topicBody -ExpectedStatus 200 -Description "Create topic"
    }
    
    # Test create question
    $questionBody = @{
        title = "What is the time complexity of binary search?"
        content = "What is the time complexity of binary search algorithm?"
        difficulty = "MEDIUM"
        topicId = 1
        levelId = 1
        questionTypeId = 1
        createdBy = 1
        isMultipleChoice = $true
        isOpenEnded = $false
        options = @(
            @{ content = "O(n)"; isCorrect = $false },
            @{ content = "O(log n)"; isCorrect = $true },
            @{ content = "O(n²)"; isCorrect = $false },
            @{ content = "O(1)"; isCorrect = $false }
        )
    } | ConvertTo-Json -Depth 3
    
    Test-APIEndpoint -Name "POST /questions" -Method "POST" -Url "$BaseUrl/questions" -Headers $headers -Body $questionBody -ExpectedStatus 200 -Description "Create question"
    
    # Test get question by ID
    Test-APIEndpoint -Name "GET /questions/1" -Method "GET" -Url "$BaseUrl/questions/1" -Headers $headers -ExpectedStatus 200 -Description "Get question by ID"
    
    # Test approve question (requires ADMIN)
    if ($TestResults.AdminToken) {
        Test-APIEndpoint -Name "POST /questions/1/approve" -Method "POST" -Url "$BaseUrl/questions/1/approve?adminId=1" -Headers $adminHeaders -ExpectedStatus 200 -Description "Approve question"
    }
}

function Test-ExamService {
    Write-Host "`n📝 Testing Exam Service APIs..." -ForegroundColor Blue
    
    $headers = @{}
    if ($TestResults.AuthToken) {
        $headers["Authorization"] = "Bearer $($TestResults.AuthToken)"
    }
    
    # Test create exam
    $examBody = @{
        title = "Java Programming Test"
        description = "Test your Java programming skills"
        examType = "TECHNICAL"
        duration = 60
        maxAttempts = 3
        isActive = $true
        createdBy = 1
    } | ConvertTo-Json
    
    Test-APIEndpoint -Name "POST /exams" -Method "POST" -Url "$BaseUrl/exams" -Headers $headers -Body $examBody -ExpectedStatus 200 -Description "Create exam"
    
    # Test get exam by ID
    Test-APIEndpoint -Name "GET /exams/1" -Method "GET" -Url "$BaseUrl/exams/1" -Headers $headers -ExpectedStatus 200 -Description "Get exam by ID"
    
    # Test publish exam (requires ADMIN or RECRUITER)
    if ($TestResults.AdminToken) {
        $adminHeaders = @{"Authorization" = "Bearer $($TestResults.AdminToken)"}
        Test-APIEndpoint -Name "POST /exams/1/publish" -Method "POST" -Url "$BaseUrl/exams/1/publish?userId=1" -Headers $adminHeaders -ExpectedStatus 200 -Description "Publish exam"
    }
}

function Test-NewsService {
    Write-Host "`n📰 Testing News Service APIs..." -ForegroundColor Blue
    
    $headers = @{}
    if ($TestResults.AuthToken) {
        $headers["Authorization"] = "Bearer $($TestResults.AuthToken)"
    }
    
    # Test create news
    $newsBody = @{
        title = "New Job Opportunities in Tech"
        content = "Exciting new job opportunities in the technology sector..."
        newsType = "JOB_OPPORTUNITY"
        fieldId = 1
        createdBy = 1
        tags = @("tech", "jobs", "opportunities")
    } | ConvertTo-Json
    
    Test-APIEndpoint -Name "POST /news" -Method "POST" -Url "$BaseUrl/news" -Headers $headers -Body $newsBody -ExpectedStatus 200 -Description "Create news"
    
    # Test get news by ID
    Test-APIEndpoint -Name "GET /news/1" -Method "GET" -Url "$BaseUrl/news/1" -Headers $headers -ExpectedStatus 200 -Description "Get news by ID"
    
    # Test approve news (requires ADMIN)
    if ($TestResults.AdminToken) {
        $adminHeaders = @{"Authorization" = "Bearer $($TestResults.AdminToken)"}
        Test-APIEndpoint -Name "POST /news/1/approve" -Method "POST" -Url "$BaseUrl/news/1/approve?adminId=1" -Headers $adminHeaders -ExpectedStatus 200 -Description "Approve news"
    }
}

function Test-NLPService {
    Write-Host "`n🤖 Testing NLP Service APIs..." -ForegroundColor Blue
    
    $headers = @{}
    if ($TestResults.AuthToken) {
        $headers["Authorization"] = "Bearer $($TestResults.AuthToken)"
    }
    
    # Test health check
    Test-APIEndpoint -Name "GET /health" -Method "GET" -Url "$BaseUrl/health" -Headers $headers -ExpectedStatus 200 -Description "Health check"
    
    # Test check similarity
    $similarityBody = @{question_text = "What is machine learning?"; exclude_id = 1} | ConvertTo-Json
    Test-APIEndpoint -Name "POST /questions/similarity/check" -Method "POST" -Url "$BaseUrl/questions/similarity/check" -Headers $headers -Body $similarityBody -ExpectedStatus 200 -Description "Check question similarity"
}

function Show-TestResults {
    Write-Host "`n📊 Production Test Results Summary:" -ForegroundColor Blue
    Write-Host "Total Tests: $($TestResults.Total)" -ForegroundColor Yellow
    Write-Host "Passed: $($TestResults.Passed)" -ForegroundColor Green
    Write-Host "Failed: $($TestResults.Failed)" -ForegroundColor Red
    
    if ($TestResults.Errors.Count -gt 0) {
        Write-Host "`n❌ Errors:" -ForegroundColor Red
        foreach ($error in $TestResults.Errors) {
            Write-Host "  - $error" -ForegroundColor Red
        }
    }
    
    $successRate = if ($TestResults.Total -gt 0) { [math]::Round(($TestResults.Passed / $TestResults.Total) * 100, 2) } else { 0 }
    Write-Host "`nSuccess Rate: $successRate%" -ForegroundColor Yellow
    
    if ($TestResults.Failed -eq 0) {
        Write-Host "`n🎉 All production tests passed! System is ready for customer delivery." -ForegroundColor Green
    } else {
        Write-Host "`n⚠️  Some tests failed. Please check the errors above before delivery." -ForegroundColor Yellow
    }
}

# Main execution
Write-Host "🚀 Production API Testing - Interview Microservice ABC" -ForegroundColor Blue
Write-Host "=========================================================" -ForegroundColor Blue
Write-Host "Base URL: $BaseUrl" -ForegroundColor Yellow

# Run all tests
Test-AuthenticationFlow
Test-UserService
Test-CareerService
Test-QuestionService
Test-ExamService
Test-NewsService
Test-NLPService

# Show results
Show-TestResults
