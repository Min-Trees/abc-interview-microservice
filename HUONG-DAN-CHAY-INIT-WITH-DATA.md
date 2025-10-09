# 🚀 HƯỚNG DẪN CHẠY INIT-WITH-DATA.SQL

## 📋 Tổng Quan

File **`init-with-data.sql`** là phiên bản hoàn chỉnh của `init.sql`, bao gồm:
- ✅ Tạo tất cả databases
- ✅ Tạo tất cả tables với constraints
- ✅ **Insert FULL dữ liệu mẫu cho TẤT CẢ các bảng**
- ✅ Thống kê số lượng data sau khi import

## 📊 DỮ LIỆU MẪU BAO GỒM:

### 1. **User Service (userdb)**
- ✅ **8 Users** với các roles khác nhau:
  - 1 Admin
  - 1 Recruiter
  - 6 Users (với ELO scores từ NEWBIE đến GOLD)
- ✅ **11 ELO History** records
- ✅ **3 Roles** (USER, RECRUITER, ADMIN)

### 2. **Question Service (questiondb)**
- ✅ **6 Fields** (Lập trình viên, Business Analyst, Tester, DevOps, Data Science, UI/UX)
- ✅ **25 Topics** phân bổ theo fields
- ✅ **6 Levels** (Fresher → Architect)
- ✅ **8 Question Types** (Multiple Choice, Open Ended, True/False, etc.)
- ✅ **15 Questions** đa dạng về topics và levels
- ✅ **15 Answers** (bao gồm sample answers)

### 3. **Career Service (careerdb)**
- ✅ **20 Career Preferences** linking users với fields/topics

### 4. **Exam Service (examdb)**
- ✅ **8 Exams** (TECHNICAL, BEHAVIORAL types)
- ✅ **17 Exam Questions** mappings
- ✅ **10 Results** với feedback chi tiết
- ✅ **13 User Answers** với similarity scores
- ✅ **15 Exam Registrations** (bao gồm 1 cancelled)

### 5. **News Service (newsdb)**
- ✅ **8 News Articles** về công nghệ
- ✅ **10 Recruitment Posts** với thông tin đầy đủ

**TỔNG CỘNG: 160+ records** phân bố trên 6 databases!

---

## 🎯 CÁCH 1: SỬ DỤNG DOCKER (KHUYẾN NGHỊ)

### Bước 1: Dừng và xóa container cũ

```powershell
docker-compose down
docker volume ls | Select-String "postgres_data" | ForEach-Object {
    $volumeName = $_.ToString().Split()[-1]
    docker volume rm $volumeName
}
```

### Bước 2: Sửa docker-compose.yml

Thay đổi dòng 16 từ:
```yaml
- ./init.sql:/docker-entrypoint-initdb.d/init.sql
```

Thành:
```yaml
- ./init-with-data.sql:/docker-entrypoint-initdb.d/init.sql
```

### Bước 3: Khởi động lại

```powershell
docker-compose up -d postgres
```

Chờ 15-20 giây để PostgreSQL khởi động và chạy init script:

```powershell
# Xem logs để theo dõi quá trình
docker-compose logs -f postgres
```

Bạn sẽ thấy messages như:
```
✅ TẤT CẢ DATABASES VÀ DỮ LIỆU MẪU ĐÃ ĐƯỢC TẠO THÀNH CÔNG!
📊 THỐNG KÊ DỮ LIỆU:
total_users: 8
total_questions: 15
...
🎉 HỆ THỐNG SẴN SÀNG SỬ DỤNG!
```

### Bước 4: Khởi động các services khác

```powershell
docker-compose up -d
```

---

## 🎯 CÁCH 2: CHẠY THỦ CÔNG VÀO CONTAINER ĐANG CHẠY

### Bước 1: Copy file vào container

```powershell
docker cp init-with-data.sql interview-postgres:/init-with-data.sql
```

### Bước 2: Chạy file SQL

```powershell
docker exec -i interview-postgres psql -U postgres -f /init-with-data.sql
```

### Bước 3: Restart các microservices

```powershell
docker-compose restart
```

---

## 🎯 CÁCH 3: DÙNG SCRIPT TỰ ĐỘNG

Tạo file **`run-init-with-data.ps1`**:

```powershell
# =============================================
# Script tự động chạy init-with-data.sql
# =============================================

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "CHẠY INIT-WITH-DATA.SQL" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Kiểm tra file tồn tại
if (-not (Test-Path "init-with-data.sql")) {
    Write-Host "✗ Không tìm thấy file init-with-data.sql!" -ForegroundColor Red
    exit 1
}

Write-Host "Chọn phương thức:" -ForegroundColor Cyan
Write-Host "1. Xóa volume và khởi tạo lại (KHUYẾN NGHỊ - Dữ liệu đầy đủ nhất)" -ForegroundColor Green
Write-Host "2. Chạy vào container đang chạy (Nhanh hơn)" -ForegroundColor Yellow
Write-Host ""
$choice = Read-Host "Nhập lựa chọn (1 hoặc 2)"

if ($choice -eq "1") {
    Write-Host ""
    Write-Host "⚠️  CẢNH BÁO: Xóa toàn bộ data PostgreSQL hiện tại!" -ForegroundColor Red
    $confirm = Read-Host "Tiếp tục? (yes/no)"
    
    if ($confirm -eq "yes") {
        Write-Host ""
        Write-Host "Dừng containers..." -ForegroundColor Yellow
        docker-compose down
        
        Write-Host "Xóa PostgreSQL volume..." -ForegroundColor Yellow
        docker volume ls | Select-String "postgres_data" | ForEach-Object {
            $volumeName = $_.ToString().Split()[-1]
            Write-Host "  Đang xóa: $volumeName" -ForegroundColor Gray
            docker volume rm $volumeName 2>$null
        }
        
        Write-Host "Sao chép init-with-data.sql..." -ForegroundColor Yellow
        Copy-Item "init-with-data.sql" "init-temp.sql"
        
        Write-Host "Cập nhật docker-compose.yml..." -ForegroundColor Yellow
        $dockerCompose = Get-Content "docker-compose.yml" -Raw
        $dockerCompose = $dockerCompose -replace "./init.sql:/docker-entrypoint-initdb.d/init.sql", "./init-with-data.sql:/docker-entrypoint-initdb.d/init.sql"
        Set-Content "docker-compose.yml" $dockerCompose
        
        Write-Host "Khởi động PostgreSQL..." -ForegroundColor Yellow
        docker-compose up -d postgres
        
        Write-Host ""
        Write-Host "Chờ PostgreSQL khởi động và chạy init script..." -ForegroundColor Yellow
        Write-Host "Quá trình này có thể mất 20-30 giây..." -ForegroundColor Gray
        Start-Sleep -Seconds 25
        
        Write-Host ""
        Write-Host "Khởi động các services khác..." -ForegroundColor Yellow
        docker-compose up -d
        
        Write-Host ""
        Write-Host "✓ Hoàn tất!" -ForegroundColor Green
    } else {
        Write-Host "Đã hủy" -ForegroundColor Yellow
        exit 0
    }
} elseif ($choice -eq "2") {
    Write-Host ""
    Write-Host "Kiểm tra container..." -ForegroundColor Yellow
    $containerRunning = docker ps --filter "name=interview-postgres" --format "{{.Names}}"
    
    if (-not $containerRunning) {
        Write-Host "✗ PostgreSQL container chưa chạy!" -ForegroundColor Red
        Write-Host "Vui lòng chạy: docker-compose up -d" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "Copy file vào container..." -ForegroundColor Yellow
    docker cp init-with-data.sql interview-postgres:/init-with-data.sql
    
    Write-Host "Chạy init-with-data.sql..." -ForegroundColor Yellow
    docker exec -i interview-postgres psql -U postgres -f /init-with-data.sql
    
    Write-Host "Restart microservices..." -ForegroundColor Yellow
    docker-compose restart
    
    Write-Host ""
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

Write-Host "1. Danh sách databases:" -ForegroundColor Yellow
docker exec -i interview-postgres psql -U postgres -c "\l"

Write-Host ""
Write-Host "2. Số lượng users:" -ForegroundColor Yellow
docker exec -i interview-postgres psql -U postgres -d userdb -c "SELECT COUNT(*) as total_users FROM users;"

Write-Host ""
Write-Host "3. Số lượng questions:" -ForegroundColor Yellow
docker exec -i interview-postgres psql -U postgres -d questiondb -c "SELECT COUNT(*) as total_questions FROM questions;"

Write-Host ""
Write-Host "4. Số lượng exams:" -ForegroundColor Yellow
docker exec -i interview-postgres psql -U postgres -d examdb -c "SELECT COUNT(*) as total_exams FROM exams;"

Write-Host ""
Write-Host "5. Số lượng news:" -ForegroundColor Yellow
docker exec -i interview-postgres psql -U postgres -d newsdb -c "SELECT COUNT(*) as total_news FROM news;"

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "🎉 HỆ THỐNG ĐÃ SẴN SÀNG!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Tài khoản test:" -ForegroundColor Cyan
Write-Host "  Admin: admin@example.com / password123" -ForegroundColor White
Write-Host "  Recruiter: recruiter@example.com / password123" -ForegroundColor White
Write-Host "  User: user@example.com / password123" -ForegroundColor White
Write-Host ""
Write-Host "API Gateway: http://localhost:8080" -ForegroundColor Cyan
Write-Host "Eureka Dashboard: http://localhost:8761" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test với Postman collection: postman-collections/" -ForegroundColor Yellow
Write-Host ""
```

**Chạy script:**
```powershell
.\run-init-with-data.ps1
```

---

## 🎯 CÁCH 4: CHẠY TỪ HOST (Nếu có psql client)

```powershell
# Đảm bảo PostgreSQL container đang chạy
docker-compose up -d postgres

# Đợi 10 giây
Start-Sleep -Seconds 10

# Chạy file SQL
psql -h localhost -U postgres -f init-with-data.sql

# Nhập password: 123456 (hoặc password bạn đã config)
```

---

## ✅ KIỂM TRA SAU KHI CHẠY

### 1. Kiểm tra databases đã được tạo

```powershell
docker exec -i interview-postgres psql -U postgres -c "\l"
```

**Kết quả mong đợi:**
```
 authdb       | postgres |
 careerdb     | postgres |
 examdb       | postgres |
 newsdb       | postgres |
 postgres     | postgres |
 questiondb   | postgres |
 userdb       | postgres |
```

### 2. Kiểm tra số lượng data

```powershell
# Users
docker exec -i interview-postgres psql -U postgres -d userdb -c "SELECT COUNT(*) FROM users;"
# Kết quả: 8

# Questions
docker exec -i interview-postgres psql -U postgres -d questiondb -c "SELECT COUNT(*) FROM questions;"
# Kết quả: 15

# Topics
docker exec -i interview-postgres psql -U postgres -d questiondb -c "SELECT COUNT(*) FROM topics;"
# Kết quả: 25

# Exams
docker exec -i interview-postgres psql -U postgres -d examdb -c "SELECT COUNT(*) FROM exams;"
# Kết quả: 8

# News + Recruitments
docker exec -i interview-postgres psql -U postgres -d newsdb -c "SELECT COUNT(*) FROM news;"
# Kết quả: 18 (8 news + 10 recruitments)
```

### 3. Kiểm tra users chi tiết

```powershell
docker exec -i interview-postgres psql -U postgres -d userdb -c "SELECT id, email, full_name, elo_score, elo_rank FROM users ORDER BY id;"
```

**Kết quả:**
```
 id |         email          |  full_name     | elo_score | elo_rank 
----+------------------------+----------------+-----------+----------
  1 | admin@example.com      | Admin User     |         0 | NEWBIE
  2 | recruiter@example.com  | Recruiter User |         0 | NEWBIE
  3 | user@example.com       | Nguyễn Văn A   |      1200 | BRONZE
  4 | test@example.com       | Test User      |       800 | NEWBIE
  5 | student@example.com    | Trần Thị B     |       950 | NEWBIE
  6 | developer@example.com  | Lê Văn C       |      1500 | SILVER
  7 | newbie@example.com     | Phạm Thị D     |       500 | NEWBIE
  8 | expert@example.com     | Hoàng Văn E    |      2100 | GOLD
```

### 4. Kiểm tra questions đã approved

```powershell
docker exec -i interview-postgres psql -U postgres -d questiondb -c "SELECT id, question_content, status FROM questions WHERE status = 'APPROVED' LIMIT 5;"
```

### 5. Kiểm tra exam results

```powershell
docker exec -i interview-postgres psql -U postgres -d examdb -c "SELECT e.title, r.score, r.pass_status FROM results r JOIN exams e ON r.exam_id = e.id LIMIT 5;"
```

### 6. Kiểm tra recruitment posts

```powershell
docker exec -i interview-postgres psql -U postgres -d newsdb -c "SELECT title, company_name, position, salary FROM news WHERE news_type = 'RECRUITMENT' AND status = 'PUBLISHED' LIMIT 5;"
```

---

## 🔄 SO SÁNH: init.sql vs init-with-data.sql

| Tính năng | init.sql | init-with-data.sql |
|-----------|----------|-------------------|
| Tạo databases | ✅ | ✅ |
| Tạo tables | ✅ | ✅ |
| Insert roles | ✅ (3 roles) | ✅ (3 roles) |
| Insert fields | ✅ (4 fields) | ✅ (6 fields) |
| Insert topics | ✅ (11 topics) | ✅ (25 topics) |
| Insert levels | ✅ (5 levels) | ✅ (6 levels) |
| Insert question types | ✅ (6 types) | ✅ (8 types) |
| **Insert users** | ❌ | ✅ (8 users) |
| **Insert questions** | ❌ | ✅ (15 questions) |
| **Insert answers** | ❌ | ✅ (15 answers) |
| **Insert exams** | ❌ | ✅ (8 exams) |
| **Insert results** | ❌ | ✅ (10 results) |
| **Insert career prefs** | ❌ | ✅ (20 preferences) |
| **Insert news** | ❌ | ✅ (18 news/recruitments) |
| **Insert ELO history** | ❌ | ✅ (11 records) |
| **Thống kê cuối** | ❌ | ✅ |

---

## 🎯 KHUYẾN NGHỊ

### Khi nào dùng `init.sql`:
- Bạn muốn tự import data riêng
- Cần cấu trúc database cơ bản
- Đang development và muốn test với data của mình

### Khi nào dùng `init-with-data.sql`:
- **Khuyến nghị cho demo và testing**
- Muốn có ngay data mẫu đầy đủ
- Cần test toàn bộ workflow (users → questions → exams → results)
- Presentation/Demo cho khách hàng
- Onboarding developers mới

---

## 📝 TÀI KHOẢN TEST SẴN SÀNG

Sau khi chạy `init-with-data.sql`, bạn có các tài khoản:

### Admin Account
```
Email: admin@example.com
Password: password123
Role: ADMIN
```

### Recruiter Account
```
Email: recruiter@example.com
Password: password123
Role: RECRUITER
```

### User Accounts (6 tài khoản)

**1. User với BRONZE rank:**
```
Email: user@example.com
Password: password123
ELO: 1200 (BRONZE)
```

**2. Developer với SILVER rank:**
```
Email: developer@example.com
Password: password123
ELO: 1500 (SILVER)
```

**3. Expert với GOLD rank:**
```
Email: expert@example.com
Password: password123
ELO: 2100 (GOLD)
```

**4. Test User (PENDING status):**
```
Email: test@example.com
Password: password123
ELO: 800 (NEWBIE)
Status: PENDING
```

**5. Student:**
```
Email: student@example.com
Password: password123
ELO: 950 (NEWBIE)
```

**6. Newbie:**
```
Email: newbie@example.com
Password: password123
ELO: 500 (NEWBIE)
```

---

## 🚀 WORKFLOW TEST SAU KHI CÀI ĐẶT

### 1. Test Authentication
```powershell
# Dùng Postman
POST http://localhost:8080/auth/login
Body: {
  "email": "user@example.com",
  "password": "password123"
}
```

### 2. Test Questions
```powershell
# Get questions by topic
GET http://localhost:8080/topics/1/questions?page=0&size=10
```

### 3. Test Exams
```powershell
# Get exam by type
GET http://localhost:8080/exams/type/TECHNICAL?page=0&size=10
```

### 4. Test News & Recruitment
```powershell
# Get published news
GET http://localhost:8080/news/published/NEWS?page=0&size=10

# Get recruitments
GET http://localhost:8080/recruitments?page=0&size=10
```

---

## ❗ TROUBLESHOOTING

### Lỗi: Duplicate key violation
**Nguyên nhân:** Đã chạy script nhiều lần

**Giải pháp:**
```powershell
# Xóa toàn bộ và chạy lại
docker-compose down
docker volume rm <postgres_volume_name>
docker-compose up -d
```

### Lỗi: Container không khởi động được
**Kiểm tra logs:**
```powershell
docker-compose logs postgres
```

### Data không hiển thị trong API
**Nguyên nhân:** Microservices cần restart

**Giải pháp:**
```powershell
docker-compose restart
```

---

## 🎉 KẾT LUẬN

File `init-with-data.sql` cung cấp:
- ✅ **160+ records** data mẫu
- ✅ **Relationships đầy đủ** giữa các bảng
- ✅ **Realistic data** cho testing
- ✅ **Ready-to-use** accounts
- ✅ **Complete workflow** từ users → exams → results

**Sử dụng script này để có ngay môi trường demo hoàn chỉnh!** 🚀
