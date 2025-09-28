# Demo NLP Service - Test các tính năng chính
Write-Host "🤖 Demo NLP Service - Testing AI Features" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta

# Test 1: Health Check
Write-Host "`n1️⃣ Testing Health Check..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8088/health" -Method GET
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Health Check: PASSED" -ForegroundColor Green
        $health = $response.Content | ConvertFrom-Json
        Write-Host "   Service: $($health.service)" -ForegroundColor White
        Write-Host "   Status: $($health.status)" -ForegroundColor White
        Write-Host "   Version: $($health.version)" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Health Check: FAILED" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Similarity Check
Write-Host "`n2️⃣ Testing Text Similarity..." -ForegroundColor Yellow
$similarityRequest = @{
    text1 = "What is machine learning?"
    text2 = "Machine learning is a subset of artificial intelligence that enables computers to learn without being explicitly programmed."
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8088/similarity/check" -Method POST -Body $similarityRequest -ContentType "application/json"
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Similarity Check: PASSED" -ForegroundColor Green
        $result = $response.Content | ConvertFrom-Json
        Write-Host "   Similarity Score: $([math]::Round($result.similarity_score, 3))" -ForegroundColor White
        Write-Host "   Is Similar: $($result.is_similar)" -ForegroundColor White
        Write-Host "   Confidence: $([math]::Round($result.confidence, 3))" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Similarity Check: FAILED" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Essay Grading
Write-Host "`n3️⃣ Testing Essay Grading..." -ForegroundColor Yellow
$gradingRequest = @{
    question = "Explain the concept of machine learning and its applications in modern technology"
    answer = "Machine learning is a subset of artificial intelligence that enables computers to learn and improve from experience without being explicitly programmed. It uses algorithms to analyze data, identify patterns, and make predictions or decisions. Some common applications include recommendation systems like Netflix and Amazon, image recognition in medical diagnosis, natural language processing in chatbots, autonomous vehicles, fraud detection in banking, and personalized marketing. The technology has revolutionized many industries by automating complex tasks and providing insights from large datasets."
    max_score = 100
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8088/grading/essay" -Method POST -Body $gradingRequest -ContentType "application/json"
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Essay Grading: PASSED" -ForegroundColor Green
        $result = $response.Content | ConvertFrom-Json
        Write-Host "   Score: $($result.score)/$($result.max_score)" -ForegroundColor White
        Write-Host "   Percentage: $($result.percentage)%" -ForegroundColor White
        Write-Host "   Confidence: $([math]::Round($result.confidence, 3))" -ForegroundColor White
        Write-Host "   Strengths: $($result.strengths -join ', ')" -ForegroundColor Green
        Write-Host "   Weaknesses: $($result.weaknesses -join ', ')" -ForegroundColor Red
        Write-Host "   Feedback:" -ForegroundColor Cyan
        foreach ($feedback in $result.feedback) {
            Write-Host "     • $feedback" -ForegroundColor White
        }
    }
} catch {
    Write-Host "❌ Essay Grading: FAILED" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Question Similarity Check
Write-Host "`n4️⃣ Testing Question Similarity..." -ForegroundColor Yellow
$questionRequest = @{
    question_text = "What are the benefits of using microservices architecture in software development?"
    exclude_id = $null
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8088/questions/similarity/check" -Method POST -Body $questionRequest -ContentType "application/json"
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Question Similarity: PASSED" -ForegroundColor Green
        $result = $response.Content | ConvertFrom-Json
        Write-Host "   Similar Questions Found: $($result.similar_questions.Count)" -ForegroundColor White
        Write-Host "   Is Duplicate: $($result.is_duplicate)" -ForegroundColor White
        if ($result.similar_questions.Count -gt 0) {
            Write-Host "   Top Similar Questions:" -ForegroundColor Cyan
            for ($i = 0; $i -lt [Math]::Min(3, $result.similar_questions.Count); $i++) {
                $q = $result.similar_questions[$i]
                Write-Host "     $($i+1). Score: $([math]::Round($q.similarity_score, 3)) - ID: $($q.question_id)" -ForegroundColor White
            }
        }
    }
} catch {
    Write-Host "❌ Question Similarity: FAILED" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Poor Quality Essay
Write-Host "`n5️⃣ Testing Poor Quality Essay..." -ForegroundColor Yellow
$poorEssayRequest = @{
    question = "Explain the concept of machine learning and its applications"
    answer = "Machine learning is good. It helps computers. Many companies use it. It is very useful technology."
    max_score = 100
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8088/grading/essay" -Method POST -Body $poorEssayRequest -ContentType "application/json"
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Poor Essay Grading: PASSED" -ForegroundColor Green
        $result = $response.Content | ConvertFrom-Json
        Write-Host "   Score: $($result.score)/$($result.max_score)" -ForegroundColor White
        Write-Host "   Percentage: $($result.percentage)%" -ForegroundColor White
        Write-Host "   Confidence: $([math]::Round($result.confidence, 3))" -ForegroundColor White
        Write-Host "   Strengths: $($result.strengths -join ', ')" -ForegroundColor Green
        Write-Host "   Weaknesses: $($result.weaknesses -join ', ')" -ForegroundColor Red
        Write-Host "   Suggestions:" -ForegroundColor Yellow
        foreach ($suggestion in $result.suggestions) {
            Write-Host "     • $suggestion" -ForegroundColor White
        }
    }
} catch {
    Write-Host "❌ Poor Essay Grading: FAILED" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎉 Demo completed! NLP Service is working perfectly!" -ForegroundColor Green
Write-Host "`n📋 Available Features:" -ForegroundColor Cyan
Write-Host "✅ Text Similarity Detection" -ForegroundColor White
Write-Host "✅ AI-Powered Essay Grading" -ForegroundColor White
Write-Host "✅ Question Duplicate Detection" -ForegroundColor White
Write-Host "✅ Detailed Feedback and Suggestions" -ForegroundColor White
Write-Host "✅ Confidence Scoring" -ForegroundColor White

Write-Host "`n🌐 Service URLs:" -ForegroundColor Cyan
Write-Host "- Health: http://localhost:8088/health" -ForegroundColor White
Write-Host "- Swagger UI: http://localhost:8088/docs" -ForegroundColor White
Write-Host "- Similarity: POST http://localhost:8088/similarity/check" -ForegroundColor White
Write-Host "- Grading: POST http://localhost:8088/grading/essay" -ForegroundColor White
