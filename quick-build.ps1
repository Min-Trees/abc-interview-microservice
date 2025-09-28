# =============================================================================
# Quick Build Script for Interview Microservice ABC
# =============================================================================
# Description: Comprehensive build script with error handling and validation
# Usage: .\quick-build.ps1 [options]
# Options:
#   -Clean: Remove all images and volumes before building
#   -NoCache: Build without using cache
#   -Service <name>: Build only specific service
#   -Verbose: Show detailed build output
# =============================================================================

param(
    [switch]$Clean,
    [switch]$NoCache,
    [string]$Service = "",
    [switch]$Verbose,
    [switch]$Help
)

# =============================================================================
# CONFIGURATION
# =============================================================================
$ScriptName = "Quick Build Script"
$Version = "2.0.0"
$RequiredDockerVersion = "20.10.0"
$RequiredComposeVersion = "2.0.0"

# Service configuration
$Services = @{
    "config-service" = @{Port = 8888; Description = "Configuration Service"}
    "discovery-service" = @{Port = 8761; Description = "Service Discovery"}
    "gateway-service" = @{Port = 8080; Description = "API Gateway"}
    "auth-service" = @{Port = 8081; Description = "Authentication Service"}
    "user-service" = @{Port = 8082; Description = "User Management Service"}
    "career-service" = @{Port = 8084; Description = "Career Management Service"}
    "question-service" = @{Port = 8085; Description = "Question Management Service"}
    "exam-service" = @{Port = 8086; Description = "Exam Management Service"}
    "news-service" = @{Port = 8087; Description = "News Management Service"}
    "nlp-service" = @{Port = 8088; Description = "NLP Processing Service"}
}

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

function Get-DockerVersion {
    try {
        $version = docker --version | Select-String -Pattern "(\d+\.\d+\.\d+)" | ForEach-Object { $_.Matches[0].Value }
        return [Version]$version
    } catch {
        return $null
    }
}

function Get-ComposeVersion {
    try {
        $version = docker-compose --version | Select-String -Pattern "(\d+\.\d+\.\d+)" | ForEach-Object { $_.Matches[0].Value }
        return [Version]$version
    } catch {
        return $null
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

function Initialize-Environment {
    Write-Step "Initializing environment configuration..." "INFO"
    
    if (-not (Test-Path ".env")) {
        Write-Step "Creating .env file from template..." "WARNING"
        $envContent = @"
# =============================================================================
# Interview Microservice ABC - Environment Configuration
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
MAIL_USERNAME=npminhtri.be@gmail.com
MAIL_PASSWORD=cfubhnaxnbdzsnta

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
"@
        $envContent | Out-File -FilePath ".env" -Encoding UTF8
        Write-Step ".env file created successfully" "SUCCESS"
    } else {
        Write-Step ".env file already exists" "INFO"
    }
}

function Stop-ExistingContainers {
    Write-Step "Stopping existing containers..." "INFO"
    try {
        docker-compose down --remove-orphans 2>$null
        Write-Step "Existing containers stopped" "SUCCESS"
    } catch {
        Write-Step "No existing containers to stop" "INFO"
    }
}

function Remove-ImagesAndVolumes {
    if ($Clean) {
        Write-Step "Cleaning up images and volumes..." "WARNING"
        try {
            # Remove unused images
            docker image prune -f
            # Remove unused volumes
            docker volume prune -f
            # Remove unused networks
            docker network prune -f
            Write-Step "Cleanup completed" "SUCCESS"
        } catch {
            Write-Step "Cleanup failed: $($_.Exception.Message)" "ERROR"
        }
    }
}

function Build-Services {
    param([string]$ServiceName = "")
    
    Write-Step "Starting build process..." "INFO"
    
    $buildArgs = @()
    if ($NoCache) {
        $buildArgs += "--no-cache"
    }
    
    if ($Verbose) {
        $buildArgs += "--progress=plain"
    }
    
    try {
        if ($ServiceName -ne "") {
            if ($Services.ContainsKey($ServiceName)) {
                Write-Step "Building service: $ServiceName" "INFO"
                $buildCommand = "docker-compose build $($buildArgs -join ' ') $ServiceName"
                Invoke-Expression $buildCommand
            } else {
                Write-Step "Unknown service: $ServiceName" "ERROR"
                return $false
            }
        } else {
            Write-Step "Building all services..." "INFO"
            $buildCommand = "docker-compose build $($buildArgs -join ' ')"
            Invoke-Expression $buildCommand
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Step "Build completed successfully!" "SUCCESS"
            return $true
        } else {
            Write-Step "Build failed with exit code: $LASTEXITCODE" "ERROR"
            return $false
        }
    } catch {
        Write-Step "Build failed: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Show-BuildSummary {
    Write-Header "Build Summary" "Green"
    
    Write-Host "`nServices built:" -ForegroundColor Yellow
    foreach ($service in $Services.GetEnumerator()) {
        $status = if ($Service -eq "" -or $Service -eq $service.Key) { "[OK]" } else { "[SKIP]" }
        Write-Host "  $status $($service.Key): $($service.Value.Description) (Port: $($service.Value.Port))" -ForegroundColor White
    }
    
    Write-Host "`nBuild Statistics:" -ForegroundColor Yellow
    $imageCount = (docker images --format "table {{.Repository}}" | Select-String "interview-" | Measure-Object).Count
    Write-Host "  • Docker images created: $imageCount" -ForegroundColor White
    Write-Host "  • Build time: $($script:BuildDuration)" -ForegroundColor White
    
    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "  • Run '.\quick-deploy.ps1' to start all services" -ForegroundColor White
    Write-Host "  • Run '.\quick-status.ps1' to check service status" -ForegroundColor White
    Write-Host "  • Run '.\quick-logs.ps1' to view service logs" -ForegroundColor White
}

function Show-Help {
    Write-Header "Help - $ScriptName v$Version" "Blue"
    Write-Host "`nUsage: .\quick-build.ps1 [options]" -ForegroundColor Yellow
    Write-Host "`nOptions:" -ForegroundColor Yellow
    Write-Host "  -Clean          Remove all images and volumes before building" -ForegroundColor White
    Write-Host "  -NoCache        Build without using cache" -ForegroundColor White
    Write-Host "  -Service <name> Build only specific service" -ForegroundColor White
    Write-Host "  -Verbose        Show detailed build output" -ForegroundColor White
    Write-Host "  -Help           Show this help message" -ForegroundColor White
    
    Write-Host "`nAvailable Services:" -ForegroundColor Yellow
    foreach ($service in $Services.GetEnumerator()) {
        Write-Host "  • $($service.Key): $($service.Value.Description)" -ForegroundColor Cyan
    }
    
    Write-Host "`nExamples:" -ForegroundColor Yellow
    Write-Host "  .\quick-build.ps1                    # Build all services" -ForegroundColor White
    Write-Host "  .\quick-build.ps1 -Clean             # Clean build" -ForegroundColor White
    Write-Host "  .\quick-build.ps1 -Service auth      # Build only auth-service" -ForegroundColor White
    Write-Host "  .\quick-build.ps1 -Verbose -NoCache  # Verbose build without cache" -ForegroundColor White
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

# Check if Docker is installed
if (-not (Test-Command "docker")) {
    Write-Step "Docker is not installed or not in PATH" "ERROR"
    exit 1
}

# Check if Docker Compose is installed
if (-not (Test-Command "docker-compose")) {
    Write-Step "Docker Compose is not installed or not in PATH" "ERROR"
    exit 1
}

# Check Docker version
$dockerVersion = Get-DockerVersion
if ($dockerVersion -and $dockerVersion -lt [Version]$RequiredDockerVersion) {
    Write-Step "Docker version $dockerVersion is below required version $RequiredDockerVersion" "WARNING"
}

# Check Compose version
$composeVersion = Get-ComposeVersion
if ($composeVersion -and $composeVersion -lt [Version]$RequiredComposeVersion) {
    Write-Step "Docker Compose version $composeVersion is below required version $RequiredComposeVersion" "WARNING"
}

# Check if Docker is running
if (-not (Test-DockerRunning)) {
    Write-Step "Docker is not running. Please start Docker Desktop first." "ERROR"
    exit 1
}

Write-Step "Prerequisites validated successfully" "SUCCESS"

# Initialize environment
Initialize-Environment

# Stop existing containers
Stop-ExistingContainers

# Clean up if requested
Remove-ImagesAndVolumes

# Build services
$buildSuccess = Build-Services -ServiceName $Service

# Calculate build duration
$script:BuildDuration = (Get-Date) - $script:StartTime
$script:BuildDuration = "{0:mm\:ss}" -f $script:BuildDuration

# Show results
if ($buildSuccess) {
    Show-BuildSummary
    Write-Header "Build Completed Successfully!" "Green"
    exit 0
} else {
    Write-Header "Build Failed!" "Red"
    Write-Host "`nPlease check the error messages above and try again." -ForegroundColor Yellow
    Write-Host "For help, run: .\quick-build.ps1 -Help" -ForegroundColor Cyan
    exit 1
}