# Script to setup database with roles and sample data
# This will create all necessary tables and insert sample data

Write-Host "🗄️ Setting up database with roles and sample data..." -ForegroundColor Blue

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
    
    Write-Host "`n📝 $Description..." -ForegroundColor Yellow
    
    try {
        # Use psql to execute SQL file
        $env:PGPASSWORD = $dbPassword
        $result = psql -h $dbHost -p $dbPort -U $dbUser -d $dbName -f $SqlFile 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ $Description completed successfully" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ $Description failed:" -ForegroundColor Red
            Write-Host $result -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "❌ Error executing $Description : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Check if PostgreSQL is running
Write-Host "`n🔍 Checking PostgreSQL connection..." -ForegroundColor Blue
try {
    $env:PGPASSWORD = $dbPassword
    $testResult = psql -h $dbHost -p $dbPort -U $dbUser -d $dbName -c "SELECT 1;" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ PostgreSQL connection successful" -ForegroundColor Green
    } else {
        Write-Host "❌ Cannot connect to PostgreSQL. Please check if the service is running." -ForegroundColor Red
        Write-Host "Make sure Docker containers are running: docker-compose up -d" -ForegroundColor Yellow
        exit 1
    }
}
catch {
    Write-Host "❌ PostgreSQL connection failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please start the database first: docker-compose up -d postgres" -ForegroundColor Yellow
    exit 1
}

# Execute the SQL script
$success = Execute-SQL -SqlFile "create-roles.sql" -Description "Creating roles and sample data"

if ($success) {
    Write-Host "`n🎉 Database setup completed successfully!" -ForegroundColor Green
    Write-Host "`n📊 Summary:" -ForegroundColor Blue
    Write-Host "- ✅ Roles created (USER, ADMIN, RECRUITER)" -ForegroundColor Green
    Write-Host "- ✅ Test users created with different roles" -ForegroundColor Green
    Write-Host "- ✅ Sample data inserted (fields, topics, levels, question types)" -ForegroundColor Green
    Write-Host "- ✅ All necessary tables created" -ForegroundColor Green
    
    Write-Host "`n🔑 Test Accounts:" -ForegroundColor Yellow
    Write-Host "User: testuser1@example.com / password123 (USER role)" -ForegroundColor Cyan
    Write-Host "Admin: admin@example.com / admin123 (ADMIN role)" -ForegroundColor Cyan
    Write-Host "Recruiter: recruiter@example.com / recruiter123 (RECRUITER role)" -ForegroundColor Cyan
    
    Write-Host "`n🚀 You can now test the APIs with these accounts!" -ForegroundColor Green
} else {
    Write-Host "`n❌ Database setup failed. Please check the errors above." -ForegroundColor Red
    exit 1
}
