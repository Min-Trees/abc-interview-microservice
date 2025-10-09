# =============================================
# Script tự động chạy init-with-data.sql
# Tạo databases và insert FULL dữ liệu mẫu
# =============================================

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "CHẠY INIT-WITH-DATA.SQL" -ForegroundColor Cyan
Write-Host "Tạo databases + Insert 160+ records data mẫu" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Kiểm tra file tồn tại
if (-not (Test-Path "init-with-data.sql")) {
    Write-Host "✗ Không tìm thấy file init-with-data.sql!" -ForegroundColor Red
    Write-Host "Vui lòng đảm bảo file tồn tại trong thư mục hiện tại" -ForegroundColor Yellow
    exit 1
}

Write-Host "Chọn phương thức:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Xóa volume và khởi tạo lại (KHUYẾN NGHỊ)" -ForegroundColor Green
Write-Host "   → Dữ liệu đầy đủ nhất, clean start" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Chạy vào container đang chạy" -ForegroundColor Yellow
Write-Host "   → Nhanh hơn, giữ một số config" -ForegroundColor Gray
Write-Host ""
$choice = Read-Host "Nhập lựa chọn (1 hoặc 2)"

if ($choice -eq "1") {
    Write-Host ""
    Write-Host "⚠️  CẢNH BÁO: Thao tác này sẽ XÓA TOÀN BỘ DATA PostgreSQL hiện tại!" -ForegroundColor Red
    $confirm = Read-Host "Bạn có chắc chắn muốn tiếp tục? (yes/no)"
    
    if ($confirm -ne "yes") {
        Write-Host "Đã hủy thao tác" -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host ""
    Write-Host "📦 Đang dừng containers..." -ForegroundColor Yellow
    docker-compose down
    
    Write-Host "🗑️  Đang xóa PostgreSQL volume..." -ForegroundColor Yellow
    docker volume ls | Select-String "postgres_data" | ForEach-Object {
        $volumeName = $_.ToString().Split()[-1]
        Write-Host "  → Xóa volume: $volumeName" -ForegroundColor Gray
        docker volume rm $volumeName 2>$null
    }
    
    Write-Host "📝 Đang cập nhật docker-compose.yml..." -ForegroundColor Yellow
    $dockerComposeContent = Get-Content "docker-compose.yml" -Raw
    if ($dockerComposeContent -match "./init.sql:/docker-entrypoint-initdb.d/init.sql") {
        $dockerComposeContent = $dockerComposeContent -replace "./init.sql:/docker-entrypoint-initdb.d/init.sql", "./init-with-data.sql:/docker-entrypoint-initdb.d/init.sql"
        Set-Content "docker-compose.yml" $dockerComposeContent
        Write-Host "  → Đã cập nhật mount point" -ForegroundColor Green
    } else {
        Write-Host "  → Đã sử dụng init-with-data.sql" -ForegroundColor Green
    }
    
    Write-Host "🐘 Đang khởi động PostgreSQL..." -ForegroundColor Yellow
    docker-compose up -d postgres
    
    Write-Host ""
    Write-Host "⏳ Đang chờ PostgreSQL khởi động và chạy init script..." -ForegroundColor Yellow
    Write-Host "   Quá trình này có thể mất 20-30 giây..." -ForegroundColor Gray
    Write-Host ""
    
    # Đợi và hiển thị progress
    for ($i = 1; $i -le 25; $i++) {
        Write-Progress -Activity "Khởi động PostgreSQL" -Status "Đang xử lý... ($i/25)" -PercentComplete ($i * 4)
        Start-Sleep -Seconds 1
    }
    Write-Progress -Activity "Khởi động PostgreSQL" -Completed
    
    Write-Host ""
    Write-Host "🚀 Đang khởi động các services khác..." -ForegroundColor Yellow
    docker-compose up -d
    
    Write-Host ""
    Write-Host "✓ Hoàn tất!" -ForegroundColor Green
    
} elseif ($choice -eq "2") {
    Write-Host ""
    Write-Host "🔍 Kiểm tra PostgreSQL container..." -ForegroundColor Yellow
    $containerRunning = docker ps --filter "name=interview-postgres" --format "{{.Names}}"
    
    if (-not $containerRunning) {
        Write-Host "✗ PostgreSQL container chưa chạy!" -ForegroundColor Red
        Write-Host "Vui lòng chạy: docker-compose up -d postgres" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "  → Container đang chạy: $containerRunning" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "📤 Copy file vào container..." -ForegroundColor Yellow
    docker cp init-with-data.sql interview-postgres:/init-with-data.sql
    Write-Host "  → Đã copy thành công" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "⚙️  Đang chạy init-with-data.sql..." -ForegroundColor Yellow
    Write-Host "   Quá trình này có thể mất 10-15 giây..." -ForegroundColor Gray
    docker exec -i interview-postgres psql -U postgres -f /init-with-data.sql
    
    Write-Host ""
    Write-Host "🔄 Đang restart microservices..." -ForegroundColor Yellow
    docker-compose restart auth-service user-service question-service exam-service career-service news-service
    
    Write-Host ""
    Write-Host "✓ Hoàn tất!" -ForegroundColor Green
    
} else {
    Write-Host "❌ Lựa chọn không hợp lệ" -ForegroundColor Red
    exit 1
}

# Kiểm tra kết quả
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "📊 KIỂM TRA KẾT QUẢ" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1️⃣  Danh sách databases:" -ForegroundColor Yellow
docker exec -i interview-postgres psql -U postgres -c "\l" | Select-String "authdb|userdb|careerdb|questiondb|examdb|newsdb|Name"

Write-Host ""
Write-Host "2️⃣  Thống kê dữ liệu:" -ForegroundColor Yellow
Write-Host ""

Write-Host "   👥 Users:" -ForegroundColor Cyan
docker exec -i interview-postgres psql -U postgres -d userdb -c "SELECT COUNT(*) as total FROM users;" | Select-String "total|------|[0-9]"

Write-Host ""
Write-Host "   📚 Topics:" -ForegroundColor Cyan
docker exec -i interview-postgres psql -U postgres -d questiondb -c "SELECT COUNT(*) as total FROM topics;" | Select-String "total|------|[0-9]"

Write-Host ""
Write-Host "   ❓ Questions:" -ForegroundColor Cyan
docker exec -i interview-postgres psql -U postgres -d questiondb -c "SELECT COUNT(*) as total FROM questions;" | Select-String "total|------|[0-9]"

Write-Host ""
Write-Host "   💬 Answers:" -ForegroundColor Cyan
docker exec -i interview-postgres psql -U postgres -d questiondb -c "SELECT COUNT(*) as total FROM answers;" | Select-String "total|------|[0-9]"

Write-Host ""
Write-Host "   📝 Exams:" -ForegroundColor Cyan
docker exec -i interview-postgres psql -U postgres -d examdb -c "SELECT COUNT(*) as total FROM exams;" | Select-String "total|------|[0-9]"

Write-Host ""
Write-Host "   🏆 Results:" -ForegroundColor Cyan
docker exec -i interview-postgres psql -U postgres -d examdb -c "SELECT COUNT(*) as total FROM results;" | Select-String "total|------|[0-9]"

Write-Host ""
Write-Host "   📰 News:" -ForegroundColor Cyan
docker exec -i interview-postgres psql -U postgres -d newsdb -c "SELECT COUNT(*) as total FROM news WHERE news_type='NEWS';" | Select-String "total|------|[0-9]"

Write-Host ""
Write-Host "   💼 Recruitments:" -ForegroundColor Cyan
docker exec -i interview-postgres psql -U postgres -d newsdb -c "SELECT COUNT(*) as total FROM news WHERE news_type='RECRUITMENT';" | Select-String "total|------|[0-9]"

Write-Host ""
Write-Host "3️⃣  Sample Users:" -ForegroundColor Yellow
docker exec -i interview-postgres psql -U postgres -d userdb -c "SELECT id, email, full_name, elo_score, elo_rank FROM users ORDER BY id LIMIT 5;"

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "🎉 HỆ THỐNG ĐÃ SẴN SÀNG SỬ DỤNG!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 TÀI KHOẢN TEST:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   🔑 Admin:" -ForegroundColor Yellow
Write-Host "      Email: admin@example.com" -ForegroundColor White
Write-Host "      Password: password123" -ForegroundColor White
Write-Host ""
Write-Host "   🔑 Recruiter:" -ForegroundColor Yellow
Write-Host "      Email: recruiter@example.com" -ForegroundColor White
Write-Host "      Password: password123" -ForegroundColor White
Write-Host ""
Write-Host "   🔑 User (BRONZE rank):" -ForegroundColor Yellow
Write-Host "      Email: user@example.com" -ForegroundColor White
Write-Host "      Password: password123" -ForegroundColor White
Write-Host "      ELO Score: 1200" -ForegroundColor Gray
Write-Host ""
Write-Host "   🔑 Developer (SILVER rank):" -ForegroundColor Yellow
Write-Host "      Email: developer@example.com" -ForegroundColor White
Write-Host "      Password: password123" -ForegroundColor White
Write-Host "      ELO Score: 1500" -ForegroundColor Gray
Write-Host ""
Write-Host "   🔑 Expert (GOLD rank):" -ForegroundColor Yellow
Write-Host "      Email: expert@example.com" -ForegroundColor White
Write-Host "      Password: password123" -ForegroundColor White
Write-Host "      ELO Score: 2100" -ForegroundColor Gray
Write-Host ""

Write-Host "🌐 SERVICE URLs:" -ForegroundColor Cyan
Write-Host "   API Gateway: http://localhost:8080" -ForegroundColor White
Write-Host "   Eureka Dashboard: http://localhost:8761" -ForegroundColor White
Write-Host "   Config Server: http://localhost:8888" -ForegroundColor White
Write-Host ""

Write-Host "📚 HƯỚNG DẪN TIẾP THEO:" -ForegroundColor Cyan
Write-Host "   1. Import Postman collection từ: postman-collections/" -ForegroundColor White
Write-Host "   2. Đọc API documentation: API-SPECIFICATION.md" -ForegroundColor White
Write-Host "   3. Xem hướng dẫn test: postman-collections/HUONG-DAN-IMPORT.md" -ForegroundColor White
Write-Host ""

Write-Host "🎯 DỮ LIỆU MẪU BAO GỒM:" -ForegroundColor Cyan
Write-Host "   ✅ 8 Users với ELO ranks khác nhau" -ForegroundColor Green
Write-Host "   ✅ 15 Questions đã approved" -ForegroundColor Green
Write-Host "   ✅ 25 Topics phân bổ theo 6 fields" -ForegroundColor Green
Write-Host "   ✅ 8 Exams (Technical & Behavioral)" -ForegroundColor Green
Write-Host "   ✅ 10 Exam Results với feedback" -ForegroundColor Green
Write-Host "   ✅ 18 News & Recruitment posts" -ForegroundColor Green
Write-Host "   ✅ 20 Career Preferences" -ForegroundColor Green
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
