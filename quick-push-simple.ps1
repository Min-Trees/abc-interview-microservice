# =============================================================================
# Quick Push Simple Script for Interview Microservice ABC
# =============================================================================
# Description: Build and push microservices to Docker Hub (without database)
# Usage: .\quick-push-simple.ps1 [options]
# Options:
#   -Tag [tag]: Custom tag for images (default: latest)
#   -Service [name]: Push only specific service
#   -NoBuild: Skip building, only push existing images
#   -NoCache: Build without using cache
#   -Verbose: Show detailed output
#   -Help: Show help message
# =============================================================================

param(
    [string]$Tag = "latest",
    [string]$Service = "",
    [switch]$NoBuild,
    [switch]$NoCache,
    [switch]$Verbose,
    [switch]$Help
)

# =============================================================================
# CONFIGURATION
# =============================================================================
$ScriptName = "Quick Push Simple Script"
$Version = "2.0.0"
$DockerHubUsername = "mintreestdmu"
$RegistryUrl = "docker.io"

# Service configuration (without database)
$Services = @{
    "config-service" = @{Image = "interview-config-service"; Description = "Configuration Service"}
    "discovery-service" = @{Image = "interview-discovery-service"; Description = "Service Discovery"}
    "gateway-service" = @{Image = "interview-gateway-service"; Description = "API Gateway"}
    "auth-service" = @{Image = "interview-auth-service"; Description = "Authentication Service"}
    "user-service" = @{Image = "interview-user-service"; Description = "User Management Service"}
    "career-service" = @{Image = "interview-career-service"; Description = "Career Management Service"}
    "question-service" = @{Image = "interview-question-service"; Description = "Question Management Service"}
    "exam-service" = @{Image = "interview-exam-service"; Description = "Exam Management Service"}
    "news-service" = @{Image = "interview-news-service"; Description = "News Management Service"}
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
        "BUILD" { "Magenta" }
        "PUSH" { "Blue" }
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

function Test-DockerLogin {
    try {
        $configPath = "$env:USERPROFILE\.docker\config.json"
        if (Test-Path $configPath) {
            $config = Get-Content $configPath | ConvertFrom-Json
            if ($config.auths -and $config.auths."https://index.docker.io/v1/") {
                return $true
            }
        }
        return $false
    } catch {
        try {
            docker ps | Out-Null
            return $true
        } catch {
            return $false
        }
    }
}

function Build-Service {
    param([string]$ServiceName, [string]$ImageName, [string]$Tag)
    
    Write-Step "Building service: $ServiceName" "BUILD"
    
    $buildArgs = @()
    if ($NoCache) {
        $buildArgs += "--no-cache"
    }
    
    if ($Verbose) {
        $buildArgs += "--progress=plain"
    }
    
    try {
        $buildCommand = "docker build $($buildArgs -join ' ') -t $ImageName`:$Tag ./$ServiceName"
        if ($Verbose) {
            Write-Host "Executing: $buildCommand" -ForegroundColor Gray
        }
        
        Invoke-Expression $buildCommand
        
        if ($LASTEXITCODE -eq 0) {
            Write-Step "Service $ServiceName built successfully" "SUCCESS"
            return $true
        } else {
            Write-Step "Failed to build service: $ServiceName" "ERROR"
            return $false
        }
    } catch {
        Write-Step "Error building service $ServiceName`: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Tag-Service {
    param([string]$ServiceName, [string]$ImageName, [string]$Tag)
    
    $localTag = "$ImageName`:$Tag"
    $remoteTag = "$DockerHubUsername/$ImageName`:$Tag"
    
    Write-Step "Tagging image: $localTag -> $remoteTag" "INFO"
    
    try {
        docker tag $localTag $remoteTag
        if ($LASTEXITCODE -eq 0) {
            Write-Step "Image tagged successfully" "SUCCESS"
            return $true
        } else {
            Write-Step "Failed to tag image" "ERROR"
            return $false
        }
    } catch {
        Write-Step "Error tagging image: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Push-Service {
    param([string]$ServiceName, [string]$ImageName, [string]$Tag)
    
    $remoteTag = "$DockerHubUsername/$ImageName`:$Tag"
    
    Write-Step "Pushing service: $ServiceName ($remoteTag)" "PUSH"
    
    try {
        if ($Verbose) {
            docker push $remoteTag
        } else {
            docker push $remoteTag 2>$null
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Step "Service $ServiceName pushed successfully" "SUCCESS"
            return $true
        } else {
            Write-Step "Failed to push service: $ServiceName" "ERROR"
            return $false
        }
    } catch {
        Write-Step "Error pushing service $ServiceName`: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Process-Service {
    param([string]$ServiceName, [string]$ImageName, [string]$Tag)
    
    $serviceInfo = $Services[$ServiceName]
    if (-not $serviceInfo) {
        Write-Step "Unknown service: $ServiceName" "ERROR"
        return $false
    }
    
    Write-Step "Processing service: $ServiceName ($($serviceInfo.Description))" "INFO"
    
    # Build service if not skipping build
    if (-not $NoBuild) {
        if (-not (Build-Service -ServiceName $ServiceName -ImageName $ImageName -Tag $Tag)) {
            return $false
        }
    }
    
    # Tag service
    if (-not (Tag-Service -ServiceName $ServiceName -ImageName $ImageName -Tag $Tag)) {
        return $false
    }
    
    # Push service
    if (-not (Push-Service -ServiceName $ServiceName -ImageName $ImageName -Tag $Tag)) {
        return $false
    }
    
    return $true
}

function Show-PushSummary {
    param([array]$ProcessedServices, [string]$Tag)
    
    Write-Header "Push Summary" "Green"
    
    Write-Host "`nServices pushed:" -ForegroundColor Yellow
    foreach ($service in $ProcessedServices) {
        $serviceInfo = $Services[$service]
        Write-Host "  [OK] [APP] $service`: $($serviceInfo.Description)" -ForegroundColor Green
    }
    
    Write-Host "`nPush Statistics:" -ForegroundColor Yellow
    Write-Host "  • Services processed: $($ProcessedServices.Count)" -ForegroundColor White
    Write-Host "  • Tag used: $Tag" -ForegroundColor White
    Write-Host "  • Registry: $RegistryUrl/$DockerHubUsername" -ForegroundColor White
    Write-Host "  • Push time: $($script:PushDuration)" -ForegroundColor White
    
    Write-Host "`nDocker Hub URLs:" -ForegroundColor Cyan
    foreach ($service in $ProcessedServices) {
        $serviceInfo = $Services[$service]
        $imageName = $serviceInfo.Image
        Write-Host "  • $service`: https://hub.docker.com/r/$DockerHubUsername/$imageName" -ForegroundColor Blue
    }
    
    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "  • Use docker-compose.prod.yml for deployment" -ForegroundColor White
    Write-Host "  • Run '.\quick-pull.ps1' to pull images" -ForegroundColor White
    Write-Host "  • Run '.\quick-deploy-prod.ps1' to deploy" -ForegroundColor White
    Write-Host "  • Share the Docker Hub URLs with your team" -ForegroundColor White
}

function Show-Help {
    Write-Header "Help - $ScriptName v$Version" "Blue"
    Write-Host "`nUsage: .\quick-push-simple.ps1 [options]" -ForegroundColor Yellow
    Write-Host "`nOptions:" -ForegroundColor Yellow
    Write-Host "  -Tag [tag]         Custom tag for images (default: latest)" -ForegroundColor White
    Write-Host "  -Service [name]    Push only specific service" -ForegroundColor White
    Write-Host "  -NoBuild           Skip building, only push existing images" -ForegroundColor White
    Write-Host "  -NoCache           Build without using cache" -ForegroundColor White
    Write-Host "  -Verbose           Show detailed output" -ForegroundColor White
    Write-Host "  -Help              Show this help message" -ForegroundColor White
    
    Write-Host "`nAvailable Services:" -ForegroundColor Yellow
    foreach ($service in $Services.GetEnumerator()) {
        Write-Host "  - [APP] $($service.Key): $($service.Value.Description)" -ForegroundColor Cyan
    }
    
    Write-Host "`nExamples:" -ForegroundColor Yellow
    Write-Host "  .\quick-push-simple.ps1                           # Push all services with 'latest' tag" -ForegroundColor White
    Write-Host "  .\quick-push-simple.ps1 -Tag v1.0.0              # Push all services with 'v1.0.0' tag" -ForegroundColor White
    Write-Host "  .\quick-push-simple.ps1 -Service auth             # Push only auth-service" -ForegroundColor White
    Write-Host "  .\quick-push-simple.ps1 -NoBuild -Tag v1.0.0     # Push existing images with custom tag" -ForegroundColor White
    Write-Host "  .\quick-push-simple.ps1 -Verbose -NoCache        # Verbose build and push without cache" -ForegroundColor White
    
    Write-Host "`nPrerequisites:" -ForegroundColor Yellow
    Write-Host "  • Docker must be installed and running" -ForegroundColor White
    Write-Host "  • Must be logged in to Docker Hub (docker login)" -ForegroundColor White
    Write-Host "  • Docker Hub username: $DockerHubUsername" -ForegroundColor White
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

# Check if logged in to Docker Hub
Write-Step "Checking Docker Hub authentication..." "INFO"
if (-not (Test-DockerLogin)) {
    Write-Step "Docker Hub authentication not detected, but continuing..." "WARNING"
    Write-Host "`nNote: If push fails, please run 'docker login' first" -ForegroundColor Yellow
} else {
    Write-Step "Docker Hub authentication confirmed" "SUCCESS"
}

Write-Step "Prerequisites validated successfully" "SUCCESS"

# Determine services to process
$servicesToProcess = @()
if ($Service -ne "") {
    if ($Services.ContainsKey($Service)) {
        $servicesToProcess = @($Service)
    } else {
        Write-Step "Unknown service: $Service" "ERROR"
        Write-Host "Available services: $($Services.Keys -join ', ')" -ForegroundColor Yellow
        exit 1
    }
} else {
    $servicesToProcess = $Services.Keys
}

Write-Step "Processing $($servicesToProcess.Count) service(s) with tag: $Tag" "INFO"

# Process services
$processedServices = @()
$pushSuccess = $true

foreach ($serviceName in $servicesToProcess) {
    $serviceInfo = $Services[$serviceName]
    $imageName = $serviceInfo.Image
    
    if (Process-Service -ServiceName $serviceName -ImageName $imageName -Tag $Tag) {
        $processedServices += $serviceName
    } else {
        $pushSuccess = $false
        break
    }
}

# Calculate push duration
$script:PushDuration = (Get-Date) - $script:StartTime
$script:PushDuration = "{0:mm\:ss}" -f $script:PushDuration

# Show results
if ($pushSuccess) {
    Show-PushSummary -ProcessedServices $processedServices -Tag $Tag
    Write-Header "Push Completed Successfully!" "Green"
    exit 0
} else {
    Write-Header "Push Failed!" "Red"
    Write-Host "`nPlease check the error messages above and try again." -ForegroundColor Yellow
    Write-Host "For help, run: .\quick-push-simple.ps1 -Help" -ForegroundColor Cyan
    exit 1
}

