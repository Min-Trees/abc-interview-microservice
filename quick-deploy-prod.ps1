# =============================================================================
# Quick Deploy Production Script for Interview Microservice ABC
# =============================================================================
# Description: Deploy system using Docker Hub images
# Usage: .\quick-deploy-prod.ps1 [options]
# Options:
#   -Tag <tag>: Docker image tag (default: latest)
#   -Service <name>: Deploy only specific service
#   -SkipHealthCheck: Skip health checks
#   -WaitTime <seconds>: Custom wait time between service starts
#   -Monitor: Enable real-time monitoring
#   -Verbose: Show detailed deployment output
#   -Help: Show help message
# =============================================================================

param(
    [string]$Tag = "latest",
    [string]$Service = "",
    [switch]$SkipHealthCheck,
    [int]$WaitTime = 10,
    [switch]$Monitor,
    [switch]$Verbose,
    [switch]$Help
)

# =============================================================================
# CONFIGURATION
# =============================================================================
$ScriptName = "Quick Deploy Production Script"
$Version = "2.0.0"
$DockerHubUsername = "mintreestdmu"
$MaxRetries = 30
$RetryInterval = 2

# Service deployment order and configuration
$DeploymentOrder = @(
    @{Name = "postgres"; Type = "infrastructure"; WaitTime = 15; HealthCheck = $true}
    @{Name = "redis"; Type = "infrastructure"; WaitTime = 5; HealthCheck = $true}
    @{Name = "config-service"; Type = "core"; WaitTime = 15; HealthCheck = $true}
    @{Name = "discovery-service"; Type = "core"; WaitTime = 15; HealthCheck = $true}
    @{Name = "gateway-service"; Type = "core"; WaitTime = 10; HealthCheck = $true}
    @{Name = "auth-service"; Type = "microservice"; WaitTime = 10; HealthCheck = $true}
    @{Name = "user-service"; Type = "microservice"; WaitTime = 10; HealthCheck = $true}
    @{Name = "career-service"; Type = "microservice"; WaitTime = 10; HealthCheck = $true}
    @{Name = "question-service"; Type = "microservice"; WaitTime = 10; HealthCheck = $true}
    @{Name = "exam-service"; Type = "microservice"; WaitTime = 10; HealthCheck = $true}
    @{Name = "news-service"; Type = "microservice"; WaitTime = 10; HealthCheck = $true}
    @{Name = "nlp-service"; Type = "microservice"; WaitTime = 10; HealthCheck = $true}
)

# Service URLs and information
$ServiceInfo = @{
    "auth-service" = @{Port = 8081; Path = "/swagger-ui.html"; Description = "Authentication Service"}
    "user-service" = @{Port = 8082; Path = "/swagger-ui.html"; Description = "User Management Service"}
    "career-service" = @{Port = 8084; Path = "/swagger-ui.html"; Description = "Career Management Service"}
    "question-service" = @{Port = 8085; Path = "/swagger-ui.html"; Description = "Question Management Service"}
    "exam-service" = @{Port = 8086; Path = "/swagger-ui.html"; Description = "Exam Management Service"}
    "news-service" = @{Port = 8087; Path = "/swagger-ui.html"; Description = "News Management Service"}
    "nlp-service" = @{Port = 8088; Path = "/docs"; Description = "NLP Processing Service"}
    "gateway-service" = @{Port = 8080; Path = "/swagger-ui.html"; Description = "API Gateway"}
    "discovery-service" = @{Port = 8761; Path = ""; Description = "Service Discovery"}
    "config-service" = @{Port = 8888; Path = ""; Description = "Configuration Service"}
}

# Test accounts
$TestAccounts = @(
    @{Role = "USER"; Email = "test@example.com"; Password = "password123"}
    @{Role = "RECRUITER"; Email = "recruiter@example.com"; Password = "recruiter123"}
    @{Role = "ADMIN"; Email = "admin2@example.com"; Password = "admin123"}
)

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

function Write-Header {
    param([string]$Title, [string]$Color = "Green")
    Write-Host "`n" -NoNewline
    Write-Host "=" * 60 -ForegroundColor $Color
    Write-Host " $Title" -ForegroundColor $Color
    Write-Host "=" * 60 -ForegroundColor $Color
}

function Write-Step {
    param([string]$Message, [string]$Status = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $statusColor = switch ($Status) {
        "SUCCESS" { "Green" }
        "ERROR" { "Red" }
        "WARNING" { "Yellow" }
        "INFO" { "Cyan" }
        "DEPLOY" { "Magenta" }
        "PULL" { "Blue" }
        default { "White" }
    }
    Write-Host "[$timestamp] [$Status] $Message" -ForegroundColor $statusColor
}

function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Test-DockerRunning {
    try {
        docker ps | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Test-EnvironmentFile {
    if (-not (Test-Path ".env")) {
        Write-Step ".env file not found. Creating from template..." "WARNING"
        $envContent = @"
# =============================================================================
# Interview Microservice ABC - Production Environment Configuration
# =============================================================================

# Database Configuration
POSTGRES_DB=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=123456
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

# Redis Configuration
REDIS_HOST=redis
REDIS_PORT=6379

# JWT Configuration
JWT_SECRET=UCIafMmHwgsJKIgg4xVAL/eOvR3ZXD/ZnYE9AfMaMQg=
JWT_ACCESS_MINUTES=30
JWT_REFRESH_DAYS=7
JWT_ISSUER=http://auth-service:8081

# Email Configuration
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password

# Service Ports
AUTH_SERVICE_PORT=8081
USER_SERVICE_PORT=8082
CAREER_SERVICE_PORT=8084
QUESTION_SERVICE_PORT=8085
EXAM_SERVICE_PORT=8086
NEWS_SERVICE_PORT=8087
NLP_SERVICE_PORT=8088
GATEWAY_SERVICE_PORT=8080
DISCOVERY_SERVICE_PORT=8761
CONFIG_SERVICE_PORT=8888

# Database Names
AUTH_DB=authdb
USER_DB=userdb
CAREER_DB=careerdb
QUESTION_DB=questiondb
EXAM_DB=examdb
NEWS_DB=newsdb

# Eureka Configuration
EUREKA_DEFAULT_ZONE=http://discovery-service:8761/eureka/

# Config Server
CONFIG_SERVER_URI=http://config-service:8888

# Verification URL
VERIFICATION_URL=http://gateway-service:8080/auth/verify

# Docker Image Tag
IMAGE_TAG=$Tag
"@
        $envContent | Out-File -FilePath ".env" -Encoding UTF8
        Write-Step ".env file created successfully" "SUCCESS"
    }
    return $true
}

function Pull-Service {
    param([string]$ServiceName, [string]$Tag)
    
    $imageName = "mintreestdmu/interview-$ServiceName"
    $fullImageName = "$imageName`:$Tag"
    
    Write-Step "Pulling image: $fullImageName" "PULL"
    
    try {
        if ($Verbose) {
            docker pull $fullImageName
        } else {
            docker pull $fullImageName 2>$null
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Step "Image pulled successfully: $fullImageName" "SUCCESS"
            return $true
        } else {
            Write-Step "Failed to pull image: $fullImageName" "ERROR"
            return $false
        }
    } catch {
        Write-Step "Error pulling image $fullImageName`: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Start-Service {
    param([string]$ServiceName, [int]$CustomWaitTime = 0)
    
    $waitTime = if ($CustomWaitTime -gt 0) { $CustomWaitTime } else { $WaitTime }
    
    Write-Step "Starting service: $ServiceName" "DEPLOY"
    
    try {
        if ($Verbose) {
            docker-compose -f docker-compose.prod.yml up -d $ServiceName
        } else {
            docker-compose -f docker-compose.prod.yml up -d $ServiceName 2>$null
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Step "Service $ServiceName started successfully" "SUCCESS"
            
            if ($waitTime -gt 0) {
                Write-Step "Waiting $waitTime seconds for service to initialize..." "INFO"
                Start-Sleep -Seconds $waitTime
            }
            return $true
        } else {
            Write-Step "Failed to start service: $ServiceName" "ERROR"
            return $false
        }
    } catch {
        Write-Step "Error starting service $ServiceName`: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Test-ServiceHealth {
    param([string]$ServiceName)
    
    if ($SkipHealthCheck) {
        Write-Step "Skipping health check for: $ServiceName" "WARNING"
        return $true
    }
    
    $serviceInfo = $ServiceInfo[$ServiceName]
    if (-not $serviceInfo) {
        Write-Step "No health check configuration for: $ServiceName" "WARNING"
        return $true
    }
    
    $port = $serviceInfo.Port
    $path = $serviceInfo.Path
    
    # Determine health check endpoint
    $healthPath = if ($path -like "*/swagger-ui.html") { "/actuator/health" } else { "/health" }
    $url = "http://localhost:$port$healthPath"
    
    Write-Step "Checking health of $ServiceName at $url" "INFO"
    
    $retryCount = 0
    while ($retryCount -lt $MaxRetries) {
        try {
            $response = Invoke-WebRequest -Uri $url -TimeoutSec 5 -ErrorAction Stop
            if ($response.StatusCode -eq 200) {
                Write-Step "Service $ServiceName is healthy" "SUCCESS"
                return $true
            } else {
                Write-Step "Service $ServiceName returned status: $($response.StatusCode)" "WARNING"
            }
        } catch {
            Write-Step "Health check attempt $($retryCount + 1)/$MaxRetries for $ServiceName" "INFO"
        }
        
        $retryCount++
        Start-Sleep -Seconds $RetryInterval
    }
    
    Write-Step "Service $ServiceName failed health check after $MaxRetries attempts" "ERROR"
    return $false
}

function Deploy-Services {
    param([string]$ServiceName = "", [string]$Tag)
    
    if ($ServiceName -ne "") {
        # Deploy specific service
        Write-Step "Deploying specific service: $ServiceName" "INFO"
        
        # Find service in deployment order
        $serviceConfig = $DeploymentOrder | Where-Object { $_.Name -eq $ServiceName }
        if (-not $serviceConfig) {
            Write-Step "Service $ServiceName not found in deployment configuration" "ERROR"
            return $false
        }
        
        # Pull image
        if (-not (Pull-Service -ServiceName $ServiceName -Tag $Tag)) {
            return $false
        }
        
        # Start service
        if (-not (Start-Service -ServiceName $ServiceName -CustomWaitTime $serviceConfig.WaitTime)) {
            return $false
        }
        
        # Check health
        if (-not (Test-ServiceHealth -ServiceName $ServiceName)) {
            return $false
        }
        
        return $true
    } else {
        # Deploy all services in order
        Write-Step "Deploying all services in order..." "INFO"
        
        $deploymentSuccess = $true
        $deployedServices = @()
        
        foreach ($serviceConfig in $DeploymentOrder) {
            $serviceName = $serviceConfig.Name
            
            # Pull image for microservices
            if ($serviceConfig.Type -eq "microservice" -or $serviceConfig.Type -eq "core") {
                if (-not (Pull-Service -ServiceName $serviceName -Tag $Tag)) {
                    $deploymentSuccess = $false
                    break
                }
            }
            
            # Start service
            if (-not (Start-Service -ServiceName $serviceName -CustomWaitTime $serviceConfig.WaitTime)) {
                $deploymentSuccess = $false
                break
            }
            
            # Check health if configured
            if ($serviceConfig.HealthCheck -and -not (Test-ServiceHealth -ServiceName $serviceName)) {
                $deploymentSuccess = $false
                break
            }
            
            $deployedServices += $serviceName
            Write-Step "Successfully deployed: $serviceName" "SUCCESS"
        }
        
        return $deploymentSuccess
    }
}

function Show-ServiceStatus {
    Write-Header "Service Status" "Blue"
    
    # Show Docker Compose status
    Write-Host "`nDocker Compose Status:" -ForegroundColor Yellow
    docker-compose -f docker-compose.prod.yml ps
    
    # Show service health
    Write-Host "`nService Health:" -ForegroundColor Yellow
    Write-Host "=================" -ForegroundColor Yellow
    
    foreach ($service in $ServiceInfo.GetEnumerator()) {
        $serviceName = $service.Key
        $serviceInfo = $service.Value
        $port = $serviceInfo.Port
        $path = $serviceInfo.Path
        
        # Determine health check endpoint
        $healthPath = if ($path -like "*/swagger-ui.html") { "/actuator/health" } else { "/health" }
        $url = "http://localhost:$port$healthPath"
        
        try {
            $response = Invoke-WebRequest -Uri $url -TimeoutSec 3 -ErrorAction Stop
            if ($response.StatusCode -eq 200) {
                Write-Host "[OK] $serviceName`: Healthy" -ForegroundColor Green
            } else {
                Write-Host "[WARN] $serviceName`: Unhealthy (Status: $($response.StatusCode))" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "[ERROR] $serviceName`: Not responding" -ForegroundColor Red
        }
    }
}

function Show-ServiceUrls {
    Write-Header "Service URLs" "Green"
    
    Write-Host "`nMicroservices:" -ForegroundColor Yellow
    foreach ($service in $ServiceInfo.GetEnumerator()) {
        $serviceName = $service.Key
        $serviceInfo = $service.Value
        $port = $serviceInfo.Port
        $path = $serviceInfo.Path
        $description = $serviceInfo.Description
        
        if ($path -ne "") {
            $url = "http://localhost:$port$path"
            $icon = switch ($serviceName) {
                "auth-service" { "[AUTH]" }
                "user-service" { "[USER]" }
                "career-service" { "[CAREER]" }
                "question-service" { "[QUESTION]" }
                "exam-service" { "[EXAM]" }
                "news-service" { "[NEWS]" }
                "nlp-service" { "[NLP]" }
                "gateway-service" { "[GATEWAY]" }
                "discovery-service" { "[DISCOVERY]" }
                "config-service" { "[CONFIG]" }
                default { "[SERVICE]" }
            }
            Write-Host "  $icon $description`: $url" -ForegroundColor Cyan
        }
    }
    
    Write-Host "`nAdditional Resources:" -ForegroundColor Yellow
    Write-Host "  Swagger Aggregator: Open 'swagger-aggregator.html' in browser" -ForegroundColor Magenta
    Write-Host "  Service Discovery: http://localhost:8761" -ForegroundColor Cyan
    Write-Host "  Config Server: http://localhost:8888" -ForegroundColor Cyan
}

function Show-TestAccounts {
    Write-Header "Test Accounts" "Green"
    
    Write-Host "`nAvailable Test Accounts:" -ForegroundColor Yellow
    Write-Host "===========================" -ForegroundColor Yellow
    
    foreach ($account in $TestAccounts) {
        Write-Host "  $($account.Role): $($account.Email) / $($account.Password)" -ForegroundColor White
    }
    
    Write-Host "`nUsage Tips:" -ForegroundColor Cyan
    Write-Host "  • Use these accounts to test different user roles" -ForegroundColor White
    Write-Host "  • Start with the Gateway Service for API access" -ForegroundColor White
    Write-Host "  • Check individual service Swagger UIs for detailed API documentation" -ForegroundColor White
}

function Start-Monitoring {
    if ($Monitor) {
        Write-Header "Real-time Monitoring" "Magenta"
        Write-Host "`nStarting real-time monitoring..." -ForegroundColor Yellow
        Write-Host "Press Ctrl+C to stop monitoring" -ForegroundColor Cyan
        
        try {
            while ($true) {
                Clear-Host
                Write-Header "Live Service Status" "Blue"
                Show-ServiceStatus
                Start-Sleep -Seconds 5
            }
        } catch {
            Write-Host "`nMonitoring stopped." -ForegroundColor Yellow
        }
    }
}

function Show-Help {
    Write-Header "Help - $ScriptName v$Version" "Blue"
    Write-Host "`nUsage: .\quick-deploy-prod.ps1 [options]" -ForegroundColor Yellow
    Write-Host "`nOptions:" -ForegroundColor Yellow
    Write-Host "  -Tag <tag>         Docker image tag (default: latest)" -ForegroundColor White
    Write-Host "  -Service <name>    Deploy only specific service" -ForegroundColor White
    Write-Host "  -SkipHealthCheck   Skip health checks during deployment" -ForegroundColor White
    Write-Host "  -WaitTime <seconds> Custom wait time between service starts" -ForegroundColor White
    Write-Host "  -Monitor           Enable real-time monitoring after deployment" -ForegroundColor White
    Write-Host "  -Verbose           Show detailed deployment output" -ForegroundColor White
    Write-Host "  -Help              Show this help message" -ForegroundColor White
    
    Write-Host "`nAvailable Services:" -ForegroundColor Yellow
    foreach ($service in $DeploymentOrder) {
        Write-Host "  • $($service.Name): $($service.Type) service" -ForegroundColor Cyan
    }
    
    Write-Host "`nExamples:" -ForegroundColor Yellow
    Write-Host "  .\quick-deploy-prod.ps1                    # Deploy all services with latest tag" -ForegroundColor White
    Write-Host "  .\quick-deploy-prod.ps1 -Tag v1.0.0        # Deploy with specific tag" -ForegroundColor White
    Write-Host "  .\quick-deploy-prod.ps1 -Service auth      # Deploy only auth-service" -ForegroundColor White
    Write-Host "  .\quick-deploy-prod.ps1 -Monitor           # Deploy with monitoring" -ForegroundColor White
    Write-Host "  .\quick-deploy-prod.ps1 -WaitTime 20       # Custom wait time" -ForegroundColor White
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

# Show help if requested
if ($Help) {
    Show-Help
    exit 0
}

# Record start time
$script:StartTime = Get-Date

# Show header
Write-Header "$ScriptName v$Version" "Green"

# Validate prerequisites
Write-Step "Validating prerequisites..." "INFO"

# Check if Docker is running
if (-not (Test-DockerRunning)) {
    Write-Step "Docker is not running. Please start Docker Desktop first." "ERROR"
    exit 1
}

# Check if .env file exists
if (-not (Test-EnvironmentFile)) {
    exit 1
}

Write-Step "Prerequisites validated successfully" "SUCCESS"

# Deploy services
Write-Step "Starting deployment process with tag: $Tag" "INFO"
$deploymentSuccess = Deploy-Services -ServiceName $Service -Tag $Tag

# Calculate deployment duration
$script:DeploymentDuration = (Get-Date) - $script:StartTime
$script:DeploymentDuration = "{0:mm\:ss}" -f $script:DeploymentDuration

# Show results
if ($deploymentSuccess) {
    Write-Header "Deployment Completed Successfully!" "Green"
    
    # Show service status
    Show-ServiceStatus
    
    # Show service URLs
    Show-ServiceUrls
    
    # Show test accounts
    Show-TestAccounts
    
    # Show deployment summary
    Write-Header "Deployment Summary" "Green"
    Write-Host "`nDeployment Statistics:" -ForegroundColor Yellow
    Write-Host "  • Deployment time: $($script:DeploymentDuration)" -ForegroundColor White
    Write-Host "  • Services deployed: $(if ($Service -ne '') { 1 } else { $DeploymentOrder.Count })" -ForegroundColor White
    Write-Host "  • Docker tag used: $Tag" -ForegroundColor White
    Write-Host "  • Health checks: $(if ($SkipHealthCheck) { 'Skipped' } else { 'Completed' })" -ForegroundColor White
    
    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "  • Run '.\quick-status.ps1' to check service status" -ForegroundColor White
    Write-Host "  • Run '.\quick-logs.ps1 [service]' to view service logs" -ForegroundColor White
    Write-Host "  • Run '.\quick-deploy-prod.ps1 -Monitor' for real-time monitoring" -ForegroundColor White
    
    # Start monitoring if requested
    Start-Monitoring
    
    exit 0
} else {
    Write-Header "Deployment Failed!" "Red"
    Write-Host "`nPlease check the error messages above and try again." -ForegroundColor Yellow
    Write-Host "For help, run: .\quick-deploy-prod.ps1 -Help" -ForegroundColor Cyan
    exit 1
}
