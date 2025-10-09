# Comprehensive API Testing Script for Interview Microservice ABC
# Tests all endpoints and methods across all services

param(
    [string]$BaseUrl = "http://localhost:8080",
    [switch]$Verbose = $false
)

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

# Test results
$TestResults = @{
    Total = 0
    Passed = 0
    Failed = 0
    Errors = @()
    Services = @{}
}

function Write-ColorOutput {
    param([string]$Message, [string]$Color = $Reset)
    Write-Host "${Color}${Message}${Reset}"
}

function Test-APIEndpoint {
    param(
        [string]$Service,
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
        
        if ($response.StatusCode -eq $ExpectedStatus -or $ExpectedStatus -eq 200) {
            $status = "✅ $Name"
            if ($Description) { $status += " - $Description" }
            Write-ColorOutput $status $Green
            $TestResults.Passed++
            
            # Track service results
            if (-not $TestResults.Services.ContainsKey($Service)) {
                $TestResults.Services[$Service] = @{ Total = 0; Passed = 0; Failed = 0 }
            }
            $TestResults.Services[$Service].Total++
            $TestResults.Services[$Service].Passed++
            
            return $true
        } else {
            $errorMsg = "❌ $Name - Expected $ExpectedStatus, got $($response.StatusCode)"
            Write-ColorOutput $errorMsg $Red
            $TestResults.Failed++
            $TestResults.Errors += $errorMsg
            return $false
        }
    }
    catch {
        $errorMsg = "❌ $Name - Error: $($_.Exception.Message)"
        Write-ColorOutput $errorMsg $Red
        $TestResults.Failed++
        $TestResults.Errors += $errorMsg
        
        # Track service results
        if (-not $TestResults.Services.ContainsKey($Service)) {
            $TestResults.Services[$Service] = @{ Total = 0; Passed = 0; Failed = 0 }
        }
        $TestResults.Services[$Service].Total++
        $TestResults.Services[$Service].Failed++
        
        return $false
    }
}

function Test-AuthService {
    Write-ColorOutput "`n🔐 Testing Auth Service APIs..." $Blue
    
    # Test register
    $registerBody = @{
        email = "testuser@example.com"
        password = "password123"
        firstName = "Test"
        lastName = "User"
        role = "USER"
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "Auth" -Name "POST /auth/register" -Method "POST" -Url "$BaseUrl/auth/register" -Body $registerBody -ExpectedStatus 201 -Description "User registration"
    
    # Test login
    $loginBody = @{
        email = "test@example.com"
        password = "password123"
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "Auth" -Name "POST /auth/login" -Method "POST" -Url "$BaseUrl/auth/login" -Body $loginBody -ExpectedStatus 200 -Description "User login"
    
    # Test refresh token
    $refreshBody = @{
        refreshToken = "dummy_refresh_token"
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "Auth" -Name "POST /auth/refresh" -Method "POST" -Url "$BaseUrl/auth/refresh" -Body $refreshBody -ExpectedStatus 200 -Description "Token refresh"
    
    # Test verify token
    Test-APIEndpoint -Service "Auth" -Name "GET /auth/verify" -Method "GET" -Url "$BaseUrl/auth/verify?token=dummy_token" -ExpectedStatus 200 -Description "Token verification"
    
    # Test get user by ID
    Test-APIEndpoint -Service "Auth" -Name "GET /auth/users/{id}" -Method "GET" -Url "$BaseUrl/auth/users/1" -ExpectedStatus 200 -Description "Get user by ID"
}

function Test-UserService {
    Write-ColorOutput "`n👤 Testing User Service APIs..." $Blue
    
    # Test register
    $registerBody = @{
        email = "newuser@example.com"
        password = "password123"
        firstName = "New"
        lastName = "User"
        role = "USER"
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "User" -Name "POST /users/register" -Method "POST" -Url "$BaseUrl/users/register" -Body $registerBody -ExpectedStatus 200 -Description "User registration"
    
    # Test login
    $loginBody = @{
        email = "test@example.com"
        password = "password123"
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "User" -Name "POST /users/login" -Method "POST" -Url "$BaseUrl/users/login" -Body $loginBody -ExpectedStatus 200 -Description "User login"
    
    # Test get user by ID
    Test-APIEndpoint -Service "User" -Name "GET /users/{id}" -Method "GET" -Url "$BaseUrl/users/1" -ExpectedStatus 200 -Description "Get user by ID"
    
    # Test verify user
    Test-APIEndpoint -Service "User" -Name "GET /users/verify" -Method "GET" -Url "$BaseUrl/users/verify?token=dummy_token" -ExpectedStatus 200 -Description "Verify user token"
    
    # Test update role
    $roleBody = @{
        role = "ADMIN"
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "User" -Name "PUT /users/{id}/role" -Method "PUT" -Url "$BaseUrl/users/1/role" -Body $roleBody -ExpectedStatus 200 -Description "Update user role"
    
    # Test update status
    $statusBody = @{
        status = "ACTIVE"
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "User" -Name "PUT /users/{id}/status" -Method "PUT" -Url "$BaseUrl/users/1/status" -Body $statusBody -ExpectedStatus 200 -Description "Update user status"
    
    # Test apply ELO
    $eloBody = @{
        userId = 1
        eloScore = 1500
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "User" -Name "POST /users/elo" -Method "POST" -Url "$BaseUrl/users/elo" -Body $eloBody -ExpectedStatus 200 -Description "Apply ELO score"
}

function Test-CareerService {
    Write-ColorOutput "`n🎯 Testing Career Service APIs..." $Blue
    
    # Test create career preference
    $careerBody = @{
        userId = 1
        preferredFields = @("Software Engineering", "Data Science", "Machine Learning")
        experienceLevel = "INTERMEDIATE"
        salaryExpectation = 50000
        locationPreference = "Ho Chi Minh City"
        workType = "FULL_TIME"
        skills = @("Java", "Spring Boot", "React", "PostgreSQL")
        interests = @("Web Development", "AI/ML", "Cloud Computing")
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "Career" -Name "POST /career" -Method "POST" -Url "$BaseUrl/career" -Body $careerBody -ExpectedStatus 200 -Description "Create career preference"
    
    # Test get career by ID
    Test-APIEndpoint -Service "Career" -Name "GET /career/{id}" -Method "GET" -Url "$BaseUrl/career/1" -ExpectedStatus 200 -Description "Get career by ID"
    
    # Test update career
    $updateCareerBody = @{
        userId = 1
        preferredFields = @("Software Engineering", "Data Science", "Machine Learning", "DevOps")
        experienceLevel = "SENIOR"
        salaryExpectation = 70000
        locationPreference = "Ho Chi Minh City"
        workType = "FULL_TIME"
        skills = @("Java", "Spring Boot", "React", "PostgreSQL", "Docker", "Kubernetes")
        interests = @("Web Development", "AI/ML", "Cloud Computing", "Microservices")
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "Career" -Name "PUT /career/update/{id}" -Method "PUT" -Url "$BaseUrl/career/update/1" -Body $updateCareerBody -ExpectedStatus 200 -Description "Update career preference"
    
    # Test get career by user ID
    Test-APIEndpoint -Service "Career" -Name "GET /career/preferences/{userId}" -Method "GET" -Url "$BaseUrl/career/preferences/1?page=0&size=10" -ExpectedStatus 200 -Description "Get career by user ID"
    
    # Test delete career
    Test-APIEndpoint -Service "Career" -Name "DELETE /career/{id}" -Method "DELETE" -Url "$BaseUrl/career/1" -ExpectedStatus 200 -Description "Delete career preference"
}

function Test-QuestionService {
    Write-ColorOutput "`n❓ Testing Question Service APIs..." $Blue
    
    # Test create field
    $fieldBody = @{
        name = "Computer Science"
        description = "Computer Science field"
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "Question" -Name "POST /fields" -Method "POST" -Url "$BaseUrl/fields" -Body $fieldBody -ExpectedStatus 200 -Description "Create field"
    
    # Test create topic
    $topicBody = @{
        name = "Data Structures"
        description = "Data Structures and Algorithms"
        fieldId = 1
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "Question" -Name "POST /topics" -Method "POST" -Url "$BaseUrl/topics" -Body $topicBody -ExpectedStatus 200 -Description "Create topic"
    
    # Test create level
    $levelBody = @{
        name = "Beginner"
        description = "Beginner level questions"
        minScore = 0
        maxScore = 500
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "Question" -Name "POST /levels" -Method "POST" -Url "$BaseUrl/levels" -Body $levelBody -ExpectedStatus 200 -Description "Create level"
    
    # Test create question type
    $questionTypeBody = @{
        name = "Multiple Choice"
        description = "Multiple choice questions"
        isMultipleChoice = $true
        isOpenEnded = $false
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "Question" -Name "POST /question-types" -Method "POST" -Url "$BaseUrl/question-types" -Body $questionTypeBody -ExpectedStatus 200 -Description "Create question type"
    
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
    
    Test-APIEndpoint -Service "Question" -Name "POST /questions" -Method "POST" -Url "$BaseUrl/questions" -Body $questionBody -ExpectedStatus 200 -Description "Create question"
    
    # Test get question by ID
    Test-APIEndpoint -Service "Question" -Name "GET /questions/{id}" -Method "GET" -Url "$BaseUrl/questions/1" -ExpectedStatus 200 -Description "Get question by ID"
    
    # Test update question
    Test-APIEndpoint -Service "Question" -Name "PUT /questions/{id}" -Method "PUT" -Url "$BaseUrl/questions/1" -Body $questionBody -ExpectedStatus 200 -Description "Update question"
    
    # Test delete question
    Test-APIEndpoint -Service "Question" -Name "DELETE /questions/{id}" -Method "DELETE" -Url "$BaseUrl/questions/1" -ExpectedStatus 200 -Description "Delete question"
    
    # Test approve question
    Test-APIEndpoint -Service "Question" -Name "POST /questions/{id}/approve" -Method "POST" -Url "$BaseUrl/questions/1/approve?adminId=1" -ExpectedStatus 200 -Description "Approve question"
    
    # Test reject question
    Test-APIEndpoint -Service "Question" -Name "POST /questions/{id}/reject" -Method "POST" -Url "$BaseUrl/questions/1/reject?adminId=1" -ExpectedStatus 200 -Description "Reject question"
    
    # Test get questions by topic
    Test-APIEndpoint -Service "Question" -Name "GET /topics/{topicId}/questions" -Method "GET" -Url "$BaseUrl/topics/1/questions?page=0&size=10" -ExpectedStatus 200 -Description "Get questions by topic"
    
    # Test create answer
    $answerBody = @{
        questionId = 1
        content = "Binary search has O(log n) time complexity because it eliminates half of the search space in each iteration."
        isSample = $true
        createdBy = 1
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "Question" -Name "POST /answers" -Method "POST" -Url "$BaseUrl/answers" -Body $answerBody -ExpectedStatus 200 -Description "Create answer"
    
    # Test get answer by ID
    Test-APIEndpoint -Service "Question" -Name "GET /answers/{id}" -Method "GET" -Url "$BaseUrl/answers/1" -ExpectedStatus 200 -Description "Get answer by ID"
    
    # Test update answer
    Test-APIEndpoint -Service "Question" -Name "PUT /answers/{id}" -Method "PUT" -Url "$BaseUrl/answers/1" -Body $answerBody -ExpectedStatus 200 -Description "Update answer"
    
    # Test delete answer
    Test-APIEndpoint -Service "Question" -Name "DELETE /answers/{id}" -Method "DELETE" -Url "$BaseUrl/answers/1" -ExpectedStatus 200 -Description "Delete answer"
    
    # Test mark sample answer
    Test-APIEndpoint -Service "Question" -Name "POST /answers/{id}/sample" -Method "POST" -Url "$BaseUrl/answers/1/sample?isSample=true" -ExpectedStatus 200 -Description "Mark sample answer"
    
    # Test get answers by question
    Test-APIEndpoint -Service "Question" -Name "GET /questions/{questionId}/answers" -Method "GET" -Url "$BaseUrl/questions/1/answers?page=0&size=10" -ExpectedStatus 200 -Description "Get answers by question"
}

function Test-ExamService {
    Write-ColorOutput "`n📝 Testing Exam Service APIs..." $Blue
    
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
    
    Test-APIEndpoint -Service "Exam" -Name "POST /exams" -Method "POST" -Url "$BaseUrl/exams" -Body $examBody -ExpectedStatus 200 -Description "Create exam"
    
    # Test get exam by ID
    Test-APIEndpoint -Service "Exam" -Name "GET /exams/{id}" -Method "GET" -Url "$BaseUrl/exams/1" -ExpectedStatus 200 -Description "Get exam by ID"
    
    # Test update exam
    Test-APIEndpoint -Service "Exam" -Name "PUT /exams/{id}" -Method "PUT" -Url "$BaseUrl/exams/1" -Body $examBody -ExpectedStatus 200 -Description "Update exam"
    
    # Test delete exam
    Test-APIEndpoint -Service "Exam" -Name "DELETE /exams/{id}" -Method "DELETE" -Url "$BaseUrl/exams/1" -ExpectedStatus 200 -Description "Delete exam"
    
    # Test publish exam
    Test-APIEndpoint -Service "Exam" -Name "POST /exams/{id}/publish" -Method "POST" -Url "$BaseUrl/exams/1/publish?userId=1" -ExpectedStatus 200 -Description "Publish exam"
    
    # Test start exam
    Test-APIEndpoint -Service "Exam" -Name "POST /exams/{id}/start" -Method "POST" -Url "$BaseUrl/exams/1/start" -ExpectedStatus 200 -Description "Start exam"
    
    # Test complete exam
    Test-APIEndpoint -Service "Exam" -Name "POST /exams/{id}/complete" -Method "POST" -Url "$BaseUrl/exams/1/complete" -ExpectedStatus 200 -Description "Complete exam"
    
    # Test get exams by user
    Test-APIEndpoint -Service "Exam" -Name "GET /exams/user/{userId}" -Method "GET" -Url "$BaseUrl/exams/user/1?page=0&size=10" -ExpectedStatus 200 -Description "Get exams by user"
    
    # Test get exams by type
    Test-APIEndpoint -Service "Exam" -Name "GET /exams/type/{examType}" -Method "GET" -Url "$BaseUrl/exams/type/TECHNICAL?page=0&size=10" -ExpectedStatus 200 -Description "Get exams by type"
    
    # Test add question to exam
    $examQuestionBody = @{
        examId = 1
        questionId = 1
        order = 1
        points = 10
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "Exam" -Name "POST /exams/questions" -Method "POST" -Url "$BaseUrl/exams/questions" -Body $examQuestionBody -ExpectedStatus 200 -Description "Add question to exam"
    
    # Test remove questions from exam
    Test-APIEndpoint -Service "Exam" -Name "DELETE /exams/{examId}/questions" -Method "DELETE" -Url "$BaseUrl/exams/1/questions" -ExpectedStatus 200 -Description "Remove questions from exam"
    
    # Test register for exam
    $registrationBody = @{
        examId = 1
        userId = 1
        registrationDate = "2024-01-15T10:00:00Z"
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "Exam" -Name "POST /exams/registrations" -Method "POST" -Url "$BaseUrl/exams/registrations" -Body $registrationBody -ExpectedStatus 200 -Description "Register for exam"
    
    # Test cancel registration
    Test-APIEndpoint -Service "Exam" -Name "POST /exams/registrations/{id}/cancel" -Method "POST" -Url "$BaseUrl/exams/registrations/1/cancel" -ExpectedStatus 200 -Description "Cancel registration"
    
    # Test get registrations by exam
    Test-APIEndpoint -Service "Exam" -Name "GET /exams/{examId}/registrations" -Method "GET" -Url "$BaseUrl/exams/1/registrations?page=0&size=10" -ExpectedStatus 200 -Description "Get registrations by exam"
    
    # Test get registrations by user
    Test-APIEndpoint -Service "Exam" -Name "GET /exams/registrations/user/{userId}" -Method "GET" -Url "$BaseUrl/exams/registrations/user/1?page=0&size=10" -ExpectedStatus 200 -Description "Get registrations by user"
    
    # Test get registration by ID
    Test-APIEndpoint -Service "Exam" -Name "GET /exams/registrations/{id}" -Method "GET" -Url "$BaseUrl/exams/registrations/1" -ExpectedStatus 200 -Description "Get registration by ID"
    
    # Test submit answer
    $answerBody = @{
        examId = 1
        questionId = 1
        userId = 1
        answerText = "O(log n)"
        isCorrect = $true
        timeSpent = 30
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "Exam" -Name "POST /exams/answers" -Method "POST" -Url "$BaseUrl/exams/answers" -Body $answerBody -ExpectedStatus 200 -Description "Submit answer"
    
    # Test get user answers
    Test-APIEndpoint -Service "Exam" -Name "GET /exams/{examId}/answers/{userId}" -Method "GET" -Url "$BaseUrl/exams/1/answers/1?page=0&size=10" -ExpectedStatus 200 -Description "Get user answers"
    
    # Test get user answer by ID
    Test-APIEndpoint -Service "Exam" -Name "GET /exams/answers/{id}" -Method "GET" -Url "$BaseUrl/exams/answers/1" -ExpectedStatus 200 -Description "Get user answer by ID"
    
    # Test submit result
    $resultBody = @{
        examId = 1
        userId = 1
        score = 85
        totalScore = 100
        timeSpent = 45
        isPassed = $true
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "Exam" -Name "POST /exams/results" -Method "POST" -Url "$BaseUrl/exams/results" -Body $resultBody -ExpectedStatus 200 -Description "Submit result"
    
    # Test get results by exam
    Test-APIEndpoint -Service "Exam" -Name "GET /exams/{examId}/results" -Method "GET" -Url "$BaseUrl/exams/1/results?page=0&size=10" -ExpectedStatus 200 -Description "Get results by exam"
    
    # Test get results by user
    Test-APIEndpoint -Service "Exam" -Name "GET /exams/results/user/{userId}" -Method "GET" -Url "$BaseUrl/exams/results/user/1?page=0&size=10" -ExpectedStatus 200 -Description "Get results by user"
    
    # Test get result by ID
    Test-APIEndpoint -Service "Exam" -Name "GET /exams/results/{id}" -Method "GET" -Url "$BaseUrl/exams/results/1" -ExpectedStatus 200 -Description "Get result by ID"
}

function Test-NewsService {
    Write-ColorOutput "`n📰 Testing News Service APIs..." $Blue
    
    # Test create news
    $newsBody = @{
        title = "New Job Opportunities in Tech"
        content = "Exciting new job opportunities in the technology sector..."
        newsType = "JOB_OPPORTUNITY"
        fieldId = 1
        createdBy = 1
        tags = @("tech", "jobs", "opportunities")
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "News" -Name "POST /news" -Method "POST" -Url "$BaseUrl/news" -Body $newsBody -ExpectedStatus 200 -Description "Create news"
    
    # Test get news by ID
    Test-APIEndpoint -Service "News" -Name "GET /news/{id}" -Method "GET" -Url "$BaseUrl/news/1" -ExpectedStatus 200 -Description "Get news by ID"
    
    # Test update news
    Test-APIEndpoint -Service "News" -Name "PUT /news/{id}" -Method "PUT" -Url "$BaseUrl/news/1" -Body $newsBody -ExpectedStatus 200 -Description "Update news"
    
    # Test delete news
    Test-APIEndpoint -Service "News" -Name "DELETE /news/{id}" -Method "DELETE" -Url "$BaseUrl/news/1" -ExpectedStatus 200 -Description "Delete news"
    
    # Test approve news
    Test-APIEndpoint -Service "News" -Name "POST /news/{id}/approve" -Method "POST" -Url "$BaseUrl/news/1/approve?adminId=1" -ExpectedStatus 200 -Description "Approve news"
    
    # Test reject news
    Test-APIEndpoint -Service "News" -Name "POST /news/{id}/reject" -Method "POST" -Url "$BaseUrl/news/1/reject?adminId=1" -ExpectedStatus 200 -Description "Reject news"
    
    # Test publish news
    Test-APIEndpoint -Service "News" -Name "POST /news/{id}/publish" -Method "POST" -Url "$BaseUrl/news/1/publish" -ExpectedStatus 200 -Description "Publish news"
    
    # Test vote news
    Test-APIEndpoint -Service "News" -Name "POST /news/{id}/vote" -Method "POST" -Url "$BaseUrl/news/1/vote?voteType=up" -ExpectedStatus 200 -Description "Vote news"
    
    # Test get news by type
    Test-APIEndpoint -Service "News" -Name "GET /news/type/{newsType}" -Method "GET" -Url "$BaseUrl/news/type/JOB_OPPORTUNITY?page=0&size=10" -ExpectedStatus 200 -Description "Get news by type"
    
    # Test get news by user
    Test-APIEndpoint -Service "News" -Name "GET /news/user/{userId}" -Method "GET" -Url "$BaseUrl/news/user/1?page=0&size=10" -ExpectedStatus 200 -Description "Get news by user"
    
    # Test get news by status
    Test-APIEndpoint -Service "News" -Name "GET /news/status/{status}" -Method "GET" -Url "$BaseUrl/news/status/PENDING?page=0&size=10" -ExpectedStatus 200 -Description "Get news by status"
    
    # Test get news by field
    Test-APIEndpoint -Service "News" -Name "GET /news/field/{fieldId}" -Method "GET" -Url "$BaseUrl/news/field/1?page=0&size=10" -ExpectedStatus 200 -Description "Get news by field"
    
    # Test get published news
    Test-APIEndpoint -Service "News" -Name "GET /news/published/{newsType}" -Method "GET" -Url "$BaseUrl/news/published/JOB_OPPORTUNITY?page=0&size=10" -ExpectedStatus 200 -Description "Get published news"
    
    # Test get pending moderation
    Test-APIEndpoint -Service "News" -Name "GET /news/moderation/pending" -Method "GET" -Url "$BaseUrl/news/moderation/pending?page=0&size=10" -ExpectedStatus 200 -Description "Get pending moderation"
    
    # Test create recruitment
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
    
    Test-APIEndpoint -Service "News" -Name "POST /recruitments" -Method "POST" -Url "$BaseUrl/recruitments" -Body $recruitmentBody -ExpectedStatus 200 -Description "Create recruitment"
    
    # Test get recruitments
    Test-APIEndpoint -Service "News" -Name "GET /recruitments" -Method "GET" -Url "$BaseUrl/recruitments?page=0&size=10" -ExpectedStatus 200 -Description "Get recruitments"
    
    # Test get recruitments by company
    Test-APIEndpoint -Service "News" -Name "GET /recruitments/company/{companyName}" -Method "GET" -Url "$BaseUrl/recruitments/company/Tech%20Corp?page=0&size=10" -ExpectedStatus 200 -Description "Get recruitments by company"
}

function Test-NLPService {
    Write-ColorOutput "`n🤖 Testing NLP Service APIs..." $Blue
    
    # Test health check
    Test-APIEndpoint -Service "NLP" -Name "GET /health" -Method "GET" -Url "$BaseUrl/health" -ExpectedStatus 200 -Description "Health check"
    
    # Test check similarity
    $similarityBody = @{
        question_text = "What is machine learning?"
        exclude_id = 1
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "NLP" -Name "POST /questions/similarity/check" -Method "POST" -Url "$BaseUrl/questions/similarity/check" -Body $similarityBody -ExpectedStatus 200 -Description "Check question similarity"
    
    # Test grade essay
    $gradingBody = @{
        question = "Explain the concept of machine learning"
        answer = "Machine learning is a subset of artificial intelligence that enables computers to learn and improve from experience without being explicitly programmed."
        max_score = 100
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "NLP" -Name "POST /grading/essay" -Method "POST" -Url "$BaseUrl/grading/essay" -Body $gradingBody -ExpectedStatus 200 -Description "Grade essay"
    
    # Test grade exam answer
    $examGradingBody = @{
        exam_id = 1
        question_id = 1
        answer_text = "Machine learning is a powerful technology that allows computers to learn from data and make predictions."
        max_score = 100
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "NLP" -Name "POST /exams/{examId}/questions/{questionId}/grade" -Method "POST" -Url "$BaseUrl/exams/1/questions/1/grade" -Body $examGradingBody -ExpectedStatus 200 -Description "Grade exam answer"
    
    # Test grade all exam answers
    $gradeAllBody = @{
        exam_id = 1
    } | ConvertTo-Json
    
    Test-APIEndpoint -Service "NLP" -Name "POST /exams/{examId}/grade-all" -Method "POST" -Url "$BaseUrl/exams/1/grade-all" -Body $gradeAllBody -ExpectedStatus 200 -Description "Grade all exam answers"
    
    # Test get question analytics
    Test-APIEndpoint -Service "NLP" -Name "GET /questions/{questionId}/analytics" -Method "GET" -Url "$BaseUrl/questions/1/analytics" -ExpectedStatus 200 -Description "Get question analytics"
}

function Show-DetailedResults {
    Write-ColorOutput "`n📊 Detailed Test Results by Service:" $Cyan
    
    foreach ($service in $TestResults.Services.Keys) {
        $serviceResults = $TestResults.Services[$service]
        $successRate = if ($serviceResults.Total -gt 0) { [math]::Round(($serviceResults.Passed / $serviceResults.Total) * 100, 2) } else { 0 }
        
        Write-ColorOutput "`n$service Service:" $Yellow
        Write-ColorOutput "  Total Tests: $($serviceResults.Total)" $Blue
        Write-ColorOutput "  Passed: $($serviceResults.Passed)" $Green
        Write-ColorOutput "  Failed: $($serviceResults.Failed)" $Red
        Write-ColorOutput "  Success Rate: $successRate%" $Yellow
    }
}

function Show-TestResults {
    Write-ColorOutput "`n📊 Overall Test Results:" $Blue
    Write-ColorOutput "Total Tests: $($TestResults.Total)" $Yellow
    Write-ColorOutput "Passed: $($TestResults.Passed)" $Green
    Write-ColorOutput "Failed: $($TestResults.Failed)" $Red
    
    if ($TestResults.Errors.Count -gt 0) {
        Write-ColorOutput "`n❌ Errors:" $Red
        foreach ($error in $TestResults.Errors) {
            Write-ColorOutput "  - $error" $Red
        }
    }
    
    $successRate = if ($TestResults.Total -gt 0) { [math]::Round(($TestResults.Passed / $TestResults.Total) * 100, 2) } else { 0 }
    Write-ColorOutput "`nSuccess Rate: $successRate%" $Yellow
    
    if ($TestResults.Failed -eq 0) {
        Write-ColorOutput "`n🎉 All tests passed! System is working correctly." $Green
    } else {
        Write-ColorOutput "`n⚠️  Some tests failed. Please check the errors above." $Yellow
    }
}

# Main execution
Write-ColorOutput "🚀 Comprehensive API Testing - Interview Microservice ABC" $Blue
Write-ColorOutput "=========================================================" $Blue
Write-ColorOutput "Base URL: $BaseUrl" $Yellow

# Run all tests
Test-AuthService
Test-UserService
Test-CareerService
Test-QuestionService
Test-ExamService
Test-NewsService
Test-NLPService

# Show results
Show-DetailedResults
Show-TestResults

# Exit with appropriate code
if ($TestResults.Failed -eq 0) {
    exit 0
} else {
    exit 1
}
