# 🗄️ HƯỚNG DẪN CHẠY INIT.SQL SAU KHI DOCKER-COMPOSE UP

## ⚠️ Tình Huống

Bạn đã chạy `docker-compose up -d` nhưng các databases chưa được tạo từ file `init.sql`.

**Nguyên nhân:** File `init.sql` trong `/docker-entrypoint-initdb.d/` chỉ tự động chạy khi PostgreSQL container được tạo **LẦN ĐẦU TIÊN** và database volume **TRỐNG**.

## ✅ GIẢI PHÁP

### Cách 1: XÓA VOLUME VÀ KHỞI TẠO LẠI (Khuyến nghị - Dễ nhất)

**Bước 1:** Dừng tất cả containers
```powershell
docker-compose down
```

**Bước 2:** Xóa volume PostgreSQL (xóa toàn bộ data cũ)
```powershell
docker volume rm "interview microservice abc_postgres_data"
```

Hoặc nếu volume name khác, kiểm tra tên volume:
```powershell
docker volume ls
```

Sau đó xóa volume có tên chứa `postgres_data`:
```powershell
docker volume rm <volume_name>
```

**Bước 3:** Khởi động lại (init.sql sẽ tự động chạy)
```powershell
docker-compose up -d
```

**Bước 4:** Kiểm tra databases đã được tạo
```powershell
docker exec -it interview-postgres psql -U postgres -c "\l"
```

Bạn sẽ thấy danh sách databases: `authdb`, `userdb`, `careerdb`, `questiondb`, `examdb`, `newsdb`

---

### Cách 2: CHẠY INIT.SQL THỦ CÔNG VÀO CONTAINER ĐANG CHẠY

**Bước 1:** Copy file init.sql vào container
```powershell
docker cp init.sql interview-postgres:/init.sql
```

**Bước 2:** Chạy file init.sql trong container
```powershell
docker exec -it interview-postgres psql -U postgres -f /init.sql
```

**Bước 3:** Kiểm tra kết quả
```powershell
docker exec -it interview-postgres psql -U postgres -c "\l"
```

---

### Cách 3: CHẠY TỪ HOST MACHINE (Nếu có psql client)

**Yêu cầu:** Máy bạn phải cài PostgreSQL client (psql)

**Bước 1:** Chạy file init.sql từ host
```powershell
psql -h localhost -U postgres -f init.sql
```

Nhập password khi được hỏi (mặc định: `123456`)

**Bước 2:** Kiểm tra databases
```powershell
psql -h localhost -U postgres -c "\l"
```

---

### Cách 4: CHẠY TỪNG LỆNH SQL TRỰC TIẾP

**Bước 1:** Truy cập PostgreSQL shell
```powershell
docker exec -it interview-postgres psql -U postgres
```

**Bước 2:** Chạy từng lệnh SQL
```sql
-- Tạo databases
CREATE DATABASE authdb;
CREATE DATABASE userdb;
CREATE DATABASE careerdb;
CREATE DATABASE questiondb;
CREATE DATABASE examdb;
CREATE DATABASE newsdb;

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE authdb TO postgres;
GRANT ALL PRIVILEGES ON DATABASE userdb TO postgres;
GRANT ALL PRIVILEGES ON DATABASE careerdb TO postgres;
GRANT ALL PRIVILEGES ON DATABASE questiondb TO postgres;
GRANT ALL PRIVILEGES ON DATABASE examdb TO postgres;
GRANT ALL PRIVILEGES ON DATABASE newsdb TO postgres;

-- Kiểm tra danh sách databases
\l

-- Thoát
\q
```

---

## 🔍 KIỂM TRA SAU KHI CHẠY INIT.SQL

### 1. Kiểm tra danh sách databases
```powershell
docker exec -it interview-postgres psql -U postgres -c "\l"
```

**Kết quả mong đợi:**
```
                                  List of databases
     Name     |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
--------------+----------+----------+------------+------------+-----------------------
 authdb       | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/postgres         +
              |          |          |            |            | postgres=CTc/postgres
 careerdb     | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 examdb       | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 newsdb       | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 postgres     | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 questiondb   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 userdb       | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
```

### 2. Kiểm tra tables trong từng database

**Kiểm tra userdb:**
```powershell
docker exec -it interview-postgres psql -U postgres -d userdb -c "\dt"
```

**Kết quả mong đợi:**
```
           List of relations
 Schema |    Name     | Type  |  Owner   
--------+-------------+-------+----------
 public | elo_history | table | postgres
 public | roles       | table | postgres
 public | users       | table | postgres
```

**Kiểm tra questiondb:**
```powershell
docker exec -it interview-postgres psql -U postgres -d questiondb -c "\dt"
```

**Kết quả mong đợi:**
```
              List of relations
 Schema |       Name       | Type  |  Owner   
--------+------------------+-------+----------
 public | answers          | table | postgres
 public | fields           | table | postgres
 public | levels           | table | postgres
 public | question_types   | table | postgres
 public | questions        | table | postgres
 public | topics           | table | postgres
```

**Kiểm tra examdb:**
```powershell
docker exec -it interview-postgres psql -U postgres -d examdb -c "\dt"
```

**Kiểm tra newsdb:**
```powershell
docker exec -it interview-postgres psql -U postgres -d newsdb -c "\dt"
```

### 3. Kiểm tra sample data

**Kiểm tra roles:**
```powershell
docker exec -it interview-postgres psql -U postgres -d userdb -c "SELECT * FROM roles;"
```

**Kết quả mong đợi:**
```
 id | role_name  |         description          
----+------------+------------------------------
  1 | USER       | Role cho sinh viên/người tìm việc
  2 | RECRUITER  | Role cho nhà tuyển dụng
  3 | ADMIN      | Role cho quản trị viên
```

**Kiểm tra fields:**
```powershell
docker exec -it interview-postgres psql -U postgres -d questiondb -c "SELECT * FROM fields;"
```

**Kiểm tra topics:**
```powershell
docker exec -it interview-postgres psql -U postgres -d questiondb -c "SELECT COUNT(*) FROM topics;"
```

---

## 📋 SCRIPT TỰ ĐỘNG (Tạo file PowerShell)

Tạo file `run-init-sql.ps1`:

```powershell
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
        docker volume rm "interview microservice abc_postgres_data" 2>$null
        
        Write-Host "Đang khởi động lại..." -ForegroundColor Yellow
        docker-compose up -d
        
        Write-Host ""
        Write-Host "Chờ PostgreSQL khởi động..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        
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
    docker exec -it interview-postgres psql -U postgres -f /init.sql
    
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
docker exec -it interview-postgres psql -U postgres -c "\l"

Write-Host ""
Write-Host "Tables trong userdb:" -ForegroundColor Yellow
docker exec -it interview-postgres psql -U postgres -d userdb -c "\dt"

Write-Host ""
Write-Host "Roles trong userdb:" -ForegroundColor Yellow
docker exec -it interview-postgres psql -U postgres -d userdb -c "SELECT * FROM roles;"

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "🎉 HOÀN TẤT!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Bạn có thể import sample data bằng lệnh:" -ForegroundColor Cyan
Write-Host "  cd database-import" -ForegroundColor White
Write-Host "  .\quick-import-data.ps1" -ForegroundColor White
Write-Host ""
```

**Cách sử dụng script:**
```powershell
.\run-init-sql.ps1
```

---

## 🚀 SAU KHI CHẠY INIT.SQL

### Bước tiếp theo: Import Sample Data

**Cách 1: Sử dụng Script PowerShell (Khuyến nghị)**
```powershell
cd database-import
.\quick-import-data.ps1
```

**Cách 2: Import thủ công từng database**
```powershell
# Import vào container
docker cp database-import/authdb-sample-data.sql interview-postgres:/tmp/
docker cp database-import/userdb-sample-data.sql interview-postgres:/tmp/
docker cp database-import/questiondb-sample-data.sql interview-postgres:/tmp/
docker cp database-import/careerdb-sample-data.sql interview-postgres:/tmp/
docker cp database-import/examdb-sample-data.sql interview-postgres:/tmp/
docker cp database-import/newsdb-sample-data.sql interview-postgres:/tmp/

# Chạy từng file
docker exec -it interview-postgres psql -U postgres -f /tmp/authdb-sample-data.sql
docker exec -it interview-postgres psql -U postgres -f /tmp/userdb-sample-data.sql
docker exec -it interview-postgres psql -U postgres -f /tmp/questiondb-sample-data.sql
docker exec -it interview-postgres psql -U postgres -f /tmp/careerdb-sample-data.sql
docker exec -it interview-postgres psql -U postgres -f /tmp/examdb-sample-data.sql
docker exec -it interview-postgres psql -U postgres -f /tmp/newsdb-sample-data.sql
```

### Restart các microservices

Sau khi tạo databases, restart các microservices để kết nối đúng:

```powershell
docker-compose restart auth-service
docker-compose restart user-service
docker-compose restart career-service
docker-compose restart question-service
docker-compose restart exam-service
docker-compose restart news-service
```

Hoặc restart tất cả:
```powershell
docker-compose restart
```

---

## ❗ TROUBLESHOOTING

### Lỗi: Volume đang được sử dụng
```
Error response from daemon: remove postgres_data: volume is in use
```

**Giải pháp:**
```powershell
# Dừng tất cả containers trước
docker-compose down

# Sau đó mới xóa volume
docker volume rm "interview microservice abc_postgres_data"
```

### Lỗi: File không tìm thấy
```
No such file or directory: init.sql
```

**Giải pháp:** Đảm bảo bạn đang ở đúng thư mục gốc của project (nơi có file `init.sql`)
```powershell
# Kiểm tra
ls init.sql

# Nếu không thấy, cd về thư mục gốc
cd "D:\Job\Interview Microservice ABC"
```

### Lỗi: Permission denied
**Giải pháp:** Chạy PowerShell với quyền Administrator

### Databases được tạo nhưng không có tables
**Nguyên nhân:** File `init.sql` chỉ tạo databases, không tạo tables.

**Giải pháp:** Tables sẽ được tạo tự động bởi JPA/Hibernate khi các microservices khởi động lần đầu.

Kiểm tra logs:
```powershell
docker-compose logs user-service | Select-String "Hibernate"
```

---

## 📝 TÓM TẮT NHANH

**Cách nhanh nhất (Nếu chưa có data quan trọng):**
```powershell
docker-compose down
docker volume rm "interview microservice abc_postgres_data"
docker-compose up -d
```

**Cách an toàn (Giữ nguyên data hiện tại):**
```powershell
docker cp init.sql interview-postgres:/init.sql
docker exec -it interview-postgres psql -U postgres -f /init.sql
```

**Kiểm tra:**
```powershell
docker exec -it interview-postgres psql -U postgres -c "\l"
```

---

Chúc bạn thành công! 🚀
