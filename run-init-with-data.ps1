# =============================================
# Script tu dong chay init-with-data.sql
# Tao databases va insert FULL du lieu mau
# =============================================

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "CHAY INIT-WITH-DATA.SQL" -ForegroundColor Cyan
Write-Host "Tao databases + Insert 160+ records data mau" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Kiem tra file ton tai
if (-not (Test-Path "init-with-data.sql")) {
    Write-Host "[X] Khong tim thay file init-with-data.sql!" -ForegroundColor Red
    Write-Host "Vui long dam bao file ton tai trong thu muc hien tai" -ForegroundColor Yellow
    exit 1
}

Write-Host "Chon phuong thuc:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Xoa volume va khoi tao lai (KHUYEN NGHI)" -ForegroundColor Green
Write-Host "   -> Du lieu day du nhat, clean start" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Chay vao container dang chay" -ForegroundColor Yellow
Write-Host "   -> Nhanh hon, giu mot so config" -ForegroundColor Gray
Write-Host ""
$choice = Read-Host "Nhap lua chon (1 hoac 2)"

if ($choice -eq "1") {
    Write-Host ""
    Write-Host "[!] CANH BAO: Thao tac nay se XOA TOAN BO DATA PostgreSQL hien tai!" -ForegroundColor Red
    $confirm = Read-Host "Ban co chac chan muon tiep tuc? (yes/no)"
    
    if ($confirm -ne "yes") {
        Write-Host "Da huy thao tac" -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host ""
    Write-Host "[*] Dang dung containers..." -ForegroundColor Yellow
    docker-compose down
    
    Write-Host "[*] Dang xoa PostgreSQL volume..." -ForegroundColor Yellow
    docker volume ls | Select-String "postgres_data" | ForEach-Object {
        $volumeName = $_.ToString().Split()[-1]
        Write-Host "  -> Xoa volume: $volumeName" -ForegroundColor Gray
        docker volume rm $volumeName 2>$null
    }
    
    Write-Host "[*] Dang cap nhat docker-compose.yml..." -ForegroundColor Yellow
    $dockerComposeContent = Get-Content "docker-compose.yml" -Raw
    if ($dockerComposeContent -match "./init.sql:/docker-entrypoint-initdb.d/init.sql") {
        $dockerComposeContent = $dockerComposeContent -replace "./init.sql:/docker-entrypoint-initdb.d/init.sql", "./init-with-data.sql:/docker-entrypoint-initdb.d/init.sql"
        Set-Content "docker-compose.yml" $dockerComposeContent
        Write-Host "  -> Da cap nhat mount point" -ForegroundColor Green
    } else {
        Write-Host "  -> Da su dung init-with-data.sql" -ForegroundColor Green
    }
    
    Write-Host "[*] Dang khoi dong PostgreSQL..." -ForegroundColor Yellow
    docker-compose up -d postgres
    
    Write-Host ""
    Write-Host "[*] Dang cho PostgreSQL khoi dong va chay init script..." -ForegroundColor Yellow
    Write-Host "   Qua trinh nay co the mat 20-30 giay..." -ForegroundColor Gray
    Write-Host ""
    
    # Doi va hien thi progress
    for ($i = 1; $i -le 25; $i++) {
        Write-Progress -Activity "Khoi dong PostgreSQL" -Status "Dang xu ly... ($i/25)" -PercentComplete ($i * 4)
        Start-Sleep -Seconds 1
    }
    Write-Progress -Activity "Khoi dong PostgreSQL" -Completed
    
    Write-Host ""
    Write-Host "[*] Dang khoi dong cac services khac..." -ForegroundColor Yellow
    docker-compose up -d
    
    Write-Host ""
    Write-Host "[OK] Hoan tat!" -ForegroundColor Green
    
} elseif ($choice -eq "2") {
    Write-Host ""
    Write-Host "[*] Kiem tra PostgreSQL container..." -ForegroundColor Yellow
    $containerRunning = docker ps --filter "name=interview-postgres" --format "{{.Names}}"
    
    if (-not $containerRunning) {
        Write-Host "[X] PostgreSQL container chua chay!" -ForegroundColor Red
        Write-Host "Vui long chay: docker-compose up -d postgres" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "  -> Container dang chay: $containerRunning" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "[*] Copy file vao container..." -ForegroundColor Yellow
    docker cp init-with-data.sql interview-postgres:/init-with-data.sql
    Write-Host "  -> Da copy thanh cong" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "[*] Dang chay init-with-data.sql..." -ForegroundColor Yellow
    Write-Host "   Qua trinh nay co the mat 10-15 giay..." -ForegroundColor Gray
    docker exec -i interview-postgres psql -U postgres -f /init-with-data.sql
    
    Write-Host ""
    Write-Host "[*] Dang restart microservices..." -ForegroundColor Yellow
    docker-compose restart auth-service user-service question-service exam-service career-service news-service
    
    Write-Host ""
    Write-Host "[OK] Hoan tat!" -ForegroundColor Green
    
} else {
    Write-Host "[X] Lua chon khong hop le" -ForegroundColor Red
    exit 1
}

# Kiem tra ket qua
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "KIEM TRA KET QUA" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1] Danh sach databases:" -ForegroundColor Yellow
docker exec -i interview-postgres psql -U postgres -c "\l" | Select-String "authdb|userdb|careerdb|questiondb|examdb|newsdb|Name"

Write-Host ""
Write-Host "[2] Thong ke du lieu:" -ForegroundColor Yellow
Write-Host ""

Write-Host "   [+] Users:" -ForegroundColor Cyan
docker exec -i interview-postgres psql -U postgres -d userdb -c "SELECT COUNT(*) as total FROM users;" | Select-String "total|------|[0-9]"

Write-Host ""
Write-Host "   [+] Topics:" -ForegroundColor Cyan
docker exec -i interview-postgres psql -U postgres -d questiondb -c "SELECT COUNT(*) as total FROM topics;" | Select-String "total|------|[0-9]"

Write-Host ""
Write-Host "   [+] Questions:" -ForegroundColor Cyan
docker exec -i interview-postgres psql -U postgres -d questiondb -c "SELECT COUNT(*) as total FROM questions;" | Select-String "total|------|[0-9]"

Write-Host ""
Write-Host "   [+] Answers:" -ForegroundColor Cyan
docker exec -i interview-postgres psql -U postgres -d questiondb -c "SELECT COUNT(*) as total FROM answers;" | Select-String "total|------|[0-9]"

Write-Host ""
Write-Host "   [+] Exams:" -ForegroundColor Cyan
docker exec -i interview-postgres psql -U postgres -d examdb -c "SELECT COUNT(*) as total FROM exams;" | Select-String "total|------|[0-9]"

Write-Host ""
Write-Host "   [+] Results:" -ForegroundColor Cyan
docker exec -i interview-postgres psql -U postgres -d examdb -c "SELECT COUNT(*) as total FROM results;" | Select-String "total|------|[0-9]"

Write-Host ""
Write-Host "   [+] News:" -ForegroundColor Cyan
docker exec -i interview-postgres psql -U postgres -d newsdb -c "SELECT COUNT(*) as total FROM news WHERE news_type='NEWS';" | Select-String "total|------|[0-9]"

Write-Host ""
Write-Host "   [+] Recruitments:" -ForegroundColor Cyan
docker exec -i interview-postgres psql -U postgres -d newsdb -c "SELECT COUNT(*) as total FROM news WHERE news_type='RECRUITMENT';" | Select-String "total|------|[0-9]"

Write-Host ""
Write-Host "[3] Sample Users:" -ForegroundColor Yellow
docker exec -i interview-postgres psql -U postgres -d userdb -c "SELECT id, email, full_name, elo_score, elo_rank FROM users ORDER BY id LIMIT 5;"

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "HE THONG DA SAN SANG SU DUNG!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

Write-Host "TAI KHOAN TEST:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   [Admin]" -ForegroundColor Yellow
Write-Host "      Email: admin@example.com" -ForegroundColor White
Write-Host "      Password: password123" -ForegroundColor White
Write-Host ""
Write-Host "   [Recruiter]" -ForegroundColor Yellow
Write-Host "      Email: recruiter@example.com" -ForegroundColor White
Write-Host "      Password: password123" -ForegroundColor White
Write-Host ""
Write-Host "   [User - BRONZE rank]" -ForegroundColor Yellow
Write-Host "      Email: user@example.com" -ForegroundColor White
Write-Host "      Password: password123" -ForegroundColor White
Write-Host "      ELO Score: 1200" -ForegroundColor Gray
Write-Host ""
Write-Host "   [Developer - SILVER rank]" -ForegroundColor Yellow
Write-Host "      Email: developer@example.com" -ForegroundColor White
Write-Host "      Password: password123" -ForegroundColor White
Write-Host "      ELO Score: 1500" -ForegroundColor Gray
Write-Host ""
Write-Host "   [Expert - GOLD rank]" -ForegroundColor Yellow
Write-Host "      Email: expert@example.com" -ForegroundColor White
Write-Host "      Password: password123" -ForegroundColor White
Write-Host "      ELO Score: 2100" -ForegroundColor Gray
Write-Host ""

Write-Host "SERVICE URLs:" -ForegroundColor Cyan
Write-Host "   API Gateway: http://localhost:8080" -ForegroundColor White
Write-Host "   Eureka Dashboard: http://localhost:8761" -ForegroundColor White
Write-Host "   Config Server: http://localhost:8888" -ForegroundColor White
Write-Host ""

Write-Host "HUONG DAN TIEP THEO:" -ForegroundColor Cyan
Write-Host "   1. Import Postman collection tu: postman-collections/" -ForegroundColor White
Write-Host "   2. Doc API documentation: API-SPECIFICATION.md" -ForegroundColor White
Write-Host "   3. Xem huong dan test: postman-collections/HUONG-DAN-IMPORT.md" -ForegroundColor White
Write-Host ""

Write-Host "DU LIEU MAU BAO GOM:" -ForegroundColor Cyan
Write-Host "   [OK] 8 Users voi ELO ranks khac nhau" -ForegroundColor Green
Write-Host "   [OK] 15 Questions da approved" -ForegroundColor Green
Write-Host "   [OK] 25 Topics phan bo theo 6 fields" -ForegroundColor Green
Write-Host "   [OK] 8 Exams (Technical & Behavioral)" -ForegroundColor Green
Write-Host "   [OK] 10 Exam Results voi feedback" -ForegroundColor Green
Write-Host "   [OK] 18 News & Recruitment posts" -ForegroundColor Green
Write-Host "   [OK] 20 Career Preferences" -ForegroundColor Green
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
