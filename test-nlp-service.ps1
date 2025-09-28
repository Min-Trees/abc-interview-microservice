# Test NLP Service Script
# Usage: .\test-nlp-service.ps1

Write-Host "🧪 Testing NLP Service" -ForegroundColor Blue
Write-Host "====================" -ForegroundColor Blue

# Check if NLP Service is running
Write-Host "`n📋 Checking NLP Service status..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8088/health" -TimeoutSec 10 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ NLP Service is running" -ForegroundColor Green
        $healthData = $response.Content | ConvertFrom-Json
        Write-Host "   Status: $($healthData.status)" -ForegroundColor White
        Write-Host "   Version: $($healthData.version)" -ForegroundColor White
    } else {
        Write-Host "⚠️  NLP Service responded with status: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ NLP Service is not responding" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nPlease make sure NLP Service is running:" -ForegroundColor Yellow
    Write-Host "   docker-compose up -d nlp-service" -ForegroundColor Cyan
    exit 1
}

# Test similarity check
Write-Host "`n🔍 Testing similarity check..." -ForegroundColor Yellow
try {
    $similarityRequest = @{
        text1 = "What is machine learning?"
        text2 = "Machine learning is a subset of artificial intelligence that enables computers to learn without being explicitly programmed."
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost:8088/similarity/check" -Method POST -Body $similarityRequest -ContentType "application/json" -TimeoutSec 30 -ErrorAction Stop
    
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Similarity check successful" -ForegroundColor Green
        $result = $response.Content | ConvertFrom-Json
        Write-Host "   Similarity Score: $($result.similarity_score)" -ForegroundColor White
        Write-Host "   Is Similar: $($result.is_similar)" -ForegroundColor White
    } else {
        Write-Host "⚠️  Similarity check failed with status: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Similarity check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test essay grading
Write-Host "`n📝 Testing essay grading..." -ForegroundColor Yellow
try {
    $gradingRequest = @{
        question = "Explain the concept of machine learning and its applications"
        answer = "Machine learning is a subset of artificial intelligence that enables computers to learn and improve from experience without being explicitly programmed. It uses algorithms to analyze data, identify patterns, and make predictions or decisions. Some common applications include recommendation systems, image recognition, natural language processing, and autonomous vehicles."
        max_score = 100
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost:8088/grading/essay" -Method POST -Body $gradingRequest -ContentType "application/json" -TimeoutSec 30 -ErrorAction Stop
    
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Essay grading successful" -ForegroundColor Green
        $result = $response.Content | ConvertFrom-Json
        Write-Host "   Score: $($result.score)/$($result.max_score)" -ForegroundColor White
        Write-Host "   Percentage: $($result.percentage)%" -ForegroundColor White
        Write-Host "   Confidence: $($result.confidence)" -ForegroundColor White
        Write-Host "   Strengths: $($result.strengths -join ', ')" -ForegroundColor White
    } else {
        Write-Host "⚠️  Essay grading failed with status: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Essay grading failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test question similarity check
Write-Host "`n❓ Testing question similarity check..." -ForegroundColor Yellow
try {
    $questionRequest = @{
        question_text = "What are the benefits of using microservices architecture?"
        exclude_id = $null
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost:8088/questions/similarity/check" -Method POST -Body $questionRequest -ContentType "application/json" -TimeoutSec 30 -ErrorAction Stop
    
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Question similarity check successful" -ForegroundColor Green
        $result = $response.Content | ConvertFrom-Json
        Write-Host "   Similar Questions Found: $($result.similar_questions.Count)" -ForegroundColor White
        Write-Host "   Is Duplicate: $($result.is_duplicate)" -ForegroundColor White
    } else {
        Write-Host "⚠️  Question similarity check failed with status: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Question similarity check failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎉 NLP Service testing completed!" -ForegroundColor Green
Write-Host "`n📋 Available endpoints:" -ForegroundColor Yellow
Write-Host "- Health Check: http://localhost:8088/health" -ForegroundColor Cyan
Write-Host "- Swagger UI: http://localhost:8088/swagger-ui.html" -ForegroundColor Cyan
Write-Host "- Similarity Check: POST /similarity/check" -ForegroundColor Cyan
Write-Host "- Essay Grading: POST /grading/essay" -ForegroundColor Cyan
Write-Host "- Question Similarity: POST /questions/similarity/check" -ForegroundColor Cyan
Write-Host "- Exam Grading: POST /exams/{id}/grade-all" -ForegroundColor Cyan
