# =============================================================================
# Quick Run Only Script for Interview Microservice ABC
# =============================================================================
# Description: Run all microservices from existing Docker images
# Usage: .\quick-run-only.ps1 [options]
# Options:
#   -Tag [tag]: Use specific tag (default: latest)
#   -Service [name]: Run only specific service
#   -StopFirst: Stop existing containers before starting
#   -Verbose: Show detailed output
#   -Help: Show help message
# =============================================================================

param(
    [string]$Tag = "latest",
    [string]$Service = "",
    [switch]$StopFirst,
    [switch]$Verbose,
    [switch]$Help
)

# =============================================================================
# CONFIGURATION
# =============================================================================
$ScriptName = "Quick Run Only Script"
$Version = "2.0.0"
$DockerHubUsername = "mintreestdmu"

# Service configuration
$Services = @{
    "postgres" = @{Image = "interview-postgres"; Description = "PostgreSQL Database"; Port = "5432"; IsDatabase = $true}
    "redis" = @{Image = "interview-redis"; Description = "Redis Cache"; Port = "6379"; IsDatabase = $true}
    "config-service" = @{Image = "interview-config-service"; Description = "Configuration Service"; Port = "8888"; IsDatabase = $false}
    "discovery-service" = @{Image = "interview-discovery-service"; Description = "Service Discovery"; Port = "8761"; IsDatabase = $false}
    "gateway-service" = @{Image = "interview-gateway-service"; Description = "API Gateway"; Port = "8080"; IsDatabase = $false}
    "auth-service" = @{Image = "interview-auth-service"; Description = "Authentication Service"; Port = "8081"; IsDatabase = $false}
    "user-service" = @{Image = "interview-user-service"; Description = "User Management Service"; Port = "8082"; IsDatabase = $false}
    "career-service" = @{Image = "interview-career-service"; Description = "Career Management Service"; Port = "8084"; IsDatabase = $false}
    "question-service" = @{Image = "interview-question-service"; Description = "Question Management Service"; Port = "8085"; IsDatabase = $false}
    "exam-service" = @{Image = "interview-exam-service"; Description = "Exam Management Service"; Port = "8086"; IsDatabase = $false}
    "news-service" = @{Image = "interview-news-service"; Description = "News Management Service"; Port = "8087"; IsDatabase = $false}
}

# Service startup order
$StartupOrder = @(
    "postgres",
    "redis", 
    "config-service",
    "discovery-service",
    "gateway-service",
    "auth-service",
    "user-service",
    "career-service",
    "question-service",
    "exam-service",
    "news-service"
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
        "RUN" { "Magenta" }
        "STOP" { "DarkRed" }
        "WAIT" { "DarkYellow" }
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

function Stop-ExistingContainers {
    Write-Step "Stopping existing containers..." "STOP"
    
    $containerNames = @()
    foreach ($service in $Services.Keys) {
        $containerNames += "interview-$service"
    }
    
    foreach ($containerName in $containerNames) {
        try {
            $existingContainer = docker ps -q -f "name=$containerName"
            if ($existingContainer) {
                Write-Step "Stopping container: $containerName" "STOP"
                docker stop $containerName | Out-Null
                docker rm $containerName | Out-Null
            }
        } catch {
            Write-Step "Warning: Could not stop container $containerName" "WARNING"
        }
    }
    
    Write-Step "Existing containers stopped" "SUCCESS"
}

function Test-ImageExists {
    param([string]$ImageName, [string]$Tag)
    
    $fullImageName = "$DockerHubUsername/$ImageName`:$Tag"
    
    try {
        $imageExists = docker images -q $fullImageName
        return $imageExists -ne $null
    } catch {
        return $false
    }
}

function Run-Service {
    param([string]$ServiceName, [string]$ImageName, [string]$Tag)
    
    $serviceInfo = $Services[$ServiceName]
    $containerName = "interview-$ServiceName"
    $fullImageName = "$DockerHubUsername/$ImageName`:$Tag"
    
    # Check if image exists
    if (-not (Test-ImageExists -ImageName $ImageName -Tag $Tag)) {
        Write-Step "Image $fullImageName not found locally. Please run pull first." "ERROR"
        return $false
    }
    
    Write-Step "Starting service: $ServiceName" "RUN"
    
    try {
        $runCommand = @()
        
        if ($serviceInfo.IsDatabase) {
            # Database services
            if ($ServiceName -eq "postgres") {
                $runCommand = @(
                    "docker", "run", "-d",
                    "--name", $containerName,
                    "-p", "$($serviceInfo.Port):5432",
                    "-e", "POSTGRES_DB=postgres",
                    "-e", "POSTGRES_USER=postgres", 
                    "-e", "POSTGRES_PASSWORD=123456",
                    "-v", "postgres_data:/var/lib/postgresql/data",
                    "--network", "interview-network",
                    $fullImageName
                )
            } elseif ($ServiceName -eq "redis") {
                $runCommand = @(
                    "docker", "run", "-d",
                    "--name", $containerName,
                    "-p", "$($serviceInfo.Port):6379",
                    "--network", "interview-network",
                    $fullImageName
                )
            }
        } else {
            # Application services
            $runCommand = @(
                "docker", "run", "-d",
                "--name", $containerName,
                "-p", "$($serviceInfo.Port):$($serviceInfo.Port)",
                "-e", "SPRING_PROFILES_ACTIVE=docker",
                "-e", "JWT_SECRET=your-secret-key-here",
                "-e", "POSTGRES_HOST=postgres",
                "-e", "POSTGRES_PORT=5432",
                "-e", "POSTGRES_USER=postgres",
                "-e", "POSTGRES_PASSWORD=123456",
                "-e", "REDIS_HOST=redis",
                "-e", "REDIS_PORT=6379",
                "--network", "interview-network",
                $fullImageName
            )
        }
        
        if ($Verbose) {
            Write-Host "Executing: $($runCommand -join ' ')" -ForegroundColor Gray
        }
        
        & $runCommand[0] $runCommand[1..($runCommand.Length-1)]
        
        if ($LASTEXITCODE -eq 0) {
            Write-Step "Service $ServiceName started successfully" "SUCCESS"
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

function Create-Network {
    Write-Step "Creating Docker network..." "INFO"
    
    try {
        # Check if network exists
        $existingNetwork = docker network ls -q -f "name=interview-network"
        if (-not $existingNetwork) {
            docker network create interview-network
            Write-Step "Docker network created" "SUCCESS"
        } else {
            Write-Step "Docker network already exists" "INFO"
        }
        return $true
    } catch {
        Write-Step "Error creating network: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Show-RunSummary {
    param([array]$ProcessedServices, [string]$Tag)
    
    Write-Header "Run Summary" "Green"
    
    Write-Host "`nServices running:" -ForegroundColor Yellow
    foreach ($service in $ProcessedServices) {
        $serviceInfo = $Services[$service]
        $icon = if ($serviceInfo.IsDatabase) { "[DB]" } else { "[APP]" }
        Write-Host "  [OK] $icon $service`: $($serviceInfo.Description) (Port: $($serviceInfo.Port))" -ForegroundColor Green
    }
    
    Write-Host "`nRun Statistics:" -ForegroundColor Yellow
    Write-Host "  • Services running: $($ProcessedServices.Count)" -ForegroundColor White
    Write-Host "  • Tag used: $Tag" -ForegroundColor White
    Write-Host "  • Registry: docker.io/$DockerHubUsername" -ForegroundColor White
    Write-Host "  • Run time: $($script:RunDuration)" -ForegroundColor White
    
    Write-Host "`nService URLs:" -ForegroundColor Cyan
    foreach ($service in $ProcessedServices) {
        $serviceInfo = $Services[$service]
        if (-not $serviceInfo.IsDatabase) {
            Write-Host "  • $service`: http://localhost:$($serviceInfo.Port)" -ForegroundColor Blue
        }
    }
    
    Write-Host "`nDatabase Connections:" -ForegroundColor Cyan
    Write-Host "  • PostgreSQL: localhost:5432 (user: postgres, password: 123456)" -ForegroundColor Blue
    Write-Host "  • Redis: localhost:6379" -ForegroundColor Blue
    
    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "  • Check service status: docker ps" -ForegroundColor White
    Write-Host "  • View logs: docker logs interview-[service-name]" -ForegroundColor White
    Write-Host "  • Stop services: docker stop interview-[service-name]" -ForegroundColor White
    Write-Host "  • Access API Gateway: http://localhost:8080" -ForegroundColor White
}

function Show-Help {
    Write-Header "Help - $ScriptName v$Version" "Blue"
    Write-Host "`nUsage: .\quick-run-only.ps1 [options]" -ForegroundColor Yellow
    Write-Host "`nOptions:" -ForegroundColor Yellow
    Write-Host "  -Tag [tag]         Use specific tag (default: latest)" -ForegroundColor White
    Write-Host "  -Service [name]    Run only specific service" -ForegroundColor White
    Write-Host "  -StopFirst         Stop existing containers before starting" -ForegroundColor White
    Write-Host "  -Verbose           Show detailed output" -ForegroundColor White
    Write-Host "  -Help              Show this help message" -ForegroundColor White
    
    Write-Host "`nAvailable Services:" -ForegroundColor Yellow
    foreach ($service in $Services.GetEnumerator()) {
        $icon = if ($service.Value.IsDatabase) { "[DB]" } else { "[APP]" }
        Write-Host "  - $icon $($service.Key): $($service.Value.Description) (Port: $($service.Value.Port))" -ForegroundColor Cyan
    }
    
    Write-Host "`nExamples:" -ForegroundColor Yellow
    Write-Host "  .\quick-run-only.ps1                           # Run all services" -ForegroundColor White
    Write-Host "  .\quick-run-only.ps1 -Tag v1.0.0              # Run with custom tag" -ForegroundColor White
    Write-Host "  .\quick-run-only.ps1 -Service postgres         # Run only database" -ForegroundColor White
    Write-Host "  .\quick-run-only.ps1 -StopFirst                # Stop existing containers first" -ForegroundColor White
    
    Write-Host "`nPrerequisites:" -ForegroundColor Yellow
    Write-Host "  • Docker must be installed and running" -ForegroundColor White
    Write-Host "  • Images must be pulled first (use quick-pull.ps1)" -ForegroundColor White
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

# Create Docker network
if (-not (Create-Network)) {
    Write-Step "Failed to create Docker network" "ERROR"
    exit 1
}

# Stop existing containers if requested
if ($StopFirst) {
    Stop-ExistingContainers
}

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
    $servicesToProcess = $StartupOrder
}

Write-Step "Processing $($servicesToProcess.Count) service(s) with tag: $Tag" "INFO"

# Process services
$processedServices = @()
$runSuccess = $true

foreach ($serviceName in $servicesToProcess) {
    $serviceInfo = $Services[$serviceName]
    $imageName = $serviceInfo.Image
    
    # Run service
    if (Run-Service -ServiceName $serviceName -ImageName $imageName -Tag $Tag) {
        $processedServices += $serviceName
    } else {
        $runSuccess = $false
        break
    }
}

# Calculate run duration
$script:RunDuration = (Get-Date) - $script:StartTime
$script:RunDuration = "{0:mm\:ss}" -f $script:RunDuration

# Show results
if ($runSuccess) {
    Show-RunSummary -ProcessedServices $processedServices -Tag $Tag
    Write-Header "Run Completed Successfully!" "Green"
    exit 0
} else {
    Write-Header "Run Failed!" "Red"
    Write-Host "`nPlease check the error messages above and try again." -ForegroundColor Yellow
    Write-Host "For help, run: .\quick-run-only.ps1 -Help" -ForegroundColor Cyan
    exit 1
}
