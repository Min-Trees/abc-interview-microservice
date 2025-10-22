param(
    [switch]$Delete,
    [switch]$ListOnly
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$archive = Join-Path $root ("archive\cleanup-" + $timestamp)

# Patterns to KEEP (never touch)
$keep = @(
  'README.md',
  'docker-compose.yml',
  'config-repo',
  'config-service',
  'discovery-service',
  'gateway-service',
  'auth-service',
  'user-service',
  'question-service',
  'exam-service',
  'career-service',
  'news-service',
  'nlp-service',
  'frontend-sdk',
  'database-import',
  'postman-collections',
  'pgdata',
  'swagger-ui.html' # keep swagger html entry if used
)

# Candidate files/folders to clean up (docs/reports/scripts)
$docFiles = @(
  'ALL-APIS-COMPLETE-LIST.md',
  'API_DOCUMENTATION.md',
  'API-COMPLETE-REFERENCE.md',
  'API-SPECIFICATION.md',
  'API-TESTING-COMPLETE.md',
  'API-TESTING-SUMMARY.md',
  'ARCHITECTURE-CLARIFICATION.md',
  'COMPLETE-API-DOCUMENTATION.md',
  'DTO-REDESIGN-SUMMARY.md',
  'DTO-STANDARDIZATION-REPORT.md',
  'DTO-VALIDATION-COMPLETE.md',
  'ERROR-CODES.md',
  'EUREKA-REGISTRATION-FIX.md',
  'EXCEPTION-HANDLING-COMPLETE.md',
  'FAILED-ENDPOINTS-ANALYSIS.md',
  'FINAL-STATUS.md',
  'GATEWAY-CONFIGURATION-COMPLETE.md',
  'GLOBAL-EXCEPTION-HANDLING.md',
  'HUONG-DAN-IMPORT-DU-LIEU.md',
  'OPEN-SWAGGER.ps1',
  'POSTMAN_TROUBLESHOOTING.md',
  'POSTMAN-COLLECTION-V2-GUIDE.md',
  'POSTMAN-COLLECTIONS-UPDATED.md',
  'POSTMAN-GUIDE.md',
  'POSTMAN-IMPORT-INSTRUCTIONS.md',
  'POSTMAN-QUICK-START.md',
  'QUESTION-SERVICE-SECURITY-FIX.md',
  'QUICK_START_FRONTEND.md',
  'QUICK-DEPLOY.md',
  'REBUILD-AND-TEST.md',
  'RESPONSE-DTO-ENDPOINT-UPDATES.md',
  'SWAGGER-CONFIG-COMPLETE.md',
  'SWAGGER-TESTING-GUIDE.md',
  'SYSTEM-CHECK-COMPLETE.md',
  'SYSTEM-COMPLETE-SUMMARY.md',
  'SYSTEM-COMPLETION-REPORT.md',
  'SYSTEM-STATUS-REPORT.md',
  'SYSTEM-VALIDATION.md',
  'WHAT-CHANGED.md'
)

$scriptFiles = @(
  'health-check.ps1',
  'open-swagger.ps1',
  'rebuild-services.ps1',
  'rebuild-updated-services.ps1',
  'run-init-with-data.ps1',
  'test-all-endpoints-complete.ps1',
  'test-all-endpoints.ps1',
  'test-api-connection.ps1',
  'test-comprehensive-fixed.ps1',
  'test-comprehensive.ps1',
  'test-endpoints-simple.ps1',
  'test-failed-endpoints.ps1',
  'test-working.ps1'
)

# Build target list that actually exists
$targets = @()
foreach ($f in ($docFiles + $scriptFiles)) {
  $p = Join-Path $root $f
  if (Test-Path $p) { $targets += $p }
}

if ($targets.Count -eq 0) {
  Write-Host "No matching files to clean." -ForegroundColor Yellow
  exit 0
}

if ($ListOnly) {
  Write-Host "Files that would be cleaned (ListOnly):" -ForegroundColor Cyan
  $targets | ForEach-Object { Write-Host " - $_" }
  exit 0
}

if (-not $Delete) {
  # Move to archive by default (safe)
  New-Item -ItemType Directory -Force -Path $archive | Out-Null
  foreach ($t in $targets) {
    Write-Host "Moving: $t" -ForegroundColor Yellow
    Move-Item -Force -Path $t -Destination $archive
  }
  Write-Host "Moved $($targets.Count) items to $archive" -ForegroundColor Green
} else {
  # Hard delete
  foreach ($t in $targets) {
    Write-Host "Deleting: $t" -ForegroundColor Red
    Remove-Item -Force -Recurse -Path $t
  }
  Write-Host "Deleted $($targets.Count) items" -ForegroundColor Green
}
