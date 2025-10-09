# =============================================================================
# Quick Push Script with Database for Interview Microservice ABC
# =============================================================================
# Description: Build and push all microservices including database to Docker Hub
# Usage: .\quick-push-with-db.ps1 [options]
# Options:
#   -Tag <tag>: Custom tag for images (default: latest)
#   -Service <name>: Push only specific service
#   -NoBuild: Skip building, only push existing images
#   -NoCache: Build without using cache
#   -IncludeDB: Include database initialization scripts
#   -Verbose: Show detailed output
#   -Help: Show help message
# =============================================================================

param(
    [string]$Tag = "latest",
    [string]$Service = "",
    [switch]$NoBuild,
    [switch]$NoCache,
    [switch]$IncludeDB,
    [switch]$Verbose,
    [switch]$Help
)

# =============================================================================
# CONFIGURATION
# =============================================================================
$ScriptName = "Quick Push with Database Script"
$Version = "3.0.0"
$DockerHubUsername = "mintreestdmu"
$RegistryUrl = "docker.io"

# Service configuration including database
$Services = @{
    "postgres" = @{Image = "interview-postgres"; Description = "PostgreSQL Database with Initialization"}
    "redis" = @{Image = "interview-redis"; Description = "Redis Cache Service"}
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

# Database configuration
$DatabaseConfig = @{
    "postgres" = @{
        BaseImage = "postgres:15-alpine"
        InitScript = "init.sql"
        Description = "PostgreSQL Database with Interview Schema"
    }
    "redis" = @{
        BaseImage = "redis:7-alpine"
        Description = "Redis Cache for Session Management"
    }
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
        "DB" { "DarkCyan" }
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

function Build-DatabaseImage {
    param([string]$ServiceName, [string]$ImageName, [string]$Tag)
    
    Write-Step "Building database image: $ServiceName" "DB"
    
    $buildArgs = @()
    if ($NoCache) {
        $buildArgs += "--no-cache"
    }
    
    if ($Verbose) {
        $buildArgs += "--progress=plain"
    }
    
    try {
        # Create temporary Dockerfile for database
        $dockerfileContent = ""
        
        if ($ServiceName -eq "postgres") {
            $dockerfileContent = @"
FROM $($DatabaseConfig[$ServiceName].BaseImage)

# Copy initialization script
COPY $($DatabaseConfig[$ServiceName].InitScript) /docker-entrypoint-initdb.d/

# Set proper permissions
RUN chmod 644 /docker-entrypoint-initdb.d/$($DatabaseConfig[$ServiceName].InitScript)

# Expose port
EXPOSE 5432

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
    CMD pg_isready -U postgres || exit 1
"@
        } elseif ($ServiceName -eq "redis") {
            $dockerfileContent = @"
FROM $($DatabaseConfig[$ServiceName].BaseImage)

# Expose port
EXPOSE 6379

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
    CMD redis-cli ping || exit 1
"@
        }
        
        # Write temporary Dockerfile
        $tempDockerfile = "Dockerfile.$ServiceName"
        $dockerfileContent | Out-File -FilePath $tempDockerfile -Encoding UTF8
        
        $buildCommand = "docker build $($buildArgs -join ' ') -f $tempDockerfile -t $ImageName`:$Tag ."
        if ($Verbose) {
            Write-Host "Executing: $buildCommand" -ForegroundColor Gray
        }
        
        Invoke-Expression $buildCommand
        
        # Clean up temporary Dockerfile
        Remove-Item $tempDockerfile -Force -ErrorAction SilentlyContinue
        
        if ($LASTEXITCODE -eq 0) {
            Write-Step "Database image $ServiceName built successfully" "SUCCESS"
            return $true
        } else {
            Write-Step "Failed to build database image: $ServiceName" "ERROR"
            return $false
        }
    } catch {
        Write-Step "Error building database image $ServiceName`: $($_.Exception.Message)" "ERROR"
        return $false
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
        if ($DatabaseConfig.ContainsKey($ServiceName)) {
            # Build database image
            if (-not (Build-DatabaseImage -ServiceName $ServiceName -ImageName $ImageName -Tag $Tag)) {
                return $false
            }
        } else {
            # Build regular service
            if (-not (Build-Service -ServiceName $ServiceName -ImageName $ImageName -Tag $Tag)) {
                return $false
            }
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

function Create-DockerComposeWithDB {
    param([string]$Tag)
    
    Write-Step "Creating docker-compose.yml with database images" "INFO"
    
    $composeContent = @"
version: '3.8'

services:
  # 🗄️ DATABASE
  postgres:
    image: $DockerHubUsername/interview-postgres:${Tag}
    container_name: interview-postgres
    environment:
      POSTGRES_DB: `${POSTGRES_DB:-postgres}
      POSTGRES_USER: `${POSTGRES_USER:-postgres}
      POSTGRES_PASSWORD: `${POSTGRES_PASSWORD:-123456}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - interview-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  # 🔴 REDIS
  redis:
    image: $DockerHubUsername/interview-redis:${Tag}
    container_name: interview-redis
    ports:
      - "6379:6379"
    networks:
      - interview-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # 🔧 CONFIG SERVER
  config-service:
    image: $DockerHubUsername/interview-config-service:${Tag}
    container_name: interview-config-service
    ports:
      - "`${CONFIG_SERVICE_PORT:-8888}:8888"
    environment:
      SPRING_PROFILES_ACTIVE: native
      CONFIG_SERVER_URI: `${CONFIG_SERVER_URI:-http://config-service:8888}
    networks:
      - interview-network
    depends_on:
      postgres:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8888/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # 🔍 DISCOVERY SERVER
  discovery-service:
    image: $DockerHubUsername/interview-discovery-service:${Tag}
    container_name: interview-discovery-service
    ports:
      - "`${DISCOVERY_SERVICE_PORT:-8761}:8761"
    environment:
      SPRING_PROFILES_ACTIVE: docker
      EUREKA_DEFAULT_ZONE: `${EUREKA_DEFAULT_ZONE:-http://discovery-service:8761/eureka/}
    networks:
      - interview-network
    depends_on:
      config-service:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8761/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # 🌐 API GATEWAY
  gateway-service:
    image: $DockerHubUsername/interview-gateway-service:${Tag}
    container_name: interview-gateway-service
    ports:
      - "`${GATEWAY_SERVICE_PORT:-8080}:8080"
    environment:
      SPRING_PROFILES_ACTIVE: docker
      JWT_SECRET: `${JWT_SECRET}
      REDIS_HOST: `${REDIS_HOST:-redis}
      REDIS_PORT: `${REDIS_PORT:-6379}
    networks:
      - interview-network
    depends_on:
      discovery-service:
        condition: service_healthy
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # 🔐 AUTH SERVICE
  auth-service:
    image: $DockerHubUsername/interview-auth-service:${Tag}
    container_name: interview-auth-service
    ports:
      - "`${AUTH_SERVICE_PORT:-8081}:8081"
    environment:
      SPRING_PROFILES_ACTIVE: docker
      SPRING_DATASOURCE_URL: jdbc:postgresql://`${POSTGRES_HOST:-postgres}:`${POSTGRES_PORT:-5432}/`${AUTH_DB:-authdb}
      SPRING_DATASOURCE_USERNAME: `${POSTGRES_USER:-postgres}
      SPRING_DATASOURCE_PASSWORD: `${POSTGRES_PASSWORD:-123456}
      JWT_SECRET: `${JWT_SECRET}
      JWT_ACCESS_MINUTES: `${JWT_ACCESS_MINUTES:-30}
      JWT_REFRESH_DAYS: `${JWT_REFRESH_DAYS:-7}
      JWT_ISSUER: `${JWT_ISSUER:-http://auth-service:8081}
      MAIL_HOST: `${MAIL_HOST:-smtp.gmail.com}
      MAIL_PORT: `${MAIL_PORT:-587}
      MAIL_USERNAME: `${MAIL_USERNAME}
      MAIL_PASSWORD: `${MAIL_PASSWORD}
    networks:
      - interview-network
    depends_on:
      postgres:
        condition: service_healthy
      discovery-service:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8081/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # 👤 USER SERVICE
  user-service:
    image: $DockerHubUsername/interview-user-service:${Tag}
    container_name: interview-user-service
    ports:
      - "`${USER_SERVICE_PORT:-8082}:8082"
    environment:
      SPRING_PROFILES_ACTIVE: docker
      SPRING_DATASOURCE_URL: jdbc:postgresql://`${POSTGRES_HOST:-postgres}:`${POSTGRES_PORT:-5432}/`${USER_DB:-userdb}
      SPRING_DATASOURCE_USERNAME: `${POSTGRES_USER:-postgres}
      SPRING_DATASOURCE_PASSWORD: `${POSTGRES_PASSWORD:-123456}
      JWT_SECRET: `${JWT_SECRET}
    networks:
      - interview-network
    depends_on:
      postgres:
        condition: service_healthy
      discovery-service:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8082/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # 🎯 CAREER SERVICE
  career-service:
    image: $DockerHubUsername/interview-career-service:${Tag}
    container_name: interview-career-service
    ports:
      - "`${CAREER_SERVICE_PORT:-8084}:8084"
    environment:
      SPRING_PROFILES_ACTIVE: docker
      SPRING_DATASOURCE_URL: jdbc:postgresql://`${POSTGRES_HOST:-postgres}:`${POSTGRES_PORT:-5432}/`${CAREER_DB:-careerdb}
      SPRING_DATASOURCE_USERNAME: `${POSTGRES_USER:-postgres}
      SPRING_DATASOURCE_PASSWORD: `${POSTGRES_PASSWORD:-123456}
      JWT_SECRET: `${JWT_SECRET}
    networks:
      - interview-network
    depends_on:
      postgres:
        condition: service_healthy
      discovery-service:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8084/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # ❓ QUESTION SERVICE
  question-service:
    image: $DockerHubUsername/interview-question-service:${Tag}
    container_name: interview-question-service
    ports:
      - "`${QUESTION_SERVICE_PORT:-8085}:8085"
    environment:
      SPRING_PROFILES_ACTIVE: docker
      SPRING_DATASOURCE_URL: jdbc:postgresql://`${POSTGRES_HOST:-postgres}:`${POSTGRES_PORT:-5432}/`${QUESTION_DB:-questiondb}
      SPRING_DATASOURCE_USERNAME: `${POSTGRES_USER:-postgres}
      SPRING_DATASOURCE_PASSWORD: `${POSTGRES_PASSWORD:-123456}
      JWT_SECRET: `${JWT_SECRET}
    networks:
      - interview-network
    depends_on:
      postgres:
        condition: service_healthy
      discovery-service:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8085/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # 📝 EXAM SERVICE
  exam-service:
    image: $DockerHubUsername/interview-exam-service:${Tag}
    container_name: interview-exam-service
    ports:
      - "`${EXAM_SERVICE_PORT:-8086}:8086"
    environment:
      SPRING_PROFILES_ACTIVE: docker
      SPRING_DATASOURCE_URL: jdbc:postgresql://`${POSTGRES_HOST:-postgres}:`${POSTGRES_PORT:-5432}/`${EXAM_DB:-examdb}
      SPRING_DATASOURCE_USERNAME: `${POSTGRES_USER:-postgres}
      SPRING_DATASOURCE_PASSWORD: `${POSTGRES_PASSWORD:-123456}
      JWT_SECRET: `${JWT_SECRET}
    networks:
      - interview-network
    depends_on:
      postgres:
        condition: service_healthy
      discovery-service:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8086/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # 📰 NEWS SERVICE
  news-service:
    image: $DockerHubUsername/interview-news-service:${Tag}
    container_name: interview-news-service
    ports:
      - "`${NEWS_SERVICE_PORT:-8087}:8087"
    environment:
      SPRING_PROFILES_ACTIVE: docker
      SPRING_DATASOURCE_URL: jdbc:postgresql://`${POSTGRES_HOST:-postgres}:`${POSTGRES_PORT:-5432}/`${NEWS_DB:-newsdb}
      SPRING_DATASOURCE_USERNAME: `${POSTGRES_USER:-postgres}
      SPRING_DATASOURCE_PASSWORD: `${POSTGRES_PASSWORD:-123456}
      JWT_SECRET: `${JWT_SECRET}
    networks:
      - interview-network
    depends_on:
      postgres:
        condition: service_healthy
      discovery-service:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8087/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3


volumes:
  postgres_data:
    driver: local

networks:
  interview-network:
    driver: bridge
"@
    
    $composeContent | Out-File -FilePath "docker-compose-with-db.yml" -Encoding UTF8
    Write-Step "Created docker-compose-with-db.yml" "SUCCESS"
}

function Show-PushSummary {
    param([array]$ProcessedServices, [string]$Tag)
    
    Write-Header "Push Summary with Database" "Green"
    
    Write-Host "`nServices pushed:" -ForegroundColor Yellow
    foreach ($service in $ProcessedServices) {
        $serviceInfo = $Services[$service]
        $icon = if ($DatabaseConfig.ContainsKey($service)) { "[DB]" } else { "[APP]" }
        Write-Host "  [OK] $icon $service`: $($serviceInfo.Description)" -ForegroundColor Green
    }
    
    Write-Host "`nPush Statistics:" -ForegroundColor Yellow
    Write-Host "  • Services processed: $($ProcessedServices.Count)" -ForegroundColor White
    Write-Host "  • Tag used: $Tag" -ForegroundColor White
    Write-Host "  • Registry: $RegistryUrl/$DockerHubUsername" -ForegroundColor White
    Write-Host "  • Push time: $($script:PushDuration)" -ForegroundColor White
    Write-Host "  • Database included: $($IncludeDB.IsPresent)" -ForegroundColor White
    
    Write-Host "`nDocker Hub URLs:" -ForegroundColor Cyan
    foreach ($service in $ProcessedServices) {
        $serviceInfo = $Services[$service]
        $imageName = $serviceInfo.Image
        Write-Host "  • $service`: https://hub.docker.com/r/$DockerHubUsername/$imageName" -ForegroundColor Blue
    }
    
    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "  • Use 'docker-compose-with-db.yml' for deployment with database" -ForegroundColor White
    Write-Host "  • Run 'docker-compose -f docker-compose-with-db.yml up -d' to start" -ForegroundColor White
    Write-Host "  • Database will be automatically initialized with schema" -ForegroundColor White
    Write-Host "  • Share the Docker Hub URLs with your team" -ForegroundColor White
}

function Show-Help {
    Write-Header "Help - $ScriptName v$Version" "Blue"
    Write-Host "`nUsage: .\quick-push-with-db.ps1 [options]" -ForegroundColor Yellow
    Write-Host "`nOptions:" -ForegroundColor Yellow
    Write-Host "  -Tag [tag]         Custom tag for images (default: latest)" -ForegroundColor White
    Write-Host "  -Service [name]    Push only specific service" -ForegroundColor White
    Write-Host "  -NoBuild           Skip building, only push existing images" -ForegroundColor White
    Write-Host "  -NoCache           Build without using cache" -ForegroundColor White
    Write-Host "  -IncludeDB         Include database initialization scripts" -ForegroundColor White
    Write-Host "  -Verbose           Show detailed output" -ForegroundColor White
    Write-Host "  -Help              Show this help message" -ForegroundColor White
    
    Write-Host "`nAvailable Services:" -ForegroundColor Yellow
    foreach ($service in $Services.GetEnumerator()) {
        $icon = if ($DatabaseConfig.ContainsKey($service.Key)) { "[DB]" } else { "[APP]" }
        Write-Host "  - $icon $($service.Key): $($service.Value.Description)" -ForegroundColor Cyan
    }
    
    Write-Host "`nExamples:" -ForegroundColor Yellow
    Write-Host "  .\quick-push-with-db.ps1                           # Push all services with database" -ForegroundColor White
    Write-Host "  .\quick-push-with-db.ps1 -Tag v1.0.0              # Push with custom tag" -ForegroundColor White
    Write-Host "  .\quick-push-with-db.ps1 -Service postgres         # Push only database" -ForegroundColor White
    Write-Host "  .\quick-push-with-db.ps1 -NoBuild -Tag v1.0.0     # Push existing images" -ForegroundColor White
    Write-Host "  .\quick-push-with-db.ps1 -Verbose -NoCache        # Verbose build without cache" -ForegroundColor White
    
    Write-Host "`nPrerequisites:" -ForegroundColor Yellow
    Write-Host "  • Docker must be installed and running" -ForegroundColor White
    Write-Host "  • Must be logged in to Docker Hub (docker login)" -ForegroundColor White
    Write-Host "  • Docker Hub username: $DockerHubUsername" -ForegroundColor White
    Write-Host "  • init.sql file must exist in project root" -ForegroundColor White
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

# Check for database initialization script
if ($IncludeDB -and -not (Test-Path "init.sql")) {
    Write-Step "init.sql not found. Database images will be created without initialization script." "WARNING"
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

# Create docker-compose file with database
if ($pushSuccess) {
    Create-DockerComposeWithDB -Tag $Tag
}

# Calculate push duration
$script:PushDuration = (Get-Date) - $script:StartTime
$script:PushDuration = "{0:mm\:ss}" -f $script:PushDuration

# Show results
if ($pushSuccess) {
    Show-PushSummary -ProcessedServices $processedServices -Tag $Tag
    Write-Header "Push with Database Completed Successfully!" "Green"
    exit 0
} else {
    Write-Header "Push Failed!" "Red"
    Write-Host "`nPlease check the error messages above and try again." -ForegroundColor Yellow
    Write-Host "For help, run: .\quick-push-with-db.ps1 -Help" -ForegroundColor Cyan
    exit 1
}
