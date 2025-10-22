# Rebuild all microservices (skip tests by default)
# Usage:
#   ./rebuild-services.ps1                  # Build all (skip tests)
#   ./rebuild-services.ps1 -IncludeInfra    # Include discovery, config, gateway first
#   ./rebuild-services.ps1 -NoSkipTests     # Run tests
#
param(
    [switch]$IncludeInfra = $true,
    [switch]$NoSkipTests
)

$ErrorActionPreference = 'Stop'

function Build-Service {
    param(
        [Parameter(Mandatory=$true)][string]$Path
    )

    if (-not (Test-Path $Path)) {
        Write-Host "   ⚠️  Skip: $Path not found" -ForegroundColor Yellow
        return $false
    }

    Push-Location $Path
    try {
        $skipArg = if ($NoSkipTests) { '' } else { '-DskipTests' }
        Write-Host "   ⏳ mvnw clean package $skipArg" -ForegroundColor DarkGray
        $out = & .\mvnw.cmd clean package $skipArg 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ Built: $Path" -ForegroundColor Green
            return $true
        } else {
            Write-Host "   ❌ Failed: $Path" -ForegroundColor Red
            Write-Host ($out | Out-String) -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "   ❌ Exception building $Path: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    } finally {
        Pop-Location
    }
}

Write-Host "🔨 Rebuilding microservices..." -ForegroundColor Cyan
Write-Host "Include Infra (discovery/config/gateway): $IncludeInfra" -ForegroundColor Cyan
Write-Host "Skip tests: $(-not $NoSkipTests)" -ForegroundColor Cyan
Write-Host "" 

$infra = @(
    'discovery-service',
    'config-service',
    'gateway-service'
)

$services = @(
    'auth-service',
    'user-service',
    'career-service',
    'question-service',
    'exam-service',
    'news-service'
)

$total = 0; $ok = 0; $fail = 0

if ($IncludeInfra) {
    Write-Host "📡 Building infra services..." -ForegroundColor Yellow
    foreach ($p in $infra) { $total++; if (Build-Service -Path $p) { $ok++ } else { $fail++ } }
    Write-Host "" 
}

Write-Host "🧩 Building business services..." -ForegroundColor Yellow
foreach ($p in $services) { $total++; if (Build-Service -Path $p) { $ok++ } else { $fail++ } }

Write-Host "" 
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "BUILD SUMMARY" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ("Total:   {0}" -f $total) -ForegroundColor White
Write-Host ("Success: {0}" -f $ok) -ForegroundColor Green
Write-Host ("Failed:  {0}" -f $fail) -ForegroundColor Red
Write-Host "" 

if ($fail -eq 0) {
    Write-Host "🎉 All builds complete!" -ForegroundColor Green
    Write-Host "Tip: docker-compose up -d --build" -ForegroundColor DarkGray
} else {
    Write-Host "⚠️  Some builds failed. See logs above. Re-run individually:" -ForegroundColor Yellow
    Write-Host "    cd <service>; .\\mvnw.cmd clean package -DskipTests" -ForegroundColor DarkGray
}
