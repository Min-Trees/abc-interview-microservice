# =============================================================================
# Quick Create Roles Script for Interview Microservice ABC
# =============================================================================
# Description: Quickly create default roles and database schema
# Usage: .\quick-create-roles.ps1 [options]
# Options:
#   -Database [db]: Database name (default: postgres)
#   -Host [host]: Database host (default: localhost)
#   -Port [port]: Database port (default: 5432)
#   -Username [user]: Database username (default: postgres)
#   -Password [pass]: Database password (default: 123456)
#   -Verbose: Show detailed output
#   -Help: Show help message
# =============================================================================

param(
    [string]$Database = "postgres",
    [string]$Host = "localhost",
    [int]$Port = 5432,
    [string]$Username = "postgres",
    [string]$Password = "123456",
    [switch]$Verbose,
    [switch]$Help
)

# =============================================================================
# CONFIGURATION
# =============================================================================
$ScriptName = "Quick Create Roles Script"
$Version = "1.0.0"

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
        "DB" { "Blue" }
        "CREATE" { "Magenta" }
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

function Execute-SqlFile {
    param([string]$SqlFile, [string]$Host, [int]$Port, [string]$Database, [string]$Username, [string]$Password)
    
    Write-Step "Executing SQL file: $SqlFile" "DB"
    
    try {
        $env:PGPASSWORD = $Password
        
        if ($Verbose) {
            psql -h $Host -p $Port -U $Username -d $Database -f $SqlFile
        } else {
            psql -h $Host -p $Port -U $Username -d $Database -f $SqlFile 2>$null
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Step "SQL file executed successfully" "SUCCESS"
            return $true
        } else {
            Write-Step "Failed to execute SQL file" "ERROR"
            return $false
        }
    } catch {
        Write-Step "Error executing SQL file: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Create-QuickRoles {
    param([string]$Host, [int]$Port, [string]$Database, [string]$Username, [string]$Password)
    
    Write-Step "Creating quick roles and schema..." "CREATE"
    
    $quickSql = @"
-- Quick roles creation script
-- Create roles table
CREATE TABLE IF NOT EXISTS roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    permissions TEXT[],
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role_id BIGINT REFERENCES roles(id),
    date_of_birth DATE,
    address TEXT,
    is_studying BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    elo_score INTEGER DEFAULT 1000,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default roles
INSERT INTO roles (name, description, permissions) VALUES 
('USER', 'Regular user with basic permissions', ARRAY['READ']),
('ADMIN', 'Administrator with full system access', ARRAY['READ', 'WRITE', 'DELETE', 'ADMIN']),
('RECRUITER', 'Recruiter with hiring and management permissions', ARRAY['READ', 'WRITE', 'RECRUIT']),
('MODERATOR', 'Moderator with content management permissions', ARRAY['READ', 'WRITE', 'MODERATE']),
('SUPER_ADMIN', 'Super administrator with all permissions', ARRAY['READ', 'WRITE', 'DELETE', 'ADMIN', 'SUPER']),
('GUEST', 'Guest user with limited permissions', ARRAY['READ'])
ON CONFLICT (name) DO UPDATE SET 
    description = EXCLUDED.description,
    permissions = EXCLUDED.permissions,
    updated_at = CURRENT_TIMESTAMP;

-- Create test users
INSERT INTO users (email, password, full_name, role_id, date_of_birth, address, is_studying, status, elo_score) VALUES 
('user@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'Test User', 1, '1995-01-15', '123 Main Street, Ho Chi Minh City', false, 'ACTIVE', 1000),
('admin@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'Admin User', 2, '1990-05-20', '456 Admin Street, Ho Chi Minh City', false, 'ACTIVE', 1500),
('recruiter@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'Recruiter User', 3, '1988-12-10', '789 Recruiter Street, Ho Chi Minh City', false, 'ACTIVE', 1200)
ON CONFLICT (email) DO NOTHING;

-- Display results
SELECT 'Roles created:' as info;
SELECT id, name, description, permissions FROM roles ORDER BY id;

SELECT 'Users created:' as info;
SELECT id, email, full_name, role_id, status FROM users ORDER BY id;
"@
    
    # Write SQL to temporary file
    $tempSqlFile = "temp_quick_roles.sql"
    $quickSql | Out-File -FilePath $tempSqlFile -Encoding UTF8
    
    try {
        $success = Execute-SqlFile -SqlFile $tempSqlFile -Host $Host -Port $Port -Database $Database -Username $Username -Password $Password
        return $success
    } finally {
        # Clean up temporary file
        if (Test-Path $tempSqlFile) {
            Remove-Item $tempSqlFile -Force
        }
    }
}

function Show-QuickSummary {
    param([string]$Database, [string]$Host, [int]$Port)
    
    Write-Header "Quick Roles Creation Summary" "Green"
    
    Write-Host "`nDatabase Configuration:" -ForegroundColor Yellow
    Write-Host "  • Database: $Database" -ForegroundColor White
    Write-Host "  • Host: $Host`:$Port" -ForegroundColor White
    Write-Host "  • Username: $Username" -ForegroundColor White
    
    Write-Host "`nRoles Created:" -ForegroundColor Yellow
    Write-Host "  • USER: Regular user with basic permissions" -ForegroundColor White
    Write-Host "  • ADMIN: Administrator with full system access" -ForegroundColor White
    Write-Host "  • RECRUITER: Recruiter with hiring and management permissions" -ForegroundColor White
    Write-Host "  • MODERATOR: Moderator with content management permissions" -ForegroundColor White
    Write-Host "  • SUPER_ADMIN: Super administrator with all permissions" -ForegroundColor White
    Write-Host "  • GUEST: Guest user with limited permissions" -ForegroundColor White
    
    Write-Host "`nTest Users Created:" -ForegroundColor Yellow
    Write-Host "  • user@example.com (USER role)" -ForegroundColor White
    Write-Host "  • admin@example.com (ADMIN role)" -ForegroundColor White
    Write-Host "  • recruiter@example.com (RECRUITER role)" -ForegroundColor White
    
    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "  • Check roles: .\create-roles.ps1 -Action list" -ForegroundColor White
    Write-Host "  • Create custom role: .\create-roles.ps1 -Action create -RoleName [name]" -ForegroundColor White
    Write-Host "  • Test database connection" -ForegroundColor White
    Write-Host "  • Start your microservices" -ForegroundColor White
}

function Show-Help {
    Write-Header "Help - $ScriptName v$Version" "Blue"
    Write-Host "`nUsage: .\quick-create-roles.ps1 [options]" -ForegroundColor Yellow
    Write-Host "`nOptions:" -ForegroundColor Yellow
    Write-Host "  -Database [db]       Database name (default: postgres)" -ForegroundColor White
    Write-Host "  -Host [host]         Database host (default: localhost)" -ForegroundColor White
    Write-Host "  -Port [port]         Database port (default: 5432)" -ForegroundColor White
    Write-Host "  -Username [user]     Database username (default: postgres)" -ForegroundColor White
    Write-Host "  -Password [pass]     Database password (default: 123456)" -ForegroundColor White
    Write-Host "  -Verbose             Show detailed output" -ForegroundColor White
    Write-Host "  -Help                Show this help message" -ForegroundColor White
    
    Write-Host "`nWhat this script does:" -ForegroundColor Yellow
    Write-Host "  • Creates roles and users tables" -ForegroundColor White
    Write-Host "  • Inserts default roles (USER, ADMIN, RECRUITER, etc.)" -ForegroundColor White
    Write-Host "  • Creates test users for each role" -ForegroundColor White
    Write-Host "  • Sets up basic permissions structure" -ForegroundColor White
    
    Write-Host "`nExamples:" -ForegroundColor Yellow
    Write-Host "  .\quick-create-roles.ps1                           # Use default settings" -ForegroundColor White
    Write-Host "  .\quick-create-roles.ps1 -Database mydb            # Use custom database" -ForegroundColor White
    Write-Host "  .\quick-create-roles.ps1 -Host 192.168.1.100      # Use custom host" -ForegroundColor White
    Write-Host "  .\quick-create-roles.ps1 -Verbose                 # Show detailed output" -ForegroundColor White
    
    Write-Host "`nPrerequisites:" -ForegroundColor Yellow
    Write-Host "  • PostgreSQL must be installed and running" -ForegroundColor White
    Write-Host "  • psql command must be available in PATH" -ForegroundColor White
    Write-Host "  • Database must be accessible" -ForegroundColor White
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

# Check if psql is installed
if (-not (Test-Command "psql")) {
    Write-Step "psql is not installed or not in PATH" "ERROR"
    Write-Host "Please install PostgreSQL client tools" -ForegroundColor Yellow
    exit 1
}

Write-Step "Prerequisites validated successfully" "SUCCESS"

# Create quick roles
Write-Step "Creating roles and database schema..." "CREATE"

$success = Create-QuickRoles -Host $Host -Port $Port -Database $Database -Username $Username -Password $Password

# Calculate execution time
$script:ExecutionTime = (Get-Date) - $script:StartTime
$script:ExecutionTime = "{0:mm\:ss}" -f $script:ExecutionTime

# Show results
if ($success) {
    Show-QuickSummary -Database $Database -Host $Host -Port $Port
    Write-Header "Quick Roles Creation Completed Successfully!" "Green"
    exit 0
} else {
    Write-Header "Quick Roles Creation Failed!" "Red"
    Write-Host "`nPlease check the error messages above and try again." -ForegroundColor Yellow
    Write-Host "For help, run: .\quick-create-roles.ps1 -Help" -ForegroundColor Cyan
    exit 1
}
