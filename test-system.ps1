# Test System Script for Interview Microservice ABC
# This script tests all services and APIs to ensure the system is working correctly

param(
    [string]$BaseUrl = "http://localhost:8080",
    [switch]$Verbose = $false
)

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Reset = "`e[0m"

# Test results
$TestResults = @{
    Total = 0
    Passed = 0
    Failed = 0
    Errors = @()
}

function Write-ColorOutput {
    param([string]$Message, [string]$Color = $Reset)
    Write-Host "${Color}${Message}${Reset}"
}

function Test-ApiEndpoint {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Url,
        [hashtable]$Headers = @{},
        [string]$Body = $null,
        [int]$ExpectedStatus = 200
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
        
        if ($Verbose) {
            Write-ColorOutput "✅ $Name - Status: $($response.StatusCode)" $Green
        } else {
            Write-ColorOutput "✅ $Name" $Green
        }
        
        $TestResults.Passed++
        return $true
    }
    catch {
        $errorMsg = "❌ $Name - Error: $($_.Exception.Message)"
        Write-ColorOutput $errorMsg $Red
        $TestResults.Failed++
        $TestResults.Errors += $errorMsg
        return $false
    }
}

function Test-HealthChecks {
    Write-ColorOutput "`n🔍 Testing Health Checks..." $Blue
    
    $services = @(
        @{ Name = "Gateway Service"; Url = "http://localhost:8080/actuator/health" },
        @{ Name = "Auth Service"; Url = "http://localhost:8081/actuator/health" },
        @{ Name = "User Service"; Url = "http://localhost:8082/actuator/health" },
        @{ Name = "Career Service"; Url = "http://localhost:8084/actuator/health" },
        @{ Name = "Question Service"; Url = "http://localhost:8085/actuator/health" },
        @{ Name = "Exam Service"; Url = "http://localhost:8086/actuator/health" },
        @{ Name = "News Service"; Url = "http://localhost:8087/actuator/health" },
        @{ Name = "NLP Service"; Url = "http://localhost:8088/health" }
    )
    
    foreach ($service in $services) {
        Test-ApiEndpoint -Name $service.Name -Method "GET" -Url $service.Url
    }
}

function Test-AuthFlow {
    Write-ColorOutput "`n🔐 Testing Authentication Flow..." $Blue
    
    # Test login
    $loginBody = @{
        email = "test@example.com"
        password = "password123"
    } | ConvertTo-Json
    
    $loginResponse = Test-ApiEndpoint -Name "User Login" -Method "POST" -Url "$BaseUrl/auth/login" -Body $loginBody
    
    if ($loginResponse) {
        # Get token from response (this would need to be implemented based on actual response structure)
        Write-ColorOutput "✅ Authentication flow completed" $Green
    }
}

function Test-UserService {
    Write-ColorOutput "`n👤 Testing User Service..." $Blue
    
    # Test user registration
    $registerBody = @{
        email = "testuser@example.com"
        password = "password123"
        firstName = "Test"
        lastName = "User"
        role = "USER"
    } | ConvertTo-Json
    
    Test-ApiEndpoint -Name "User Registration" -Method "POST" -Url "$BaseUrl/users/register" -Body $registerBody
    
    # Test user login
    $loginBody = @{
        email = "test@example.com"
        password = "password123"
    } | ConvertTo-Json
    
    Test-ApiEndpoint -Name "User Login" -Method "POST" -Url "$BaseUrl/users/login" -Body $loginBody
}

function Test-QuestionService {
    Write-ColorOutput "`n❓ Testing Question Service..." $Blue
    
    # Test create field
    $fieldBody = @{
        name = "Computer Science"
        description = "Computer Science field"
    } | ConvertTo-Json
    
    Test-ApiEndpoint -Name "Create Field" -Method "POST" -Url "$BaseUrl/fields" -Body $fieldBody
    
    # Test create topic
    $topicBody = @{
        name = "Data Structures"
        description = "Data Structures and Algorithms"
        fieldId = 1
    } | ConvertTo-Json
    
    Test-ApiEndpoint -Name "Create Topic" -Method "POST" -Url "$BaseUrl/topics" -Body $topicBody
    
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
    
    Test-ApiEndpoint -Name "Create Question" -Method "POST" -Url "$BaseUrl/questions" -Body $questionBody
}

function Test-ExamService {
    Write-ColorOutput "`n📝 Testing Exam Service..." $Blue
    
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
    
    Test-ApiEndpoint -Name "Create Exam" -Method "POST" -Url "$BaseUrl/exams" -Body $examBody
    
    # Test exam registration
    $registrationBody = @{
        examId = 1
        userId = 1
        registrationDate = "2024-01-15T10:00:00Z"
    } | ConvertTo-Json
    
    Test-ApiEndpoint -Name "Register for Exam" -Method "POST" -Url "$BaseUrl/exams/registrations" -Body $registrationBody
}

function Test-CareerService {
    Write-ColorOutput "`n🎯 Testing Career Service..." $Blue
    
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
    
    Test-ApiEndpoint -Name "Create Career Preference" -Method "POST" -Url "$BaseUrl/career" -Body $careerBody
}

function Test-NewsService {
    Write-ColorOutput "`n📰 Testing News Service..." $Blue
    
    # Test create news
    $newsBody = @{
        title = "New Job Opportunities in Tech"
        content = "Exciting new job opportunities in the technology sector..."
        newsType = "JOB_OPPORTUNITY"
        fieldId = 1
        createdBy = 1
        tags = @("tech", "jobs", "opportunities")
    } | ConvertTo-Json
    
    Test-ApiEndpoint -Name "Create News" -Method "POST" -Url "$BaseUrl/news" -Body $newsBody
    
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
    
    Test-ApiEndpoint -Name "Create Recruitment" -Method "POST" -Url "$BaseUrl/recruitments" -Body $recruitmentBody
}

function Test-NLPService {
    Write-ColorOutput "`n🤖 Testing NLP Service..." $Blue
    
    # Test similarity check
    $similarityBody = @{
        question_text = "What is machine learning?"
        exclude_id = 1
    } | ConvertTo-Json
    
    Test-ApiEndpoint -Name "Check Question Similarity" -Method "POST" -Url "$BaseUrl/questions/similarity/check" -Body $similarityBody
    
    # Test essay grading
    $gradingBody = @{
        question = "Explain the concept of machine learning"
        answer = "Machine learning is a subset of artificial intelligence that enables computers to learn and improve from experience without being explicitly programmed."
        max_score = 100
    } | ConvertTo-Json
    
    Test-ApiEndpoint -Name "Grade Essay" -Method "POST" -Url "$BaseUrl/grading/essay" -Body $gradingBody
}

function Show-TestResults {
    Write-ColorOutput "`n📊 Test Results Summary:" $Blue
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
Write-ColorOutput "🚀 Starting Interview Microservice ABC System Tests..." $Blue
Write-ColorOutput "Base URL: $BaseUrl" $Yellow

# Run all tests
Test-HealthChecks
Test-AuthFlow
Test-UserService
Test-QuestionService
Test-ExamService
Test-CareerService
Test-NewsService
Test-NLPService

# Show results
Show-TestResults

# Exit with appropriate code
if ($TestResults.Failed -eq 0) {
    exit 0
} else {
    exit 1
}
