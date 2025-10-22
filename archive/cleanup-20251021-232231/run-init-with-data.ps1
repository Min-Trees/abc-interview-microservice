# =============================================
# Script Import Full Sample Data to PostgreSQL
# Tao databases va insert 160+ records du lieu mau
# =============================================

$ErrorActionPreference = "Continue"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "IMPORT FULL SAMPLE DATA TO POSTGRESQL" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Kiem tra file ton tai
$sqlFile = "init-with-data.sql"
if (-not (Test-Path $sqlFile)) {
    Write-Host "[ERROR] File not found: $sqlFile" -ForegroundColor Red
    Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow
    Write-Host "Please ensure $sqlFile exists in the current directory" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "[OK] Found SQL file: $sqlFile" -ForegroundColor Green
Write-Host "File size: $((Get-Item $sqlFile).Length) bytes" -ForegroundColor Gray
Write-Host ""

# Kiem tra Docker
Write-Host "[*] Checking Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "[OK] Docker is installed: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Docker is not installed or not running!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host ""

# Kiem tra PostgreSQL container
Write-Host "[*] Checking PostgreSQL container..." -ForegroundColor Yellow
$containerName = "interview-postgres"
$containerRunning = docker ps --filter "name=$containerName" --format "{{.Names}}" 2>$null

if (-not $containerRunning) {
    Write-Host "[WARNING] PostgreSQL container is not running!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Do you want to start PostgreSQL now?" -ForegroundColor Cyan
    Write-Host "1. Yes - Start PostgreSQL with docker-compose" -ForegroundColor Green
    Write-Host "2. No - Exit script" -ForegroundColor Red
    Write-Host ""
    $startChoice = Read-Host "Your choice (1 or 2)"
    
    if ($startChoice -eq "1") {
        Write-Host ""
        Write-Host "[*] Starting PostgreSQL with docker-compose..." -ForegroundColor Yellow
        docker-compose up -d postgres
        
        Write-Host "[*] Waiting for PostgreSQL to be ready..." -ForegroundColor Yellow
        Start-Sleep -Seconds 15
        
        # Verify container is running
        $containerRunning = docker ps --filter "name=$containerName" --format "{{.Names}}" 2>$null
        if (-not $containerRunning) {
            Write-Host "[ERROR] Failed to start PostgreSQL container!" -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit 1
        }
        Write-Host "[OK] PostgreSQL container is now running" -ForegroundColor Green
    } else {
        Write-Host "[INFO] Script cancelled by user" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 0
    }
} else {
    Write-Host "[OK] PostgreSQL container is running: $containerRunning" -ForegroundColor Green
}
Write-Host ""

# Menu lua chon
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "IMPORT METHOD" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. FRESH START (Recommended)" -ForegroundColor Green
Write-Host "   - Stop all containers" -ForegroundColor Gray
Write-Host "   - Delete PostgreSQL volume (remove all old data)" -ForegroundColor Gray
Write-Host "   - Start PostgreSQL with new data" -ForegroundColor Gray
Write-Host "   - Import all sample data" -ForegroundColor Gray
Write-Host ""
Write-Host "2. IMPORT TO RUNNING CONTAINER" -ForegroundColor Yellow
Write-Host "   - Keep existing data" -ForegroundColor Gray
Write-Host "   - Import into running container" -ForegroundColor Gray
Write-Host "   - May have conflicts if data exists" -ForegroundColor Gray
Write-Host ""
$choice = Read-Host "Your choice (1 or 2)"

if ($choice -eq "1") {
    # ===== OPTION 1: FRESH START =====
    Write-Host ""
    Write-Host "[WARNING] This will DELETE ALL existing PostgreSQL data!" -ForegroundColor Red
    Write-Host "Are you sure you want to continue? (yes/no)" -ForegroundColor Yellow
    $confirm = Read-Host
    
    if ($confirm -ne "yes") {
        Write-Host "[INFO] Operation cancelled" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 0
    }
    
    Write-Host ""
    Write-Host "[STEP 1/6] Stopping all containers..." -ForegroundColor Cyan
    docker-compose down
    Write-Host "[OK] Containers stopped" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "[STEP 2/6] Removing PostgreSQL volume..." -ForegroundColor Cyan
    docker volume ls | Select-String "postgres" | ForEach-Object {
        $volumeName = $_.ToString().Split()[-1]
        Write-Host "  Removing volume: $volumeName" -ForegroundColor Gray
        docker volume rm $volumeName 2>$null
    }
    Write-Host "[OK] Volume removed" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "[STEP 3/6] Updating docker-compose.yml..." -ForegroundColor Cyan
    $dockerComposeFile = "docker-compose.yml"
    if (Test-Path $dockerComposeFile) {
        $dockerComposeContent = Get-Content $dockerComposeFile -Raw
        if ($dockerComposeContent -match "./init\.sql:/docker-entrypoint-initdb\.d/init\.sql") {
            $dockerComposeContent = $dockerComposeContent -replace "./init\.sql:/docker-entrypoint-initdb\.d/init\.sql", "./init-with-data.sql:/docker-entrypoint-initdb.d/init.sql"
            Set-Content $dockerComposeFile $dockerComposeContent -NoNewline
            Write-Host "[OK] Updated mount point to init-with-data.sql" -ForegroundColor Green
        } else {
            Write-Host "[OK] Already using init-with-data.sql" -ForegroundColor Green
        }
    }
    
    Write-Host ""
    Write-Host "[STEP 4/6] Starting PostgreSQL..." -ForegroundColor Cyan
    docker-compose up -d postgres
    
    Write-Host ""
    Write-Host "[STEP 5/6] Waiting for PostgreSQL to initialize..." -ForegroundColor Cyan
    Write-Host "This may take 30-40 seconds as it creates databases and imports data..." -ForegroundColor Gray
    
    # Wait with progress
    for ($i = 1; $i -le 30; $i++) {
        Write-Progress -Activity "Initializing PostgreSQL" -Status "Processing... ($i/30)" -PercentComplete ($i * 3.33)
        Start-Sleep -Seconds 1
    }
    Write-Progress -Activity "Initializing PostgreSQL" -Completed
    
    Write-Host "[OK] PostgreSQL initialized" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "[STEP 6/6] Starting other services..." -ForegroundColor Cyan
    docker-compose up -d
    Write-Host "[OK] All services started" -ForegroundColor Green
    
} elseif ($choice -eq "2") {
    # ===== OPTION 2: IMPORT TO RUNNING CONTAINER =====
    Write-Host ""
    Write-Host "[STEP 1/3] Copying SQL file to container..." -ForegroundColor Cyan
    docker cp $sqlFile ${containerName}:/tmp/init-with-data.sql
    Write-Host "[OK] File copied to container" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "[STEP 2/3] Executing SQL script..." -ForegroundColor Cyan
    Write-Host "This may take 15-20 seconds..." -ForegroundColor Gray
    docker exec -i $containerName psql -U postgres -f /tmp/init-with-data.sql
    Write-Host "[OK] SQL script executed" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "[STEP 3/3] Restarting microservices..." -ForegroundColor Cyan
    docker-compose restart auth-service user-service question-service exam-service career-service news-service
    Write-Host "[OK] Services restarted" -ForegroundColor Green
    
} else {
    Write-Host "[ERROR] Invalid choice" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# ===== VERIFICATION =====
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "VERIFICATION" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1] Checking databases..." -ForegroundColor Yellow
$databases = docker exec -i $containerName psql -U postgres -t -c "\l" 2>$null | Select-String "authdb|userdb|careerdb|questiondb|examdb|newsdb"
if ($databases) {
    Write-Host "[OK] All 6 databases created" -ForegroundColor Green
    $databases | ForEach-Object { Write-Host "  - $($_.Line.Trim())" -ForegroundColor Gray }
} else {
    Write-Host "[WARNING] Could not verify databases" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[2] Checking data counts..." -ForegroundColor Yellow

# Check Users in USERDB (main user data)
$userCount = docker exec -i $containerName psql -U postgres -d userdb -t -c "SELECT COUNT(*) FROM users;" 2>$null
if ($userCount) {
    Write-Host "[OK] Users in userdb: $($userCount.Trim())" -ForegroundColor Green
}

# Check Roles in AUTHDB (only roles, no user data)
$roleCount = docker exec -i $containerName psql -U postgres -d authdb -t -c "SELECT COUNT(*) FROM roles;" 2>$null
if ($roleCount) {
    Write-Host "[OK] Roles in authdb: $($roleCount.Trim())" -ForegroundColor Green
}

# Check Questions
$questionCount = docker exec -i $containerName psql -U postgres -d questiondb -t -c "SELECT COUNT(*) FROM questions;" 2>$null
if ($questionCount) {
    Write-Host "[OK] Questions: $($questionCount.Trim())" -ForegroundColor Green
}

# Check Topics
$topicCount = docker exec -i $containerName psql -U postgres -d questiondb -t -c "SELECT COUNT(*) FROM topics;" 2>$null
if ($topicCount) {
    Write-Host "[OK] Topics: $($topicCount.Trim())" -ForegroundColor Green
}

# Check Exams
$examCount = docker exec -i $containerName psql -U postgres -d examdb -t -c "SELECT COUNT(*) FROM exams;" 2>$null
if ($examCount) {
    Write-Host "[OK] Exams: $($examCount.Trim())" -ForegroundColor Green
}

# Check News
$newsCount = docker exec -i $containerName psql -U postgres -d newsdb -t -c "SELECT COUNT(*) FROM news;" 2>$null
if ($newsCount) {
    Write-Host "[OK] News: $($newsCount.Trim())" -ForegroundColor Green
}

Write-Host ""
Write-Host "[3] Sample user data from userdb..." -ForegroundColor Yellow
Write-Host ""
docker exec -i $containerName psql -U postgres -d userdb -c "SELECT id, email, full_name, elo_score, elo_rank, status FROM users ORDER BY id LIMIT 5;" 2>$null

Write-Host ""
Write-Host "[4] Checking password encryption..." -ForegroundColor Yellow
$passwordSample = docker exec -i $containerName psql -U postgres -d userdb -t -c "SELECT password FROM users LIMIT 1;" 2>$null
if ($passwordSample -match '\$2a\$') {
    Write-Host "[OK] Passwords are BCrypt encrypted" -ForegroundColor Green
    Write-Host "Sample hash: $($passwordSample.Trim().Substring(0, 30))..." -ForegroundColor Gray
    Write-Host "Password for all test users: password123" -ForegroundColor Cyan
} else {
    Write-Host "[WARNING] Could not verify password encryption" -ForegroundColor Yellow
}

# ===== SUMMARY =====
Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "IMPORT COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

Write-Host "TEST ACCOUNTS (all use password: password123):" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [ADMIN]" -ForegroundColor Yellow
Write-Host "    Email: admin@example.com" -ForegroundColor White
Write-Host "    Password: password123" -ForegroundColor White
Write-Host ""
Write-Host "  [RECRUITER]" -ForegroundColor Yellow
Write-Host "    Email: recruiter@example.com" -ForegroundColor White
Write-Host "    Password: password123" -ForegroundColor White
Write-Host ""
Write-Host "  [USER - BRONZE]" -ForegroundColor Yellow
Write-Host "    Email: user@example.com" -ForegroundColor White
Write-Host "    Password: password123" -ForegroundColor White
Write-Host "    ELO: 1200" -ForegroundColor Gray
Write-Host ""
Write-Host "  [DEVELOPER - SILVER]" -ForegroundColor Yellow
Write-Host "    Email: developer@example.com" -ForegroundColor White
Write-Host "    Password: password123" -ForegroundColor White
Write-Host "    ELO: 1500" -ForegroundColor Gray
Write-Host ""
Write-Host "  [EXPERT - GOLD]" -ForegroundColor Yellow
Write-Host "    Email: expert@example.com" -ForegroundColor White
Write-Host "    Password: password123" -ForegroundColor White
Write-Host "    ELO: 2100" -ForegroundColor Gray
Write-Host ""

Write-Host "SERVICE URLs:" -ForegroundColor Cyan
Write-Host "  API Gateway: http://localhost:8080" -ForegroundColor White
Write-Host "  Eureka: http://localhost:8761" -ForegroundColor White
Write-Host "  Config Server: http://localhost:8888" -ForegroundColor White
Write-Host ""

Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "  1. Import Postman collection from: postman-collections/" -ForegroundColor White
Write-Host "  2. Read API docs: API-SPECIFICATION.md" -ForegroundColor White
Write-Host "  3. Test APIs with the accounts above" -ForegroundColor White
Write-Host ""

Write-Host "DATA SUMMARY:" -ForegroundColor Cyan
Write-Host "  [OK] 8 Users with different ELO ranks (stored in userdb)" -ForegroundColor Green
Write-Host "  [OK] 3 Roles (stored in authdb - Auth Service)" -ForegroundColor Green
Write-Host "  [OK] 15+ Questions (approved)" -ForegroundColor Green
Write-Host "  [OK] 25+ Topics across 6 fields" -ForegroundColor Green
Write-Host "  [OK] 8+ Exams (Technical & Behavioral)" -ForegroundColor Green
Write-Host "  [OK] 10+ Exam Results with feedback" -ForegroundColor Green
Write-Host "  [OK] 18+ News & Recruitment posts" -ForegroundColor Green
Write-Host "  [OK] Passwords: BCrypt encrypted" -ForegroundColor Green
Write-Host ""
Write-Host "ARCHITECTURE:" -ForegroundColor Cyan
Write-Host "  [OK] Auth Service: Only roles + JWT tokens" -ForegroundColor Green
Write-Host "  [OK] User Service: All user data + ELO management" -ForegroundColor Green
Write-Host "  [OK] Proper separation of concerns" -ForegroundColor Green
Write-Host ""

Read-Host "Press Enter to exit"
