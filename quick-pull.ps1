# =============================================================================
# Quick Pull Script for Interview Microservice ABC
# =============================================================================
# Description: Pull all microservices from Docker Hub
# Usage: .\quick-pull.ps1 [options]
# Options:
#   -Tag <tag>: Pull specific tag (default: latest)
#   -Service <name>: Pull only specific service
#   -AllTags: Pull all available tags
#   -Verbose: Show detailed output
#   -Help: Show help message
# =============================================================================

param(
    [string]$Tag = "latest",
    [string]$Service = "",
    [switch]$AllTags,
    [switch]$Verbose,
    [switch]$Help
)

# =============================================================================
# CONFIGURATION
# =============================================================================
$ScriptName = "Quick Pull Script"
$Version = "2.0.0"
$DockerHubUsername = "mintreestdmu"

# Service configuration
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

function Pull-Service {
    param([string]$ServiceName, [string]$ImageName, [string]$Tag)
    
    $fullImageName = "$DockerHubUsername/$ImageName`:$Tag"
    
    Write-Step "Pulling service: $ServiceName ($fullImageName)" "PULL"
    
    try {
        if ($Verbose) {
            docker pull $fullImageName
        } else {
            docker pull $fullImageName 2>$null
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Step "Service $ServiceName pulled successfully" "SUCCESS"
            return $true
        } else {
            Write-Step "Failed to pull service: $ServiceName" "ERROR"
            return $false
        }
    } catch {
        Write-Step "Error pulling service $ServiceName`: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Pull-AllTags {
    param([string]$ServiceName, [string]$ImageName)
    
    Write-Step "Pulling all tags for service: $ServiceName" "PULL"
    
    $tags = @("latest", "v1.0.0", "v1.1.0", "v1.2.0", "v2.0.0")
    $successCount = 0
    
    foreach ($tag in $tags) {
        $fullImageName = "$DockerHubUsername/$ImageName`:$tag"
        
        try {
            if ($Verbose) {
                docker pull $fullImageName
            } else {
                docker pull $fullImageName 2>$null
            }
            
            if ($LASTEXITCODE -eq 0) {
                Write-Step "Tag $tag pulled successfully for $ServiceName" "SUCCESS"
                $successCount++
            } else {
                Write-Step "Tag $tag not found for $ServiceName" "WARNING"
            }
        } catch {
            Write-Step "Error pulling tag $tag for $ServiceName`: $($_.Exception.Message)" "WARNING"
        }
    }
    
    return $successCount -gt 0
}

function Process-Service {
    param([string]$ServiceName, [string]$ImageName, [string]$Tag)
    
    $serviceInfo = $Services[$ServiceName]
    if (-not $serviceInfo) {
        Write-Step "Unknown service: $ServiceName" "ERROR"
        return $false
    }
    
    Write-Step "Processing service: $ServiceName ($($serviceInfo.Description))" "INFO"
    
    if ($AllTags) {
        return Pull-AllTags -ServiceName $ServiceName -ImageName $ImageName
    } else {
        return Pull-Service -ServiceName $ServiceName -ImageName $ImageName -Tag $Tag
    }
}

function Show-PullSummary {
    param([array]$ProcessedServices, [string]$Tag)
    
    Write-Header "Pull Summary" "Green"
    
    Write-Host "`nServices pulled:" -ForegroundColor Yellow
    foreach ($service in $ProcessedServices) {
        $serviceInfo = $Services[$service]
        Write-Host "  [OK] $service`: $($serviceInfo.Description)" -ForegroundColor Green
    }
    
    Write-Host "`nPull Statistics:" -ForegroundColor Yellow
    Write-Host "  • Services processed: $($ProcessedServices.Count)" -ForegroundColor White
    Write-Host "  • Tag used: $Tag" -ForegroundColor White
    Write-Host "  • Registry: docker.io/$DockerHubUsername" -ForegroundColor White
    Write-Host "  • Pull time: $($script:PullDuration)" -ForegroundColor White
    
    Write-Host "`nDocker Hub URLs:" -ForegroundColor Cyan
    foreach ($service in $ProcessedServices) {
        $serviceInfo = $Services[$service]
        $imageName = $serviceInfo.Image
        Write-Host "  • $service`: https://hub.docker.com/r/$DockerHubUsername/$imageName" -ForegroundColor Blue
    }
    
    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "  • Run '.\quick-deploy-prod.ps1' to deploy from Docker Hub images" -ForegroundColor White
    Write-Host "  • Run '.\quick-status.ps1' to check service status" -ForegroundColor White
    Write-Host "  • Run 'docker images | findstr mintreestdmu' to see all images" -ForegroundColor White
}

function Show-Help {
    Write-Header "Help - $ScriptName v$Version" "Blue"
    Write-Host "`nUsage: .\quick-pull.ps1 [options]" -ForegroundColor Yellow
    Write-Host "`nOptions:" -ForegroundColor Yellow
    Write-Host "  -Tag <tag>         Pull specific tag (default: latest)" -ForegroundColor White
    Write-Host "  -Service <name>    Pull only specific service" -ForegroundColor White
    Write-Host "  -AllTags           Pull all available tags" -ForegroundColor White
    Write-Host "  -Verbose           Show detailed output" -ForegroundColor White
    Write-Host "  -Help              Show this help message" -ForegroundColor White
    
    Write-Host "`nAvailable Services:" -ForegroundColor Yellow
    foreach ($service in $Services.GetEnumerator()) {
        Write-Host "  • $($service.Key): $($service.Value.Description)" -ForegroundColor Cyan
    }
    
    Write-Host "`nExamples:" -ForegroundColor Yellow
    Write-Host "  .\quick-pull.ps1                           # Pull all services with 'latest' tag" -ForegroundColor White
    Write-Host "  .\quick-pull.ps1 -Tag v1.0.0              # Pull all services with 'v1.0.0' tag" -ForegroundColor White
    Write-Host "  .\quick-pull.ps1 -Service auth            # Pull only auth-service" -ForegroundColor White
    Write-Host "  .\quick-pull.ps1 -AllTags                 # Pull all available tags" -ForegroundColor White
    Write-Host "  .\quick-pull.ps1 -Verbose                 # Verbose pull output" -ForegroundColor White
    
    Write-Host "`nPrerequisites:" -ForegroundColor Yellow
    Write-Host "  • Docker must be installed and running" -ForegroundColor White
    Write-Host "  • Internet connection required" -ForegroundColor White
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

$tagInfo = if ($AllTags) { "all available tags" } else { "tag: $Tag" }
Write-Step "Processing $($servicesToProcess.Count) service(s) with $tagInfo" "INFO"

# Process services
$processedServices = @()
$pullSuccess = $true

foreach ($serviceName in $servicesToProcess) {
    $serviceInfo = $Services[$serviceName]
    $imageName = $serviceInfo.Image
    
    if (Process-Service -ServiceName $serviceName -ImageName $imageName -Tag $Tag) {
        $processedServices += $serviceName
    } else {
        $pullSuccess = $false
        if (-not $AllTags) {
            break
        }
    }
}

# Calculate pull duration
$script:PullDuration = (Get-Date) - $script:StartTime
$script:PullDuration = "{0:mm\:ss}" -f $script:PullDuration

# Show results
if ($pullSuccess -or $processedServices.Count -gt 0) {
    Show-PullSummary -ProcessedServices $processedServices -Tag $Tag
    Write-Header "Pull Completed Successfully!" "Green"
    exit 0
} else {
    Write-Header "Pull Failed!" "Red"
    Write-Host "`nPlease check the error messages above and try again." -ForegroundColor Yellow
    Write-Host "For help, run: .\quick-pull.ps1 -Help" -ForegroundColor Cyan
    exit 1
}



