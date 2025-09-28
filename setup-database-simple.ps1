# Script to setup database with roles and sample data
# This will create all necessary tables and insert sample data

Write-Host "Setting up database with roles and sample data..." -ForegroundColor Blue

# Database connection parameters
$dbHost = "localhost"
$dbPort = "5432"
$dbName = "interview_db"
$dbUser = "postgres"
$dbPassword = "postgres"

# Function to execute SQL
function Execute-SQL {
    param(
        [string]$SqlFile,
        [string]$Description
    )
    
    Write-Host "`n$Description..." -ForegroundColor Yellow
    
    try {
        # Use psql to execute SQL file
        $env:PGPASSWORD = $dbPassword
        $result = psql -h $dbHost -p $dbPort -U $dbUser -d $dbName -f $SqlFile 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "SUCCESS: $Description completed successfully" -ForegroundColor Green
            return $true
        } else {
            Write-Host "ERROR: $Description failed:" -ForegroundColor Red
            Write-Host $result -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "ERROR executing $Description : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Check if PostgreSQL is running
Write-Host "`nChecking PostgreSQL connection..." -ForegroundColor Blue
try {
    $env:PGPASSWORD = $dbPassword
    $testResult = psql -h $dbHost -p $dbPort -U $dbUser -d $dbName -c "SELECT 1;" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: PostgreSQL connection successful" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Cannot connect to PostgreSQL. Please check if the service is running." -ForegroundColor Red
        Write-Host "Make sure Docker containers are running: docker-compose up -d" -ForegroundColor Yellow
        exit 1
    }
}
catch {
    Write-Host "ERROR: PostgreSQL connection failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please start the database first: docker-compose up -d postgres" -ForegroundColor Yellow
    exit 1
}

# Execute the SQL script
$success = Execute-SQL -SqlFile "create-roles.sql" -Description "Creating roles and sample data"

if ($success) {
    Write-Host "`nDatabase setup completed successfully!" -ForegroundColor Green
    Write-Host "`nSummary:" -ForegroundColor Blue
    Write-Host "- SUCCESS: Roles created (USER, ADMIN, RECRUITER)" -ForegroundColor Green
    Write-Host "- SUCCESS: Test users created with different roles" -ForegroundColor Green
    Write-Host "- SUCCESS: Sample data inserted (fields, topics, levels, question types)" -ForegroundColor Green
    Write-Host "- SUCCESS: All necessary tables created" -ForegroundColor Green
    
    Write-Host "`nTest Accounts:" -ForegroundColor Yellow
    Write-Host "User: testuser1@example.com / password123 (USER role)" -ForegroundColor Cyan
    Write-Host "Admin: admin@example.com / admin123 (ADMIN role)" -ForegroundColor Cyan
    Write-Host "Recruiter: recruiter@example.com / recruiter123 (RECRUITER role)" -ForegroundColor Cyan
    
    Write-Host "`nYou can now test the APIs with these accounts!" -ForegroundColor Green
} else {
    Write-Host "`nDatabase setup failed. Please check the errors above." -ForegroundColor Red
    exit 1
}
