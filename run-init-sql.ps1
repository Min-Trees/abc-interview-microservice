# =============================================
# Script tự động chạy init.sql
# =============================================

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "CHẠY INIT.SQL - INTERVIEW MICROSERVICE ABC" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Kiểm tra container đang chạy
Write-Host "Kiểm tra PostgreSQL container..." -ForegroundColor Yellow
$containerRunning = docker ps --filter "name=interview-postgres" --format "{{.Names}}"

if (-not $containerRunning) {
    Write-Host "✗ PostgreSQL container chưa chạy!" -ForegroundColor Red
    Write-Host "Vui lòng chạy: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ PostgreSQL container đang chạy" -ForegroundColor Green
Write-Host ""

# Tùy chọn
Write-Host "Chọn phương thức:" -ForegroundColor Cyan
Write-Host "1. Xóa volume và khởi tạo lại (Mất toàn bộ data)" -ForegroundColor Yellow
Write-Host "2. Chạy init.sql vào container đang chạy (Giữ nguyên data)" -ForegroundColor Green
Write-Host ""
$choice = Read-Host "Nhập lựa chọn (1 hoặc 2)"

if ($choice -eq "1") {
    Write-Host ""
    Write-Host "⚠️  CẢNH BÁO: Thao tác này sẽ XÓA TOÀN BỘ DATA trong PostgreSQL!" -ForegroundColor Red
    $confirm = Read-Host "Bạn có chắc chắn? (yes/no)"
    
    if ($confirm -eq "yes") {
        Write-Host ""
        Write-Host "Đang dừng containers..." -ForegroundColor Yellow
        docker-compose down
        
        Write-Host "Đang xóa PostgreSQL volume..." -ForegroundColor Yellow
        docker volume ls | Select-String "postgres_data" | ForEach-Object {
            $volumeName = $_.ToString().Split()[-1]
            Write-Host "Xóa volume: $volumeName" -ForegroundColor Yellow
            docker volume rm $volumeName 2>$null
        }
        
        Write-Host "Đang khởi động lại..." -ForegroundColor Yellow
        docker-compose up -d postgres
        
        Write-Host ""
        Write-Host "Chờ PostgreSQL khởi động..." -ForegroundColor Yellow
        Start-Sleep -Seconds 15
        
        Write-Host "Đang chạy init.sql..." -ForegroundColor Yellow
        docker exec -i interview-postgres psql -U postgres < init.sql
        
        Write-Host ""
        Write-Host "Khởi động các services khác..." -ForegroundColor Yellow
        docker-compose up -d
        
        Write-Host "✓ Hoàn tất! init.sql đã được chạy tự động" -ForegroundColor Green
    } else {
        Write-Host "Đã hủy thao tác" -ForegroundColor Yellow
        exit 0
    }
} elseif ($choice -eq "2") {
    Write-Host ""
    Write-Host "Đang copy init.sql vào container..." -ForegroundColor Yellow
    docker cp init.sql interview-postgres:/init.sql
    
    Write-Host "Đang chạy init.sql..." -ForegroundColor Yellow
    docker exec -i interview-postgres psql -U postgres -f /init.sql
    
    Write-Host "✓ Hoàn tất!" -ForegroundColor Green
} else {
    Write-Host "Lựa chọn không hợp lệ" -ForegroundColor Red
    exit 1
}

# Kiểm tra kết quả
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "KIỂM TRA KẾT QUẢ" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Danh sách databases:" -ForegroundColor Yellow
docker exec -i interview-postgres psql -U postgres -c "\l"

Write-Host ""
Write-Host "Tables trong userdb:" -ForegroundColor Yellow
docker exec -i interview-postgres psql -U postgres -d userdb -c "\dt"

Write-Host ""
Write-Host "Roles trong userdb:" -ForegroundColor Yellow
docker exec -i interview-postgres psql -U postgres -d userdb -c "SELECT * FROM roles;"

Write-Host ""
Write-Host "Topics trong questiondb:" -ForegroundColor Yellow
docker exec -i interview-postgres psql -U postgres -d questiondb -c "SELECT COUNT(*) as total_topics FROM topics;"

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "🎉 HOÀN TẤT!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Databases đã được tạo thành công!" -ForegroundColor Green
Write-Host ""
Write-Host "Bước tiếp theo - Import sample data:" -ForegroundColor Cyan
Write-Host "  cd database-import" -ForegroundColor White
Write-Host "  .\quick-import-data.ps1" -ForegroundColor White
Write-Host ""
Write-Host "Sau đó restart các microservices:" -ForegroundColor Cyan
Write-Host "  docker-compose restart" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

