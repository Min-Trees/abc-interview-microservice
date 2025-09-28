# =============================================================================
# Create Roles Script for Interview Microservice ABC
# =============================================================================
# Description: Create and manage roles in the database
# Usage: .\create-roles.ps1 [options]
# Options:
#   -Action [action]: Action to perform (create, list, delete, reset)
#   -RoleName [name]: Role name for specific operations
#   -Description [desc]: Role description
#   -Database [db]: Database name (default: postgres)
#   -Host [host]: Database host (default: localhost)
#   -Port [port]: Database port (default: 5432)
#   -Username [user]: Database username (default: postgres)
#   -Password [pass]: Database password (default: 123456)
#   -Verbose: Show detailed output
#   -Help: Show help message
# =============================================================================

param(
    [string]$Action = "create",
    [string]$RoleName = "",
    [string]$Description = "",
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
$ScriptName = "Create Roles Script"
$Version = "2.0.0"

# Default roles configuration
$DefaultRoles = @{
    "USER" = "Regular user with basic permissions"
    "ADMIN" = "Administrator with full system access"
    "RECRUITER" = "Recruiter with hiring and management permissions"
    "MODERATOR" = "Moderator with content management permissions"
    "SUPER_ADMIN" = "Super administrator with all permissions"
    "GUEST" = "Guest user with limited permissions"
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
        "DB" { "Blue" }
        "CREATE" { "Magenta" }
        "DELETE" { "DarkRed" }
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

function Test-DatabaseConnection {
    param([string]$Host, [int]$Port, [string]$Database, [string]$Username, [string]$Password)
    
    Write-Step "Testing database connection..." "DB"
    
    try {
        $connectionString = "Host=$Host;Port=$Port;Database=$Database;Username=$Username;Password=$Password"
        
        # Test with psql command
        $env:PGPASSWORD = $Password
        $testQuery = "SELECT 1;"
        $result = psql -h $Host -p $Port -U $Username -d $Database -c $testQuery 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Step "Database connection successful" "SUCCESS"
            return $true
        } else {
            Write-Step "Database connection failed" "ERROR"
            return $false
        }
    } catch {
        Write-Step "Database connection error: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Execute-SqlQuery {
    param([string]$Query, [string]$Host, [int]$Port, [string]$Database, [string]$Username, [string]$Password)
    
    try {
        $env:PGPASSWORD = $Password
        
        if ($Verbose) {
            Write-Host "Executing SQL: $Query" -ForegroundColor Gray
        }
        
        $result = psql -h $Host -p $Port -U $Username -d $Database -c $Query 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            return $true, $result
        } else {
            return $false, $result
        }
    } catch {
        return $false, $_.Exception.Message
    }
}

function Create-RolesTable {
    param([string]$Host, [int]$Port, [string]$Database, [string]$Username, [string]$Password)
    
    Write-Step "Creating roles table..." "CREATE"
    
    $createTableQuery = @"
CREATE TABLE IF NOT EXISTS roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    permissions TEXT[],
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"@
    
    $success, $result = Execute-SqlQuery -Query $createTableQuery -Host $Host -Port $Port -Database $Database -Username $Username -Password $Password
    
    if ($success) {
        Write-Step "Roles table created successfully" "SUCCESS"
        return $true
    } else {
        Write-Step "Failed to create roles table: $result" "ERROR"
        return $false
    }
}

function Create-UsersTable {
    param([string]$Host, [int]$Port, [string]$Database, [string]$Username, [string]$Password)
    
    Write-Step "Creating users table..." "CREATE"
    
    $createTableQuery = @"
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
"@
    
    $success, $result = Execute-SqlQuery -Query $createTableQuery -Host $Host -Port $Port -Database $Database -Username $Username -Password $Password
    
    if ($success) {
        Write-Step "Users table created successfully" "SUCCESS"
        return $true
    } else {
        Write-Step "Failed to create users table: $result" "ERROR"
        return $false
    }
}

function Create-DefaultRoles {
    param([string]$Host, [int]$Port, [string]$Database, [string]$Username, [string]$Password)
    
    Write-Step "Creating default roles..." "CREATE"
    
    foreach ($role in $DefaultRoles.GetEnumerator()) {
        $roleName = $role.Key
        $roleDescription = $role.Value
        
        $insertQuery = @"
INSERT INTO roles (name, description, permissions) VALUES 
('$roleName', '$roleDescription', ARRAY['READ']) 
ON CONFLICT (name) DO UPDATE SET 
    description = EXCLUDED.description,
    updated_at = CURRENT_TIMESTAMP;
"@
        
        $success, $result = Execute-SqlQuery -Query $insertQuery -Host $Host -Port $Port -Database $Database -Username $Username -Password $Password
        
        if ($success) {
            Write-Step "Role '$roleName' created/updated" "SUCCESS"
        } else {
            Write-Step "Failed to create role '$roleName': $result" "ERROR"
        }
    }
}

function Create-CustomRole {
    param([string]$RoleName, [string]$Description, [string]$Host, [int]$Port, [string]$Database, [string]$Username, [string]$Password)
    
    Write-Step "Creating custom role: $RoleName" "CREATE"
    
    $insertQuery = @"
INSERT INTO roles (name, description, permissions) VALUES 
('$RoleName', '$Description', ARRAY['READ']) 
ON CONFLICT (name) DO UPDATE SET 
    description = EXCLUDED.description,
    updated_at = CURRENT_TIMESTAMP;
"@
    
    $success, $result = Execute-SqlQuery -Query $insertQuery -Host $Host -Port $Port -Database $Database -Username $Username -Password $Password
    
    if ($success) {
        Write-Step "Custom role '$RoleName' created successfully" "SUCCESS"
        return $true
    } else {
        Write-Step "Failed to create custom role '$RoleName': $result" "ERROR"
        return $false
    }
}

function List-Roles {
    param([string]$Host, [int]$Port, [string]$Database, [string]$Username, [string]$Password)
    
    Write-Step "Listing all roles..." "INFO"
    
    $selectQuery = "SELECT id, name, description, permissions, is_active, created_at FROM roles ORDER BY id;"
    
    $success, $result = Execute-SqlQuery -Query $selectQuery -Host $Host -Port $Port -Database $Database -Username $Username -Password $Password
    
    if ($success) {
        Write-Host "`nRoles in database:" -ForegroundColor Yellow
        Write-Host $result -ForegroundColor White
        return $true
    } else {
        Write-Step "Failed to list roles: $result" "ERROR"
        return $false
    }
}

function Delete-Role {
    param([string]$RoleName, [string]$Host, [int]$Port, [string]$Database, [string]$Username, [string]$Password)
    
    Write-Step "Deleting role: $RoleName" "DELETE"
    
    # Check if role is in use
    $checkQuery = "SELECT COUNT(*) FROM users WHERE role_id = (SELECT id FROM roles WHERE name = '$RoleName');"
    $success, $result = Execute-SqlQuery -Query $checkQuery -Host $Host -Port $Port -Database $Database -Username $Username -Password $Password
    
    if ($success -and $result -match "(\d+)") {
        $userCount = [int]$matches[1]
        if ($userCount -gt 0) {
            Write-Step "Cannot delete role '$RoleName' - it is used by $userCount user(s)" "ERROR"
            return $false
        }
    }
    
    $deleteQuery = "DELETE FROM roles WHERE name = '$RoleName';"
    $success, $result = Execute-SqlQuery -Query $deleteQuery -Host $Host -Port $Port -Database $Database -Username $Username -Password $Password
    
    if ($success) {
        Write-Step "Role '$RoleName' deleted successfully" "SUCCESS"
        return $true
    } else {
        Write-Step "Failed to delete role '$RoleName': $result" "ERROR"
        return $false
    }
}

function Reset-Roles {
    param([string]$Host, [int]$Port, [string]$Database, [string]$Username, [string]$Password)
    
    Write-Step "Resetting all roles..." "DELETE"
    
    # Delete all roles
    $deleteQuery = "DELETE FROM roles;"
    $success, $result = Execute-SqlQuery -Query $deleteQuery -Host $Host -Port $Port -Database $Database -Username $Username -Password $Password
    
    if ($success) {
        Write-Step "All roles deleted" "SUCCESS"
        
        # Recreate default roles
        Create-DefaultRoles -Host $Host -Port $Port -Database $Database -Username $Username -Password $Password
        
        return $true
    } else {
        Write-Step "Failed to reset roles: $result" "ERROR"
        return $false
    }
}

function Show-RoleSummary {
    param([string]$Action, [string]$RoleName = "")
    
    Write-Header "Role Management Summary" "Green"
    
    Write-Host "`nAction performed: $Action" -ForegroundColor Yellow
    if ($RoleName -ne "") {
        Write-Host "Role name: $RoleName" -ForegroundColor Yellow
    }
    Write-Host "Database: $Database" -ForegroundColor Yellow
    Write-Host "Host: $Host`:$Port" -ForegroundColor Yellow
    Write-Host "Username: $Username" -ForegroundColor Yellow
    
    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "  • Check roles: .\create-roles.ps1 -Action list" -ForegroundColor White
    Write-Host "  • Create custom role: .\create-roles.ps1 -Action create -RoleName [name] -Description [desc]" -ForegroundColor White
    Write-Host "  • Delete role: .\create-roles.ps1 -Action delete -RoleName [name]" -ForegroundColor White
    Write-Host "  • Reset all roles: .\create-roles.ps1 -Action reset" -ForegroundColor White
}

function Show-Help {
    Write-Header "Help - $ScriptName v$Version" "Blue"
    Write-Host "`nUsage: .\create-roles.ps1 [options]" -ForegroundColor Yellow
    Write-Host "`nOptions:" -ForegroundColor Yellow
    Write-Host "  -Action [action]     Action to perform (create, list, delete, reset)" -ForegroundColor White
    Write-Host "  -RoleName [name]     Role name for specific operations" -ForegroundColor White
    Write-Host "  -Description [desc]  Role description" -ForegroundColor White
    Write-Host "  -Database [db]       Database name (default: postgres)" -ForegroundColor White
    Write-Host "  -Host [host]         Database host (default: localhost)" -ForegroundColor White
    Write-Host "  -Port [port]         Database port (default: 5432)" -ForegroundColor White
    Write-Host "  -Username [user]     Database username (default: postgres)" -ForegroundColor White
    Write-Host "  -Password [pass]     Database password (default: 123456)" -ForegroundColor White
    Write-Host "  -Verbose             Show detailed output" -ForegroundColor White
    Write-Host "  -Help                Show this help message" -ForegroundColor White
    
    Write-Host "`nActions:" -ForegroundColor Yellow
    Write-Host "  create               Create default roles and tables" -ForegroundColor White
    Write-Host "  list                 List all roles" -ForegroundColor White
    Write-Host "  delete               Delete specific role" -ForegroundColor White
    Write-Host "  reset                Reset all roles to default" -ForegroundColor White
    
    Write-Host "`nDefault Roles:" -ForegroundColor Yellow
    foreach ($role in $DefaultRoles.GetEnumerator()) {
        Write-Host "  • $($role.Key): $($role.Value)" -ForegroundColor Cyan
    }
    
    Write-Host "`nExamples:" -ForegroundColor Yellow
    Write-Host "  .\create-roles.ps1 -Action create                    # Create default roles" -ForegroundColor White
    Write-Host "  .\create-roles.ps1 -Action list                      # List all roles" -ForegroundColor White
    Write-Host "  .\create-roles.ps1 -Action create -RoleName MANAGER -Description 'Manager role'" -ForegroundColor White
    Write-Host "  .\create-roles.ps1 -Action delete -RoleName MANAGER  # Delete specific role" -ForegroundColor White
    Write-Host "  .\create-roles.ps1 -Action reset                     # Reset all roles" -ForegroundColor White
    
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

# Test database connection
if (-not (Test-DatabaseConnection -Host $Host -Port $Port -Database $Database -Username $Username -Password $Password)) {
    Write-Step "Cannot connect to database" "ERROR"
    Write-Host "Please check your database connection parameters" -ForegroundColor Yellow
    exit 1
}

Write-Step "Prerequisites validated successfully" "SUCCESS"

# Execute action
$actionSuccess = $false

switch ($Action.ToLower()) {
    "create" {
        if ($RoleName -ne "" -and $Description -ne "") {
            # Create custom role
            $actionSuccess = Create-CustomRole -RoleName $RoleName -Description $Description -Host $Host -Port $Port -Database $Database -Username $Username -Password $Password
        } else {
            # Create default roles and tables
            if ((Create-RolesTable -Host $Host -Port $Port -Database $Database -Username $Username -Password $Password) -and
                (Create-UsersTable -Host $Host -Port $Port -Database $Database -Username $Username -Password $Password) -and
                (Create-DefaultRoles -Host $Host -Port $Port -Database $Database -Username $Username -Password $Password)) {
                $actionSuccess = $true
            }
        }
    }
    "list" {
        $actionSuccess = List-Roles -Host $Host -Port $Port -Database $Database -Username $Username -Password $Password
    }
    "delete" {
        if ($RoleName -ne "") {
            $actionSuccess = Delete-Role -RoleName $RoleName -Host $Host -Port $Port -Database $Database -Username $Username -Password $Password
        } else {
            Write-Step "Role name is required for delete action" "ERROR"
        }
    }
    "reset" {
        $actionSuccess = Reset-Roles -Host $Host -Port $Port -Database $Database -Username $Username -Password $Password
    }
    default {
        Write-Step "Unknown action: $Action" "ERROR"
        Write-Host "Available actions: create, list, delete, reset" -ForegroundColor Yellow
    }
}

# Calculate execution time
$script:ExecutionTime = (Get-Date) - $script:StartTime
$script:ExecutionTime = "{0:mm\:ss}" -f $script:ExecutionTime

# Show results
if ($actionSuccess) {
    Show-RoleSummary -Action $Action -RoleName $RoleName
    Write-Header "Role Management Completed Successfully!" "Green"
    exit 0
} else {
    Write-Header "Role Management Failed!" "Red"
    Write-Host "`nPlease check the error messages above and try again." -ForegroundColor Yellow
    Write-Host "For help, run: .\create-roles.ps1 -Help" -ForegroundColor Cyan
    exit 1
}

