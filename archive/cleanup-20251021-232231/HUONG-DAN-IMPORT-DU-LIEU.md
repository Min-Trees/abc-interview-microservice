# 📚 HƯỚNG DẪN IMPORT DỮ LIỆU VÀO DATABASE

## 🎯 MỤC ĐÍCH

Script `run-init-with-data.ps1` giúp bạn:
- Tạo 6 databases (authdb, userdb, careerdb, questiondb, examdb, newsdb)
- Import 160+ records dữ liệu mẫu đầy đủ
- Mật khẩu được mã hóa bằng BCrypt
- Tự động kiểm tra kết quả

---

## ✅ YÊU CẦU

### 1. Docker Desktop đang chạy
- Icon Docker màu xanh trên taskbar
- Không có thông báo lỗi

### 2. Files cần thiết
- `init-with-data.sql` - File SQL chứa dữ liệu
- `docker-compose.yml` - File cấu hình Docker
- `run-init-with-data.ps1` - Script PowerShell

### 3. Thư mục làm việc
Phải ở đúng thư mục gốc của project:
```
D:\Job\Interview Microservice ABC
```

---

## 🚀 CÁCH CHẠY

### Bước 1: Mở PowerShell

**Cách 1: Từ File Explorer**
1. Mở thư mục `D:\Job\Interview Microservice ABC`
2. Shift + Click chuột phải → "Open PowerShell window here"

**Cách 2: Từ Terminal**
```powershell
cd "D:\Job\Interview Microservice ABC"
```

### Bước 2: Chạy script

```powershell
.\run-init-with-data.ps1
```

### Bước 3: Chọn phương thức

Script sẽ hiển thị 2 options:

#### **OPTION 1: FRESH START (KHUYẾN NGHỊ)** ✅

```
1. FRESH START (Recommended)
   - Stop all containers
   - Delete PostgreSQL volume (remove all old data)
   - Start PostgreSQL with new data
   - Import all sample data
```

**Khi nào dùng?**
- Lần đầu tiên setup
- Muốn reset toàn bộ về trạng thái ban đầu
- Có lỗi với data cũ
- Muốn dữ liệu sạch 100%

**Nhập:** `1` → Enter → `yes` → Enter

**Thời gian:** ~40 giây

#### **OPTION 2: IMPORT TO RUNNING CONTAINER** ⚡

```
2. IMPORT TO RUNNING CONTAINER
   - Keep existing data
   - Import into running container
   - May have conflicts if data exists
```

**Khi nào dùng?**
- PostgreSQL đã chạy
- Muốn nhanh hơn
- Không muốn xóa config khác

**Nhập:** `2` → Enter

**Thời gian:** ~20 giây

---

## 📊 QUÁ TRÌNH THỰC HIỆN

### Option 1: Fresh Start

```
[STEP 1/6] Stopping all containers...
[OK] Containers stopped

[STEP 2/6] Removing PostgreSQL volume...
  Removing volume: interview_microservice_abc_postgres_data
[OK] Volume removed

[STEP 3/6] Updating docker-compose.yml...
[OK] Updated mount point to init-with-data.sql

[STEP 4/6] Starting PostgreSQL...

[STEP 5/6] Waiting for PostgreSQL to initialize...
This may take 30-40 seconds as it creates databases and imports data...
[Progress bar 100%]
[OK] PostgreSQL initialized

[STEP 6/6] Starting other services...
[OK] All services started
```

### Option 2: Import to Running Container

```
[STEP 1/3] Copying SQL file to container...
[OK] File copied to container

[STEP 2/3] Executing SQL script...
This may take 15-20 seconds...
[OK] SQL script executed

[STEP 3/3] Restarting microservices...
[OK] Services restarted
```

---

## ✅ KIỂM TRA KẾT QUẢ

Script tự động kiểm tra:

### 1. Databases
```
[OK] All 6 databases created
  - authdb
  - userdb
  - careerdb
  - questiondb
  - examdb
  - newsdb
```

### 2. Data Counts
```
[OK] Users: 8
[OK] Questions: 15
[OK] Topics: 25
[OK] Exams: 8
[OK] News: 18
```

### 3. Sample User Data
```
id | email                 | full_name      | elo_score | elo_rank | status
---+-----------------------+----------------+-----------+----------+--------
 1 | admin@example.com     | Admin User     |         0 | NEWBIE   | ACTIVE
 2 | recruiter@example.com | Recruiter User |         0 | NEWBIE   | ACTIVE
 3 | user@example.com      | Nguyen Van A   |      1200 | BRONZE   | ACTIVE
 ...
```

### 4. Password Encryption
```
[OK] Passwords are BCrypt encrypted
Sample hash: $2a$10$N.zmdr9k7uOCQb376NoUnu...
Password for all test users: password123
```

---

## 🔑 TÀI KHOẢN TEST

Tất cả tài khoản dùng password: **`password123`**

### Admin
```
Email: admin@example.com
Password: password123
Role: ADMIN
```

### Recruiter
```
Email: recruiter@example.com
Password: password123
Role: RECRUITER
```

### User - BRONZE
```
Email: user@example.com
Password: password123
ELO: 1200
Rank: BRONZE
```

### Developer - SILVER
```
Email: developer@example.com
Password: password123
ELO: 1500
Rank: SILVER
```

### Expert - GOLD
```
Email: expert@example.com
Password: password123
ELO: 2100
Rank: GOLD
```

---

## 🔍 KIỂM TRA THỦ CÔNG

### Script kiểm tra tự động:

```powershell
.\check-database-data.ps1
```

### Hoặc kiểm tra thủ công:

```powershell
# Kiem tra container
docker ps | Select-String postgres

# Kiem tra databases
docker exec -i interview-postgres psql -U postgres -c "\l"

# Kiem tra users
docker exec -i interview-postgres psql -U postgres -d userdb -c "SELECT * FROM users;"

# Kiem tra password encryption
docker exec -i interview-postgres psql -U postgres -d userdb -c "SELECT email, LEFT(password, 30) FROM users;"

# Kiem tra questions
docker exec -i interview-postgres psql -U postgres -d questiondb -c "SELECT COUNT(*) FROM questions;"
```

---

## ❗ XỬ LÝ LỖI

### Lỗi 1: "File not found: init-with-data.sql"

**Nguyên nhân:** Sai thư mục hoặc file không tồn tại

**Giải pháp:**
```powershell
# Kiem tra thu muc hien tai
pwd

# Di chuyen den dung thu muc
cd "D:\Job\Interview Microservice ABC"

# Kiem tra file ton tai
ls init-with-data.sql
```

### Lỗi 2: "Docker is not installed or not running!"

**Giải pháp:**
1. Mở Docker Desktop
2. Đợi icon Docker màu xanh
3. Chạy lại script

### Lỗi 3: "PostgreSQL container is not running!"

**Giải pháp:**
- Script sẽ tự động hỏi bạn có muốn start không
- Chọn `1` để start PostgreSQL

### Lỗi 4: "execution of scripts is disabled"

**Giải pháp:**
```powershell
# Mở PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Hoac chay voi bypass
powershell -ExecutionPolicy Bypass -File .\run-init-with-data.ps1
```

### Lỗi 5: Không có data sau khi chạy

**Nguyên nhân:** Script init.sql không được chạy

**Giải pháp:**
```powershell
# Chay lai voi Option 1 (Fresh Start)
.\run-init-with-data.ps1
# Chon: 1 -> yes
```

### Lỗi 6: Container khởi động nhưng không có data

**Kiểm tra logs:**
```powershell
docker-compose logs postgres
```

**Giải pháp:**
- Xem logs xem có lỗi SQL không
- Chạy lại với Option 2 để import trực tiếp

---

## 🔐 MÃ HÓA MẬT KHẨU

### Xác nhận mật khẩu đã được mã hóa:

```powershell
# Kiem tra password hash
docker exec -i interview-postgres psql -U postgres -d userdb -c "SELECT email, password FROM users LIMIT 1;"
```

**Kết quả mong đợi:**
```
email             | password
------------------+--------------------------------------------------------------
admin@example.com | $2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi
```

**Giải thích:**
- `$2a$` = BCrypt algorithm
- `10` = Cost factor (rounds)
- Phần còn lại = Salt + Hash

**Password gốc:** `password123`

**BCrypt Hash:** `$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi`

---

## 📝 DỮ LIỆU MẪU

### 8 Users
- 1 Admin
- 1 Recruiter  
- 6 Users với ELO khác nhau (NEWBIE → GOLD)

### 25+ Topics
- Phân bổ theo 6 fields
- Software Engineering, Data Science, AI/ML, etc.

### 15+ Questions
- Multiple choice và open-ended
- Difficulty: EASY, MEDIUM, HARD
- Status: APPROVED

### 8+ Exams
- TECHNICAL và BEHAVIORAL
- Status: PUBLISHED
- Duration: 30-90 minutes

### 10+ Exam Results
- Scores, feedback, time spent
- Passed/Failed status

### 18+ News
- NEWS và RECRUITMENT types
- Company info cho recruitments
- Tags, status

### 20+ Career Preferences
- User career interests
- Field và topic preferences

---

## 🎯 SAU KHI IMPORT THÀNH CÔNG

### 1. Test Login với Postman

**Endpoint:** `POST http://localhost:8080/auth/login`

**Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "accessToken": "eyJhbGc...",
  "user": {
    "id": 3,
    "email": "user@example.com",
    "fullName": "Nguyen Van A",
    "eloScore": 1200,
    "eloRank": "BRONZE"
  }
}
```

### 2. Kiểm tra services

```powershell
# Kiem tra tat ca services
docker-compose ps

# Kiem tra logs
docker-compose logs -f user-service
```

### 3. Test APIs

- Import Postman collection từ `postman-collections/`
- Đọc API docs từ `API-SPECIFICATION.md`
- Follow hướng dẫn từ `postman-collections/HUONG-DAN-IMPORT.md`

---

## ⏱️ TIMELINE

| Bước | Thời gian | Mô tả |
|------|-----------|-------|
| Chạy script | 1s | Hiển thị menu |
| Chọn option | 5s | Nhập lựa chọn |
| Stop containers | 5s | docker-compose down |
| Remove volume | 2s | Xóa PostgreSQL data |
| Start PostgreSQL | 10s | docker-compose up |
| Init + Import | 30s | Chạy init-with-data.sql |
| Start services | 5s | docker-compose up -d |
| Verification | 5s | Kiểm tra kết quả |
| **TỔNG** | **~63s** | **Option 1** |
| **TỔNG** | **~25s** | **Option 2** |

---

## 📞 TROUBLESHOOTING

### Nếu vẫn không có data:

```powershell
# 1. Kiem tra container
docker ps

# 2. Kiem tra databases
docker exec -i interview-postgres psql -U postgres -c "\l"

# 3. Kiem tra tables
docker exec -i interview-postgres psql -U postgres -d userdb -c "\dt"

# 4. Count data
docker exec -i interview-postgres psql -U postgres -d userdb -c "SELECT COUNT(*) FROM users;"

# 5. Xem logs
docker-compose logs postgres | Select-String "ERROR"

# 6. Chay lai script
.\run-init-with-data.ps1
# Chon Option 1 -> yes
```

### Nếu cần reset hoàn toàn:

```powershell
# Dung tat ca va xoa volumes
docker-compose down -v

# Chay lai script
.\run-init-with-data.ps1
# Chon Option 1 -> yes
```

---

## ✨ CHECKLIST

Sau khi chạy script, kiểm tra:

- [ ] Script chạy không lỗi
- [ ] 6 databases được tạo
- [ ] Users table có 8 records
- [ ] Password được mã hóa (bắt đầu bằng `$2a$`)
- [ ] Questions table có data
- [ ] Exams table có data
- [ ] Login thành công với `user@example.com / password123`
- [ ] API Gateway trả về status UP
- [ ] Eureka Dashboard hiển thị services

**Nếu tất cả ✅ → Bạn đã setup thành công!** 🎉

---

**Happy Coding! 🚀**



