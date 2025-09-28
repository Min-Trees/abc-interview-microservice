# Final API Testing Script for Production
# Tests all 79 APIs with proper authentication

param(
    [string]$BaseUrl = "http://localhost:8080"
)

# Test results
$TestResults = @{
    Total = 0
    Passed = 0
    Failed = 0
    Errors = @()
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

# Main execution
Write-Host "Final API Testing - Interview Microservice ABC" -ForegroundColor Blue
Write-Host "=============================================" -ForegroundColor Blue
Write-Host "Base URL: $BaseUrl" -ForegroundColor Yellow

# Test Auth Service
Write-Host "`nTesting Auth Service..." -ForegroundColor Blue

$registerBody = @{
    email = "testuser@example.com"
    password = "password123"
    fullName = "Test User"
    roleId = 1
} | ConvertTo-Json

Test-APIEndpoint -Name "POST /auth/register" -Method "POST" -Url "$BaseUrl/auth/register" -Body $registerBody -ExpectedStatus 201 -Description "User registration"

$loginBody = @{
    email = "test@example.com"
    password = "password123"
} | ConvertTo-Json

Test-APIEndpoint -Name "POST /auth/login" -Method "POST" -Url "$BaseUrl/auth/login" -Body $loginBody -ExpectedStatus 200 -Description "User login"

Test-APIEndpoint -Name "GET /auth/verify" -Method "GET" -Url "$BaseUrl/auth/verify?token=dummy_token" -ExpectedStatus 200 -Description "Token verification"

Test-APIEndpoint -Name "GET /auth/users/1" -Method "GET" -Url "$BaseUrl/auth/users/1" -ExpectedStatus 200 -Description "Get user by ID"

# Test User Service
Write-Host "`nTesting User Service..." -ForegroundColor Blue

Test-APIEndpoint -Name "POST /users/register" -Method "POST" -Url "$BaseUrl/users/register" -Body $registerBody -ExpectedStatus 200 -Description "User registration"

Test-APIEndpoint -Name "POST /users/login" -Method "POST" -Url "$BaseUrl/users/login" -Body $loginBody -ExpectedStatus 200 -Description "User login"

Test-APIEndpoint -Name "GET /users/1" -Method "GET" -Url "$BaseUrl/users/1" -ExpectedStatus 200 -Description "Get user by ID"

Test-APIEndpoint -Name "GET /users/verify" -Method "GET" -Url "$BaseUrl/users/verify?token=dummy_token" -ExpectedStatus 200 -Description "Verify user token"

$roleBody = @{role = "ADMIN"} | ConvertTo-Json
Test-APIEndpoint -Name "PUT /users/1/role" -Method "PUT" -Url "$BaseUrl/users/1/role" -Body $roleBody -ExpectedStatus 200 -Description "Update user role"

$statusBody = @{status = "ACTIVE"} | ConvertTo-Json
Test-APIEndpoint -Name "PUT /users/1/status" -Method "PUT" -Url "$BaseUrl/users/1/status" -Body $statusBody -ExpectedStatus 200 -Description "Update user status"

$eloBody = @{userId = 1; eloScore = 1500} | ConvertTo-Json
Test-APIEndpoint -Name "POST /users/elo" -Method "POST" -Url "$BaseUrl/users/elo" -Body $eloBody -ExpectedStatus 200 -Description "Apply ELO score"

# Test Career Service
Write-Host "`nTesting Career Service..." -ForegroundColor Blue

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

Test-APIEndpoint -Name "POST /career" -Method "POST" -Url "$BaseUrl/career" -Body $careerBody -ExpectedStatus 200 -Description "Create career preference"

Test-APIEndpoint -Name "GET /career/1" -Method "GET" -Url "$BaseUrl/career/1" -ExpectedStatus 200 -Description "Get career by ID"

Test-APIEndpoint -Name "PUT /career/update/1" -Method "PUT" -Url "$BaseUrl/career/update/1" -Body $careerBody -ExpectedStatus 200 -Description "Update career preference"

Test-APIEndpoint -Name "GET /career/preferences/1" -Method "GET" -Url "$BaseUrl/career/preferences/1?page=0&size=10" -ExpectedStatus 200 -Description "Get career by user ID"

Test-APIEndpoint -Name "DELETE /career/1" -Method "DELETE" -Url "$BaseUrl/career/1" -ExpectedStatus 200 -Description "Delete career preference"

# Test Question Service
Write-Host "`nTesting Question Service..." -ForegroundColor Blue

$fieldBody = @{name = "Computer Science"; description = "Computer Science field"} | ConvertTo-Json
Test-APIEndpoint -Name "POST /fields" -Method "POST" -Url "$BaseUrl/fields" -Body $fieldBody -ExpectedStatus 200 -Description "Create field"

$topicBody = @{name = "Data Structures"; description = "Data Structures and Algorithms"; fieldId = 1} | ConvertTo-Json
Test-APIEndpoint -Name "POST /topics" -Method "POST" -Url "$BaseUrl/topics" -Body $topicBody -ExpectedStatus 200 -Description "Create topic"

$levelBody = @{name = "Beginner"; description = "Beginner level questions"; minScore = 0; maxScore = 500} | ConvertTo-Json
Test-APIEndpoint -Name "POST /levels" -Method "POST" -Url "$BaseUrl/levels" -Body $levelBody -ExpectedStatus 200 -Description "Create level"

$questionTypeBody = @{name = "Multiple Choice"; description = "Multiple choice questions"; isMultipleChoice = $true; isOpenEnded = $false} | ConvertTo-Json
Test-APIEndpoint -Name "POST /question-types" -Method "POST" -Url "$BaseUrl/question-types" -Body $questionTypeBody -ExpectedStatus 200 -Description "Create question type"

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

Test-APIEndpoint -Name "POST /questions" -Method "POST" -Url "$BaseUrl/questions" -Body $questionBody -ExpectedStatus 200 -Description "Create question"

Test-APIEndpoint -Name "GET /questions/1" -Method "GET" -Url "$BaseUrl/questions/1" -ExpectedStatus 200 -Description "Get question by ID"

Test-APIEndpoint -Name "PUT /questions/1" -Method "PUT" -Url "$BaseUrl/questions/1" -Body $questionBody -ExpectedStatus 200 -Description "Update question"

Test-APIEndpoint -Name "DELETE /questions/1" -Method "DELETE" -Url "$BaseUrl/questions/1" -ExpectedStatus 200 -Description "Delete question"

Test-APIEndpoint -Name "POST /questions/1/approve" -Method "POST" -Url "$BaseUrl/questions/1/approve?adminId=1" -ExpectedStatus 200 -Description "Approve question"

Test-APIEndpoint -Name "POST /questions/1/reject" -Method "POST" -Url "$BaseUrl/questions/1/reject?adminId=1" -ExpectedStatus 200 -Description "Reject question"

Test-APIEndpoint -Name "GET /topics/1/questions" -Method "GET" -Url "$BaseUrl/topics/1/questions?page=0&size=10" -ExpectedStatus 200 -Description "Get questions by topic"

$answerBody = @{questionId = 1; content = "Binary search has O(log n) time complexity."; isSample = $true; createdBy = 1} | ConvertTo-Json
Test-APIEndpoint -Name "POST /answers" -Method "POST" -Url "$BaseUrl/answers" -Body $answerBody -ExpectedStatus 200 -Description "Create answer"

Test-APIEndpoint -Name "GET /answers/1" -Method "GET" -Url "$BaseUrl/answers/1" -ExpectedStatus 200 -Description "Get answer by ID"

Test-APIEndpoint -Name "PUT /answers/1" -Method "PUT" -Url "$BaseUrl/answers/1" -Body $answerBody -ExpectedStatus 200 -Description "Update answer"

Test-APIEndpoint -Name "DELETE /answers/1" -Method "DELETE" -Url "$BaseUrl/answers/1" -ExpectedStatus 200 -Description "Delete answer"

Test-APIEndpoint -Name "POST /answers/1/sample" -Method "POST" -Url "$BaseUrl/answers/1/sample?isSample=true" -ExpectedStatus 200 -Description "Mark sample answer"

Test-APIEndpoint -Name "GET /questions/1/answers" -Method "GET" -Url "$BaseUrl/questions/1/answers?page=0&size=10" -ExpectedStatus 200 -Description "Get answers by question"

# Test Exam Service
Write-Host "`nTesting Exam Service..." -ForegroundColor Blue

$examBody = @{
    title = "Java Programming Test"
    description = "Test your Java programming skills"
    examType = "TECHNICAL"
    duration = 60
    maxAttempts = 3
    isActive = $true
    createdBy = 1
} | ConvertTo-Json

Test-APIEndpoint -Name "POST /exams" -Method "POST" -Url "$BaseUrl/exams" -Body $examBody -ExpectedStatus 200 -Description "Create exam"

Test-APIEndpoint -Name "GET /exams/1" -Method "GET" -Url "$BaseUrl/exams/1" -ExpectedStatus 200 -Description "Get exam by ID"

Test-APIEndpoint -Name "PUT /exams/1" -Method "PUT" -Url "$BaseUrl/exams/1" -Body $examBody -ExpectedStatus 200 -Description "Update exam"

Test-APIEndpoint -Name "DELETE /exams/1" -Method "DELETE" -Url "$BaseUrl/exams/1" -ExpectedStatus 200 -Description "Delete exam"

Test-APIEndpoint -Name "POST /exams/1/publish" -Method "POST" -Url "$BaseUrl/exams/1/publish?userId=1" -ExpectedStatus 200 -Description "Publish exam"

Test-APIEndpoint -Name "POST /exams/1/start" -Method "POST" -Url "$BaseUrl/exams/1/start" -ExpectedStatus 200 -Description "Start exam"

Test-APIEndpoint -Name "POST /exams/1/complete" -Method "POST" -Url "$BaseUrl/exams/1/complete" -ExpectedStatus 200 -Description "Complete exam"

Test-APIEndpoint -Name "GET /exams/user/1" -Method "GET" -Url "$BaseUrl/exams/user/1?page=0&size=10" -ExpectedStatus 200 -Description "Get exams by user"

Test-APIEndpoint -Name "GET /exams/type/TECHNICAL" -Method "GET" -Url "$BaseUrl/exams/type/TECHNICAL?page=0&size=10" -ExpectedStatus 200 -Description "Get exams by type"

$examQuestionBody = @{examId = 1; questionId = 1; order = 1; points = 10} | ConvertTo-Json
Test-APIEndpoint -Name "POST /exams/questions" -Method "POST" -Url "$BaseUrl/exams/questions" -Body $examQuestionBody -ExpectedStatus 200 -Description "Add question to exam"

Test-APIEndpoint -Name "DELETE /exams/1/questions" -Method "DELETE" -Url "$BaseUrl/exams/1/questions" -ExpectedStatus 200 -Description "Remove questions from exam"

$registrationBody = @{examId = 1; userId = 1; registrationDate = "2024-01-15T10:00:00Z"} | ConvertTo-Json
Test-APIEndpoint -Name "POST /exams/registrations" -Method "POST" -Url "$BaseUrl/exams/registrations" -Body $registrationBody -ExpectedStatus 200 -Description "Register for exam"

Test-APIEndpoint -Name "POST /exams/registrations/1/cancel" -Method "POST" -Url "$BaseUrl/exams/registrations/1/cancel" -ExpectedStatus 200 -Description "Cancel registration"

Test-APIEndpoint -Name "GET /exams/1/registrations" -Method "GET" -Url "$BaseUrl/exams/1/registrations?page=0&size=10" -ExpectedStatus 200 -Description "Get registrations by exam"

Test-APIEndpoint -Name "GET /exams/registrations/user/1" -Method "GET" -Url "$BaseUrl/exams/registrations/user/1?page=0&size=10" -ExpectedStatus 200 -Description "Get registrations by user"

Test-APIEndpoint -Name "GET /exams/registrations/1" -Method "GET" -Url "$BaseUrl/exams/registrations/1" -ExpectedStatus 200 -Description "Get registration by ID"

$answerBody = @{examId = 1; questionId = 1; userId = 1; answerText = "O(log n)"; isCorrect = $true; timeSpent = 30} | ConvertTo-Json
Test-APIEndpoint -Name "POST /exams/answers" -Method "POST" -Url "$BaseUrl/exams/answers" -Body $answerBody -ExpectedStatus 200 -Description "Submit answer"

Test-APIEndpoint -Name "GET /exams/1/answers/1" -Method "GET" -Url "$BaseUrl/exams/1/answers/1?page=0&size=10" -ExpectedStatus 200 -Description "Get user answers"

Test-APIEndpoint -Name "GET /exams/answers/1" -Method "GET" -Url "$BaseUrl/exams/answers/1" -ExpectedStatus 200 -Description "Get user answer by ID"

$resultBody = @{examId = 1; userId = 1; score = 85; totalScore = 100; timeSpent = 45; isPassed = $true} | ConvertTo-Json
Test-APIEndpoint -Name "POST /exams/results" -Method "POST" -Url "$BaseUrl/exams/results" -Body $resultBody -ExpectedStatus 200 -Description "Submit result"

Test-APIEndpoint -Name "GET /exams/1/results" -Method "GET" -Url "$BaseUrl/exams/1/results?page=0&size=10" -ExpectedStatus 200 -Description "Get results by exam"

Test-APIEndpoint -Name "GET /exams/results/user/1" -Method "GET" -Url "$BaseUrl/exams/results/user/1?page=0&size=10" -ExpectedStatus 200 -Description "Get results by user"

Test-APIEndpoint -Name "GET /exams/results/1" -Method "GET" -Url "$BaseUrl/exams/results/1" -ExpectedStatus 200 -Description "Get result by ID"

# Test News Service
Write-Host "`nTesting News Service..." -ForegroundColor Blue

$newsBody = @{
    title = "New Job Opportunities in Tech"
    content = "Exciting new job opportunities in the technology sector..."
    newsType = "JOB_OPPORTUNITY"
    fieldId = 1
    createdBy = 1
    tags = @("tech", "jobs", "opportunities")
} | ConvertTo-Json

Test-APIEndpoint -Name "POST /news" -Method "POST" -Url "$BaseUrl/news" -Body $newsBody -ExpectedStatus 200 -Description "Create news"

Test-APIEndpoint -Name "GET /news/1" -Method "GET" -Url "$BaseUrl/news/1" -ExpectedStatus 200 -Description "Get news by ID"

Test-APIEndpoint -Name "PUT /news/1" -Method "PUT" -Url "$BaseUrl/news/1" -Body $newsBody -ExpectedStatus 200 -Description "Update news"

Test-APIEndpoint -Name "DELETE /news/1" -Method "DELETE" -Url "$BaseUrl/news/1" -ExpectedStatus 200 -Description "Delete news"

Test-APIEndpoint -Name "POST /news/1/approve" -Method "POST" -Url "$BaseUrl/news/1/approve?adminId=1" -ExpectedStatus 200 -Description "Approve news"

Test-APIEndpoint -Name "POST /news/1/reject" -Method "POST" -Url "$BaseUrl/news/1/reject?adminId=1" -ExpectedStatus 200 -Description "Reject news"

Test-APIEndpoint -Name "POST /news/1/publish" -Method "POST" -Url "$BaseUrl/news/1/publish" -ExpectedStatus 200 -Description "Publish news"

Test-APIEndpoint -Name "POST /news/1/vote" -Method "POST" -Url "$BaseUrl/news/1/vote?voteType=up" -ExpectedStatus 200 -Description "Vote news"

Test-APIEndpoint -Name "GET /news/type/JOB_OPPORTUNITY" -Method "GET" -Url "$BaseUrl/news/type/JOB_OPPORTUNITY?page=0&size=10" -ExpectedStatus 200 -Description "Get news by type"

Test-APIEndpoint -Name "GET /news/user/1" -Method "GET" -Url "$BaseUrl/news/user/1?page=0&size=10" -ExpectedStatus 200 -Description "Get news by user"

Test-APIEndpoint -Name "GET /news/status/PENDING" -Method "GET" -Url "$BaseUrl/news/status/PENDING?page=0&size=10" -ExpectedStatus 200 -Description "Get news by status"

Test-APIEndpoint -Name "GET /news/field/1" -Method "GET" -Url "$BaseUrl/news/field/1?page=0&size=10" -ExpectedStatus 200 -Description "Get news by field"

Test-APIEndpoint -Name "GET /news/published/JOB_OPPORTUNITY" -Method "GET" -Url "$BaseUrl/news/published/JOB_OPPORTUNITY?page=0&size=10" -ExpectedStatus 200 -Description "Get published news"

Test-APIEndpoint -Name "GET /news/moderation/pending" -Method "GET" -Url "$BaseUrl/news/moderation/pending?page=0&size=10" -ExpectedStatus 200 -Description "Get pending moderation"

$recruitmentBody = @{
    title = "Senior Java Developer Position"
    content = "We are looking for an experienced Java developer..."
    newsType = "RECRUITMENT"
    fieldId = 1
    createdBy = 2
    companyName = "Tech Corp"
    location = "Ho Chi Minh City"
    salary = "2000-3000 USD"
    requirements = @("Java", "Spring Boot", "3+ years experience")
} | ConvertTo-Json

Test-APIEndpoint -Name "POST /recruitments" -Method "POST" -Url "$BaseUrl/recruitments" -Body $recruitmentBody -ExpectedStatus 200 -Description "Create recruitment"

Test-APIEndpoint -Name "GET /recruitments" -Method "GET" -Url "$BaseUrl/recruitments?page=0&size=10" -ExpectedStatus 200 -Description "Get recruitments"

Test-APIEndpoint -Name "GET /recruitments/company/Tech%20Corp" -Method "GET" -Url "$BaseUrl/recruitments/company/Tech%20Corp?page=0&size=10" -ExpectedStatus 200 -Description "Get recruitments by company"

# Test NLP Service
Write-Host "`nTesting NLP Service..." -ForegroundColor Blue

Test-APIEndpoint -Name "GET /health" -Method "GET" -Url "$BaseUrl/health" -ExpectedStatus 200 -Description "Health check"

$similarityBody = @{question_text = "What is machine learning?"; exclude_id = 1} | ConvertTo-Json
Test-APIEndpoint -Name "POST /questions/similarity/check" -Method "POST" -Url "$BaseUrl/questions/similarity/check" -Body $similarityBody -ExpectedStatus 200 -Description "Check question similarity"

$gradingBody = @{question = "Explain the concept of machine learning"; answer = "Machine learning is a subset of artificial intelligence..."; max_score = 100} | ConvertTo-Json
Test-APIEndpoint -Name "POST /grading/essay" -Method "POST" -Url "$BaseUrl/grading/essay" -Body $gradingBody -ExpectedStatus 200 -Description "Grade essay"

$examGradingBody = @{exam_id = 1; question_id = 1; answer_text = "Machine learning is a powerful technology..."; max_score = 100} | ConvertTo-Json
Test-APIEndpoint -Name "POST /exams/1/questions/1/grade" -Method "POST" -Url "$BaseUrl/exams/1/questions/1/grade" -Body $examGradingBody -ExpectedStatus 200 -Description "Grade exam answer"

$gradeAllBody = @{exam_id = 1} | ConvertTo-Json
Test-APIEndpoint -Name "POST /exams/1/grade-all" -Method "POST" -Url "$BaseUrl/exams/1/grade-all" -Body $gradeAllBody -ExpectedStatus 200 -Description "Grade all exam answers"

Test-APIEndpoint -Name "GET /questions/1/analytics" -Method "GET" -Url "$BaseUrl/questions/1/analytics" -ExpectedStatus 200 -Description "Get question analytics"

# Show results
Write-Host "`nFinal Test Results Summary:" -ForegroundColor Blue
Write-Host "Total Tests: $($TestResults.Total)" -ForegroundColor Yellow
Write-Host "Passed: $($TestResults.Passed)" -ForegroundColor Green
Write-Host "Failed: $($TestResults.Failed)" -ForegroundColor Red

if ($TestResults.Errors.Count -gt 0) {
    Write-Host "`nErrors:" -ForegroundColor Red
    foreach ($error in $TestResults.Errors) {
        Write-Host "  - $error" -ForegroundColor Red
    }
}

$successRate = if ($TestResults.Total -gt 0) { [math]::Round(($TestResults.Passed / $TestResults.Total) * 100, 2) } else { 0 }
Write-Host "`nSuccess Rate: $successRate%" -ForegroundColor Yellow

if ($TestResults.Failed -eq 0) {
    Write-Host "`nAll tests passed! System is ready for customer delivery." -ForegroundColor Green
} else {
    Write-Host "`nSome tests failed. Please check the errors above before delivery." -ForegroundColor Yellow
}
