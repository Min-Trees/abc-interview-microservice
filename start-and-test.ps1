# Start and Test Script for Interview Microservice ABC
# This script will start the system and run comprehensive tests

param(
    [switch]$SkipStart = $false,
    [switch]$Verbose = $false
)

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = $Reset)
    Write-Host "${Color}${Message}${Reset}"
}

function Test-DockerRunning {
    try {
        $null = docker ps 2>$null
        return $true
    }
    catch {
        return $false
    }
}

function Start-DockerDesktop {
    Write-ColorOutput "🐳 Starting Docker Desktop..." $Blue
    
    # Try to start Docker Desktop
    try {
        Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe" -WindowStyle Hidden
        Write-ColorOutput "Docker Desktop is starting..." $Yellow
        Write-ColorOutput "Please wait for Docker to fully start (this may take 1-2 minutes)" $Yellow
        
        # Wait for Docker to be ready
        $timeout = 120 # 2 minutes
        $elapsed = 0
        while ($elapsed -lt $timeout) {
            if (Test-DockerRunning) {
                Write-ColorOutput "✅ Docker is ready!" $Green
                return $true
            }
            Start-Sleep -Seconds 5
            $elapsed += 5
            Write-ColorOutput "Waiting for Docker... ($elapsed/$timeout seconds)" $Yellow
        }
        
        Write-ColorOutput "❌ Docker failed to start within timeout" $Red
        return $false
    }
    catch {
        Write-ColorOutput "❌ Failed to start Docker Desktop: $($_.Exception.Message)" $Red
        Write-ColorOutput "Please start Docker Desktop manually and run this script again" $Yellow
        return $false
    }
}

function Start-System {
    Write-ColorOutput "🚀 Starting Interview Microservice ABC System..." $Blue
    
    # Check if Docker is running
    if (-not (Test-DockerRunning)) {
        Write-ColorOutput "Docker is not running. Starting Docker Desktop..." $Yellow
        if (-not (Start-DockerDesktop)) {
            Write-ColorOutput "Cannot proceed without Docker. Exiting." $Red
            exit 1
        }
    }
    
    # Start the system
    Write-ColorOutput "Starting services with Docker Compose..." $Blue
    try {
        docker-compose up -d
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ Services started successfully!" $Green
        } else {
            Write-ColorOutput "❌ Failed to start services" $Red
            return $false
        }
    }
    catch {
        Write-ColorOutput "❌ Error starting services: $($_.Exception.Message)" $Red
        return $false
    }
    
    # Wait for services to be ready
    Write-ColorOutput "⏳ Waiting for services to be ready..." $Yellow
    Start-Sleep -Seconds 30
    
    return $true
}

function Test-SystemHealth {
    Write-ColorOutput "🔍 Testing system health..." $Blue
    
    $services = @(
        @{ Name = "Gateway"; Url = "http://localhost:8080/actuator/health" },
        @{ Name = "Auth Service"; Url = "http://localhost:8081/actuator/health" },
        @{ Name = "User Service"; Url = "http://localhost:8082/actuator/health" },
        @{ Name = "Career Service"; Url = "http://localhost:8084/actuator/health" },
        @{ Name = "Question Service"; Url = "http://localhost:8085/actuator/health" },
        @{ Name = "Exam Service"; Url = "http://localhost:8086/actuator/health" },
        @{ Name = "News Service"; Url = "http://localhost:8087/actuator/health" },
        @{ Name = "NLP Service"; Url = "http://localhost:8088/health" }
    )
    
    $healthy = 0
    $total = $services.Count
    
    foreach ($service in $services) {
        try {
            $response = Invoke-RestMethod -Uri $service.Url -TimeoutSec 10 -ErrorAction Stop
            Write-ColorOutput "✅ $($service.Name) - Healthy" $Green
            $healthy++
        }
        catch {
            Write-ColorOutput "❌ $($service.Name) - Unhealthy" $Red
            if ($Verbose) {
                Write-ColorOutput "   Error: $($_.Exception.Message)" $Red
            }
        }
    }
    
    Write-ColorOutput "`nHealth Check Results: $healthy/$total services healthy" $Yellow
    
    if ($healthy -eq $total) {
        Write-ColorOutput "🎉 All services are healthy!" $Green
        return $true
    } else {
        Write-ColorOutput "⚠️  Some services are not healthy. Check logs with: docker-compose logs" $Yellow
        return $false
    }
}

function Test-APIs {
    Write-ColorOutput "🧪 Testing API endpoints..." $Blue
    
    # Test basic endpoints
    $tests = @(
        @{ Name = "Auth Login"; Url = "http://localhost:8080/auth/login"; Method = "POST"; Body = '{"email":"test@example.com","password":"password123"}' },
        @{ Name = "User Registration"; Url = "http://localhost:8080/users/register"; Method = "POST"; Body = '{"email":"testuser@example.com","password":"password123","firstName":"Test","lastName":"User","role":"USER"}' },
        @{ Name = "Create Field"; Url = "http://localhost:8080/fields"; Method = "POST"; Body = '{"name":"Computer Science","description":"Computer Science field"}' },
        @{ Name = "Create Exam"; Url = "http://localhost:8080/exams"; Method = "POST"; Body = '{"title":"Java Test","description":"Test Java skills","examType":"TECHNICAL","duration":60,"maxAttempts":3,"isActive":true,"createdBy":1}' }
    )
    
    $passed = 0
    $total = $tests.Count
    
    foreach ($test in $tests) {
        try {
            $headers = @{ "Content-Type" = "application/json" }
            $response = Invoke-RestMethod -Uri $test.Url -Method $test.Method -Headers $headers -Body $test.Body -TimeoutSec 30 -ErrorAction Stop
            Write-ColorOutput "✅ $($test.Name)" $Green
            $passed++
        }
        catch {
            Write-ColorOutput "❌ $($test.Name) - $($_.Exception.Message)" $Red
        }
    }
    
    Write-ColorOutput "`nAPI Test Results: $passed/$total tests passed" $Yellow
    return $passed -eq $total
}

function Show-SystemInfo {
    Write-ColorOutput "`n📊 System Information:" $Cyan
    Write-ColorOutput "Gateway: http://localhost:8080" $Yellow
    Write-ColorOutput "Auth Service: http://localhost:8081" $Yellow
    Write-ColorOutput "User Service: http://localhost:8082" $Yellow
    Write-ColorOutput "Career Service: http://localhost:8084" $Yellow
    Write-ColorOutput "Question Service: http://localhost:8085" $Yellow
    Write-ColorOutput "Exam Service: http://localhost:8086" $Yellow
    Write-ColorOutput "News Service: http://localhost:8087" $Yellow
    Write-ColorOutput "NLP Service: http://localhost:8088" $Yellow
    Write-ColorOutput "Eureka Dashboard: http://localhost:8761" $Yellow
    
    Write-ColorOutput "`n📚 Test Files Available:" $Cyan
    Write-ColorOutput "• test-data.json - Sample data for all APIs" $Yellow
    Write-ColorOutput "• postman-collection.json - Complete Postman collection" $Yellow
    Write-ColorOutput "• test-system.ps1 - Comprehensive test script" $Yellow
    Write-ColorOutput "• test-api.sh - Simple curl-based test script" $Yellow
    Write-ColorOutput "• TESTING_GUIDE.md - Detailed testing instructions" $Yellow
    
    Write-ColorOutput "`n🔧 Useful Commands:" $Cyan
    Write-ColorOutput "• View logs: docker-compose logs [service-name]" $Yellow
    Write-ColorOutput "• Stop system: docker-compose down" $Yellow
    Write-ColorOutput "• Restart service: docker-compose restart [service-name]" $Yellow
    Write-ColorOutput "• Check status: docker-compose ps" $Yellow
}

function Show-NextSteps {
    Write-ColorOutput "`n🎯 Next Steps:" $Cyan
    Write-ColorOutput "1. Import postman-collection.json into Postman" $Yellow
    Write-ColorOutput "2. Run comprehensive tests with: .\test-system.ps1" $Yellow
    Write-ColorOutput "3. Check Swagger UI at: http://localhost:8080/swagger-ui.html" $Yellow
    Write-ColorOutput "4. Monitor logs with: docker-compose logs -f" $Yellow
    Write-ColorOutput "5. Stop system with: docker-compose down" $Yellow
}

# Main execution
Write-ColorOutput "🚀 Interview Microservice ABC - Start and Test Script" $Blue
Write-ColorOutput "=================================================" $Blue

if (-not $SkipStart) {
    # Start the system
    if (Start-System) {
        Write-ColorOutput "`n✅ System started successfully!" $Green
    } else {
        Write-ColorOutput "`n❌ Failed to start system" $Red
        exit 1
    }
} else {
    Write-ColorOutput "Skipping system start (using existing running system)" $Yellow
}

# Test system health
if (Test-SystemHealth) {
    # Test APIs
    if (Test-APIs) {
        Write-ColorOutput "`n🎉 All tests passed! System is working correctly." $Green
    } else {
        Write-ColorOutput "`n⚠️  Some API tests failed, but system is running." $Yellow
    }
} else {
    Write-ColorOutput "`n❌ System health check failed. Please check the logs." $Red
    Write-ColorOutput "Run: docker-compose logs" $Yellow
    exit 1
}

# Show system information
Show-SystemInfo
Show-NextSteps

Write-ColorOutput "`n✨ Setup complete! Your Interview Microservice ABC system is ready for testing." $Green
