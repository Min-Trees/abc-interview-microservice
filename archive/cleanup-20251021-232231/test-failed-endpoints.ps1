# Test các endpoint failed để tìm nguyên nhân
$baseUrl = "http://localhost:8080"

Write-Host "`n========= Testing Failed Endpoints =========" -ForegroundColor Cyan

# 1. Login để lấy token
Write-Host "`n[1] Login to get token..." -ForegroundColor Yellow
$loginBody = @{
    email = "admin@example.com"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResp = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    $token = $loginResp.accessToken
    Write-Host "  [OK] Token: $($token.Substring(0,20))..." -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Login failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
}

# 2. Test GET /auth/user-info
Write-Host "`n[2] Test GET /auth/user-info" -ForegroundColor Yellow
try {
    $userInfo = Invoke-RestMethod -Uri "$baseUrl/auth/user-info" -Method GET -Headers $headers
    Write-Host "  [OK] User info: $($userInfo | ConvertTo-Json -Compress)" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "  Message: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Test GET /questions/1 (kiểm tra xem có question id=1 không)
Write-Host "`n[3] Test GET /questions (check available questions)" -ForegroundColor Yellow
try {
    $questions = Invoke-RestMethod -Uri "$baseUrl/questions?page=0&size=5" -Method GET
    Write-Host "  [OK] Total questions: $($questions.totalElements)" -ForegroundColor Green
    if ($questions.content.Count -gt 0) {
        $firstId = $questions.content[0].id
        Write-Host "  First question ID: $firstId" -ForegroundColor Gray
        
        # Test GET by ID
        Write-Host "`n[4] Test GET /questions/$firstId" -ForegroundColor Yellow
        try {
            $question = Invoke-RestMethod -Uri "$baseUrl/questions/$firstId" -Method GET
            Write-Host "  [OK] Question: $($question.content)" -ForegroundColor Green
        } catch {
            Write-Host "  [ERROR] Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
            Write-Host "  Message: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  [WARN] No questions found. Cannot test GET by ID" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  [ERROR] Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
}

# 5. Test POST /questions (create question)
Write-Host "`n[5] Test POST /questions (create)" -ForegroundColor Yellow
$questionBody = @{
    userId = 1
    topicId = 1
    fieldId = 1
    levelId = 1
    questionTypeId = 1
    content = "What is PowerShell?"
    answer = "PowerShell is a task automation and configuration management framework"
    language = "Vietnamese"
} | ConvertTo-Json

try {
    $newQuestion = Invoke-RestMethod -Uri "$baseUrl/questions" -Method POST -Body $questionBody -ContentType "application/json" -Headers $headers
    Write-Host "  [OK] Created question ID: $($newQuestion.id)" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    $errorBody = $_.ErrorDetails.Message
    Write-Host "  Details: $errorBody" -ForegroundColor Red
}

# 6. Test GET /exams (check available exams)
Write-Host "`n[6] Test GET /exams (check available)" -ForegroundColor Yellow
try {
    $exams = Invoke-RestMethod -Uri "$baseUrl/exams?page=0&size=5" -Method GET
    Write-Host "  [OK] Total exams: $($exams.totalElements)" -ForegroundColor Green
    if ($exams.content.Count -gt 0) {
        $firstExamId = $exams.content[0].id
        Write-Host "  First exam ID: $firstExamId" -ForegroundColor Gray
        
        # Test GET by ID
        Write-Host "`n[7] Test GET /exams/$firstExamId" -ForegroundColor Yellow
        try {
            $exam = Invoke-RestMethod -Uri "$baseUrl/exams/$firstExamId" -Method GET -Headers $headers
            Write-Host "  [OK] Exam: $($exam.title)" -ForegroundColor Green
        } catch {
            Write-Host "  [ERROR] Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
            Write-Host "  Message: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  [WARN] No exams found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  [ERROR] Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
}

# 8. Test POST /exams (create exam)
Write-Host "`n[8] Test POST /exams (create)" -ForegroundColor Yellow
$examBody = @{
    userId = 1
    examType = "VIRTUAL"
    title = "PowerShell Test"
    position = "Developer"
    topics = @(1)
    questionTypes = @(1)
    questionCount = 5
    duration = 30
    language = "Vietnamese"
} | ConvertTo-Json

try {
    $newExam = Invoke-RestMethod -Uri "$baseUrl/exams" -Method POST -Body $examBody -ContentType "application/json" -Headers $headers
    Write-Host "  [OK] Created exam ID: $($newExam.id)" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    $errorBody = $_.ErrorDetails.Message
    Write-Host "  Details: $errorBody" -ForegroundColor Red
}

# 9. Test GET /news (check available)
Write-Host "`n[9] Test GET /news (check available)" -ForegroundColor Yellow
try {
    $news = Invoke-RestMethod -Uri "$baseUrl/news?page=0&size=5" -Method GET
    Write-Host "  [OK] Total news: $($news.totalElements)" -ForegroundColor Green
    if ($news.content.Count -gt 0) {
        $firstNewsId = $news.content[0].id
        Write-Host "  First news ID: $firstNewsId" -ForegroundColor Gray
        
        # Test GET by ID
        Write-Host "`n[10] Test GET /news/$firstNewsId" -ForegroundColor Yellow
        try {
            $newsItem = Invoke-RestMethod -Uri "$baseUrl/news/$firstNewsId" -Method GET
            Write-Host "  [OK] News: $($newsItem.title)" -ForegroundColor Green
        } catch {
            Write-Host "  [ERROR] Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
            Write-Host "  Message: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  [WARN] No news found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  [ERROR] Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
}

Write-Host "`n========= Test Complete =========" -ForegroundColor Cyan
