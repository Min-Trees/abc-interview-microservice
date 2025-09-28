# =============================================================================
# Quick Setup Script for Interview Microservice ABC
# =============================================================================
# Description: Complete setup script for new users
# Usage: .\quick-setup.ps1 [options]
# Options:
#   -Tag <tag>: Use specific tag (default: latest)
#   -SkipPull: Skip pulling images
#   -SkipDeploy: Skip deployment
#   -Verbose: Show detailed output
#   -Help: Show help message
# =============================================================================

param(
    [string]$Tag = "latest",
    [switch]$SkipPull,
    [switch]$SkipDeploy,
    [switch]$Verbose,
    [switch]$Help
)

# =============================================================================
# CONFIGURATION
# =============================================================================
$ScriptName = "Quick Setup Script"
$Version = "2.0.0"
$DockerHubUsername = "mintreestdmu"

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
        "SETUP" { "Magenta" }
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

function Create-EnvironmentFile {
    Write-Step "Creating environment configuration..." "SETUP"
    
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

function Create-ReadmeFile {
    Write-Step "Creating README file..." "SETUP"
    
    $readmeContent = @"
# Interview Microservice ABC - Quick Setup

## Prerequisites
- Docker Desktop installed and running
- Internet connection

## Quick Start

### 1. Pull all images from Docker Hub
``````powershell
.\quick-pull.ps1
``````

### 2. Deploy the system
``````powershell
.\quick-deploy-prod.ps1
``````

### 3. Check system status
``````powershell
.\quick-status.ps1
``````

## Service URLs

| Service | URL | Description |
|---------|-----|-------------|
| API Gateway | http://localhost:8080/swagger-ui.html | Main API Gateway |
| Auth Service | http://localhost:8081/swagger-ui.html | Authentication |
| User Service | http://localhost:8082/swagger-ui.html | User Management |
| Career Service | http://localhost:8084/swagger-ui.html | Career Management |
| Question Service | http://localhost:8085/swagger-ui.html | Question Management |
| Exam Service | http://localhost:8086/swagger-ui.html | Exam Management |
| News Service | http://localhost:8087/swagger-ui.html | News Management |
| Discovery Service | http://localhost:8761 | Service Discovery |
| Config Service | http://localhost:8888 | Configuration |

## Test Accounts

| Role | Email | Password |
|------|-------|----------|
| USER | test@example.com | password123 |
| RECRUITER | recruiter@example.com | recruiter123 |
| ADMIN | admin2@example.com | admin123 |

## Management Commands

``````powershell
# View logs
.\quick-logs.ps1 [service-name]

# Restart service
.\quick-restart.ps1 [service-name]

# Stop all services
.\quick-stop.ps1

# Check status
.\quick-status.ps1
``````

## Documentation

- [Installation Guide](INSTALLATION_GUIDE.md)
- [Docker Hub Setup](DOCKER_HUB_SETUP.md)

## Support

If you encounter any issues, please check the troubleshooting section in the installation guide.

---
**Docker Hub Images**: https://hub.docker.com/r/$DockerHubUsername
"@
    
    $readmeContent | Out-File -FilePath "README-SETUP.md" -Encoding UTF8
    Write-Step "README file created successfully" "SUCCESS"
}

function Show-SetupSummary {
    Write-Header "Setup Summary" "Green"
    
    Write-Host "`nFiles created:" -ForegroundColor Yellow
    Write-Host "  [OK] .env - Environment configuration" -ForegroundColor Green
    Write-Host "  [OK] README-SETUP.md - Setup instructions" -ForegroundColor Green
    
    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "  1. Run '.\quick-pull.ps1' to pull all images" -ForegroundColor White
    Write-Host "  2. Run '.\quick-deploy-prod.ps1' to deploy system" -ForegroundColor White
    Write-Host "  3. Run '.\quick-status.ps1' to check status" -ForegroundColor White
    
    Write-Host "`nDocker Hub:" -ForegroundColor Cyan
    Write-Host "  • Username: $DockerHubUsername" -ForegroundColor White
    Write-Host "  • Tag: $Tag" -ForegroundColor White
    Write-Host "  • URL: https://hub.docker.com/r/$DockerHubUsername" -ForegroundColor White
}

function Show-Help {
    Write-Header "Help - $ScriptName v$Version" "Blue"
    Write-Host "`nUsage: .\quick-setup.ps1 [options]" -ForegroundColor Yellow
    Write-Host "`nOptions:" -ForegroundColor Yellow
    Write-Host "  -Tag <tag>      Use specific tag (default: latest)" -ForegroundColor White
    Write-Host "  -SkipPull       Skip pulling images" -ForegroundColor White
    Write-Host "  -SkipDeploy     Skip deployment" -ForegroundColor White
    Write-Host "  -Verbose        Show detailed output" -ForegroundColor White
    Write-Host "  -Help           Show this help message" -ForegroundColor White
    
    Write-Host "`nExamples:" -ForegroundColor Yellow
    Write-Host "  .\quick-setup.ps1                    # Complete setup with latest tag" -ForegroundColor White
    Write-Host "  .\quick-setup.ps1 -Tag v1.0.0        # Setup with specific tag" -ForegroundColor White
    Write-Host "  .\quick-setup.ps1 -SkipPull          # Setup without pulling images" -ForegroundColor White
    Write-Host "  .\quick-setup.ps1 -SkipDeploy        # Setup without deployment" -ForegroundColor White
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

# Check if Docker is running
if (-not (Test-DockerRunning)) {
    Write-Step "Docker is not running. Please start Docker Desktop first." "ERROR"
    exit 1
}

Write-Step "Prerequisites validated successfully" "SUCCESS"

# Create environment file
Create-EnvironmentFile

# Create README file
Create-ReadmeFile

# Pull images if not skipped
if (-not $SkipPull) {
    Write-Step "Pulling images from Docker Hub..." "SETUP"
    if ($Verbose) {
        .\quick-pull.ps1 -Tag $Tag -Verbose
    } else {
        .\quick-pull.ps1 -Tag $Tag
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Step "Failed to pull images" "ERROR"
        exit 1
    }
}

# Deploy system if not skipped
if (-not $SkipDeploy) {
    Write-Step "Deploying system..." "SETUP"
    if ($Verbose) {
        .\quick-deploy-prod.ps1 -Tag $Tag -Verbose
    } else {
        .\quick-deploy-prod.ps1 -Tag $Tag
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Step "Failed to deploy system" "ERROR"
        exit 1
    }
}

# Calculate setup duration
$script:SetupDuration = (Get-Date) - $script:StartTime
$script:SetupDuration = "{0:mm\:ss}" -f $script:SetupDuration

# Show results
Write-Header "Setup Completed Successfully!" "Green"
Show-SetupSummary

Write-Host "`nSetup Statistics:" -ForegroundColor Yellow
Write-Host "  • Setup time: $($script:SetupDuration)" -ForegroundColor White
Write-Host "  • Images pulled: $(if ($SkipPull) { 'Skipped' } else { 'Yes' })" -ForegroundColor White
Write-Host "  • System deployed: $(if ($SkipDeploy) { 'Skipped' } else { 'Yes' })" -ForegroundColor White

exit 0



