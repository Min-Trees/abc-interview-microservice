# 🚀 HƯỚNG DẪN CHẠY SCRIPT run-init-with-data.ps1

## 📋 Mục Đích

Script `run-init-with-data.ps1` giúp bạn tự động:
- ✅ Tạo tất cả databases (authdb, userdb, careerdb, questiondb, examdb, newsdb)
- ✅ Tạo tất cả tables với relationships
- ✅ Import **160+ records** dữ liệu mẫu đầy đủ
- ✅ Kiểm tra kết quả tự động
- ✅ Hiển thị tài khoản test sẵn sàng

---

## 🎯 YÊU CẦU TRƯỚC KHI CHẠY

### 1. Kiểm tra Docker đang chạy

```powershell
docker --version
```

**Kết quả mong đợi:** 
```
Docker version 24.x.x, build xxxxx
```

Nếu báo lỗi → Mở **Docker Desktop** và đợi nó khởi động xong.

### 2. Kiểm tra file tồn tại

```powershell
# Kiểm tra file script
ls run-init-with-data.ps1

# Kiểm tra file SQL
ls init-with-data.sql
```

Cả 2 files phải ở **cùng thư mục** với `docker-compose.yml`

### 3. Vị trí thư mục

Đảm bảo bạn đang ở đúng thư mục gốc của project:

```powershell
# Kiểm tra thư mục hiện tại
pwd

# Kết quả phải là:
# D:\Job\Interview Microservice ABC
```

Nếu sai thư mục:
```powershell
cd "D:\Job\Interview Microservice ABC"
```

---

## 🚀 CÁCH CHẠY (3 BƯỚC ĐơN GIẢN)

### BƯỚC 1: Mở PowerShell

**Cách 1: Từ File Explorer**
1. Mở thư mục `D:\Job\Interview Microservice ABC`
2. Giữ phím **Shift** + Click chuột phải vào vùng trống
3. Chọn **"Open PowerShell window here"** hoặc **"Open in Terminal"**

**Cách 2: Từ Start Menu**
1. Nhấn **Windows + X**
2. Chọn **"Windows PowerShell (Admin)"** hoặc **"Terminal (Admin)"**
3. Chạy lệnh:
```powershell
cd "D:\Job\Interview Microservice ABC"
```

### BƯỚC 2: Chạy Script

```powershell
.\run-init-with-data.ps1
```

**Lưu ý:** Phải có dấu `.\` ở đầu!

### BƯỚC 3: Chọn Option

Script sẽ hiển thị menu:

```
=========================================
CHẠY INIT-WITH-DATA.SQL
Tạo databases + Insert 160+ records data mẫu
=========================================

Chọn phương thức:

1. Xóa volume và khởi tạo lại (KHUYẾN NGHỊ)
   → Dữ liệu đầy đủ nhất, clean start

2. Chạy vào container đang chạy
   → Nhanh hơn, giữ một số config

Nhập lựa chọn (1 hoặc 2):
```

---

## 📌 OPTION 1: XÓA VOLUME VÀ KHỞI TẠO LẠI (KHUYẾN NGHỊ)

### Khi nào dùng?
- ✅ Lần đầu tiên setup
- ✅ Muốn reset toàn bộ về trạng thái ban đầu
- ✅ Có lỗi với database cũ
- ✅ Muốn dữ liệu sạch 100%

### Các bước:

**1. Chọn option 1**
```
Nhập lựa chọn (1 hoặc 2): 1
```

**2. Xác nhận xóa data**
```
⚠️  CẢNH BÁO: Thao tác này sẽ XÓA TOÀN BỘ DATA PostgreSQL hiện tại!
Bạn có chắc chắn muốn tiếp tục? (yes/no): yes
```

**3. Script sẽ tự động:**
- Dừng tất cả containers
- Xóa PostgreSQL volume (xóa toàn bộ data cũ)
- Cập nhật docker-compose.yml
- Khởi động PostgreSQL
- Chạy init-with-data.sql (tạo DB + import data)
- Khởi động các services khác

**4. Đợi khoảng 30 giây**

Bạn sẽ thấy:
```
📦 Đang dừng containers...
🗑️  Đang xóa PostgreSQL volume...
  → Xóa volume: interview_microservice_abc_postgres_data
📝 Đang cập nhật docker-compose.yml...
  → Đã cập nhật mount point
🐘 Đang khởi động PostgreSQL...

⏳ Đang chờ PostgreSQL khởi động và chạy init script...
   Quá trình này có thể mất 20-30 giây...

[Progress bar 100%]

🚀 Đang khởi động các services khác...

✓ Hoàn tất!
```

**5. Kiểm tra kết quả**

Script sẽ tự động kiểm tra và hiển thị:
```
=========================================
📊 KIỂM TRA KẾT QUẢ
=========================================

1️⃣  Danh sách databases:
   authdb, userdb, careerdb, questiondb, examdb, newsdb ✓

2️⃣  Thống kê dữ liệu:
   👥 Users: 8
   📚 Topics: 25
   ❓ Questions: 15
   💬 Answers: 15
   📝 Exams: 8
   🏆 Results: 10
   📰 News: 8
   💼 Recruitments: 10

3️⃣  Sample Users:
   id | email                 | full_name      | elo_score | elo_rank
   ---+-----------------------+----------------+-----------+----------
    1 | admin@example.com     | Admin User     |         0 | NEWBIE
    2 | recruiter@example.com | Recruiter User |         0 | NEWBIE
    3 | user@example.com      | Nguyễn Văn A   |      1200 | BRONZE
    ...
```

---

## 📌 OPTION 2: CHẠY VÀO CONTAINER ĐANG CHẠY

### Khi nào dùng?
- ✅ Container PostgreSQL đã chạy
- ✅ Muốn nhanh hơn
- ✅ Không muốn xóa config khác
- ✅ Đang development và test

### Yêu cầu:
- PostgreSQL container phải đang chạy

Kiểm tra:
```powershell
docker ps | Select-String "postgres"
```

Nếu không thấy, khởi động:
```powershell
docker-compose up -d postgres
```

### Các bước:

**1. Chọn option 2**
```
Nhập lựa chọn (1 hoặc 2): 2
```

**2. Script sẽ tự động:**
- Kiểm tra container đang chạy
- Copy file SQL vào container
- Chạy init-with-data.sql
- Restart các microservices

**3. Đợi khoảng 15-20 giây**

```
🔍 Kiểm tra PostgreSQL container...
  → Container đang chạy: interview-postgres

📤 Copy file vào container...
  → Đã copy thành công

⚙️  Đang chạy init-with-data.sql...
   Quá trình này có thể mất 10-15 giây...

🔄 Đang restart microservices...

✓ Hoàn tất!
```

---

## ✅ SAU KHI CHẠY XONG

### Bạn sẽ thấy màn hình tổng kết:

```
=========================================
🎉 HỆ THỐNG ĐÃ SẴN SÀNG SỬ DỤNG!
=========================================

📋 TÀI KHOẢN TEST:

   🔑 Admin:
      Email: admin@example.com
      Password: password123

   🔑 Recruiter:
      Email: recruiter@example.com
      Password: password123

   🔑 User (BRONZE rank):
      Email: user@example.com
      Password: password123
      ELO Score: 1200

   🔑 Developer (SILVER rank):
      Email: developer@example.com
      Password: password123
      ELO Score: 1500

   🔑 Expert (GOLD rank):
      Email: expert@example.com
      Password: password123
      ELO Score: 2100

🌐 SERVICE URLs:
   API Gateway: http://localhost:8080
   Eureka Dashboard: http://localhost:8761
   Config Server: http://localhost:8888

📚 HƯỚNG DẪN TIẾP THEO:
   1. Import Postman collection từ: postman-collections/
   2. Đọc API documentation: API-SPECIFICATION.md
   3. Xem hướng dẫn test: postman-collections/HUONG-DAN-IMPORT.md

🎯 DỮ LIỆU MẪU BAO GỒM:
   ✅ 8 Users với ELO ranks khác nhau
   ✅ 15 Questions đã approved
   ✅ 25 Topics phân bổ theo 6 fields
   ✅ 8 Exams (Technical & Behavioral)
   ✅ 10 Exam Results với feedback
   ✅ 18 News & Recruitment posts
   ✅ 20 Career Preferences

Press any key to exit...
```

---

## 🧪 TEST SAU KHI SETUP

### 1. Kiểm tra containers đang chạy

```powershell
docker-compose ps
```

**Kết quả mong đợi:** Tất cả services đều **Up** và **healthy**

### 2. Test API Gateway

```powershell
# Mở browser
start http://localhost:8080/actuator/health
```

**Kết quả:** `{"status":"UP"}`

### 3. Test Eureka Dashboard

```powershell
start http://localhost:8761
```

**Kết quả:** Thấy tất cả services đã đăng ký

### 4. Test Login với Postman

**Endpoint:** `POST http://localhost:8080/auth/login`

**Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Kết quả:** Nhận được token

---

## ❗ XỬ LÝ LỖI THƯỜNG GẶP

### Lỗi 1: "execution of scripts is disabled on this system"

**Nguyên nhân:** Windows chặn chạy PowerShell scripts

**Giải pháp:**
```powershell
# Mở PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Chạy lại script
.\run-init-with-data.ps1
```

### Lỗi 2: "cannot be loaded because running scripts is disabled"

**Giải pháp thay thế:**
```powershell
# Chạy với bypass
powershell -ExecutionPolicy Bypass -File .\run-init-with-data.ps1
```

### Lỗi 3: "File not found: init-with-data.sql"

**Nguyên nhân:** Sai thư mục hoặc file không tồn tại

**Giải pháp:**
```powershell
# Kiểm tra thư mục hiện tại
pwd

# Di chuyển đến đúng thư mục
cd "D:\Job\Interview Microservice ABC"

# Kiểm tra file tồn tại
ls init-with-data.sql
```

### Lỗi 4: "PostgreSQL container chưa chạy" (Option 2)

**Giải pháp:**
```powershell
# Khởi động PostgreSQL
docker-compose up -d postgres

# Đợi 10 giây
Start-Sleep -Seconds 10

# Chạy lại script
.\run-init-with-data.ps1
```

### Lỗi 5: "Volume is in use"

**Nguyên nhân:** Containers vẫn đang chạy

**Giải pháp:**
```powershell
# Dừng tất cả containers
docker-compose down

# Chờ 5 giây
Start-Sleep -Seconds 5

# Chạy lại script
.\run-init-with-data.ps1
```

### Lỗi 6: Docker Desktop không chạy

**Giải pháp:**
1. Mở **Docker Desktop**
2. Đợi nó khởi động xong (biểu tượng Docker trên taskbar ngừng xoay)
3. Chạy lại script

### Lỗi 7: Port đã được sử dụng (8080, 5432, etc.)

**Giải pháp:**
```powershell
# Kiểm tra process đang dùng port
netstat -ano | findstr :8080
netstat -ano | findstr :5432

# Kill process nếu cần (thay PID bằng số thực tế)
taskkill /PID <PID> /F
```

---

## 📝 MẸO VÀ TRICKS

### 1. Chạy nhanh trong 1 lệnh

Nếu bạn chắc chắn muốn xóa volume và reset:

```powershell
# Tự động chọn option 1 và confirm yes
echo "1" | .\run-init-with-data.ps1
```

### 2. Xem logs chi tiết

```powershell
# Xem logs PostgreSQL
docker-compose logs -f postgres

# Xem logs tất cả services
docker-compose logs -f
```

### 3. Chạy lại chỉ PostgreSQL

```powershell
# Nếu chỉ muốn restart PostgreSQL
docker-compose restart postgres

# Hoặc rebuild
docker-compose up -d --build postgres
```

### 4. Kiểm tra volume

```powershell
# Xem tất cả volumes
docker volume ls

# Xem chi tiết volume
docker volume inspect <volume_name>
```

### 5. Backup data trước khi xóa

```powershell
# Backup tất cả databases
docker exec -i interview-postgres pg_dumpall -U postgres > backup.sql

# Restore sau này
docker exec -i interview-postgres psql -U postgres < backup.sql
```

---

## 🔄 WORKFLOW HOÀN CHỈNH

### Lần đầu tiên setup:

```
1. Mở PowerShell tại thư mục project
   └─> cd "D:\Job\Interview Microservice ABC"

2. Chạy script
   └─> .\run-init-with-data.ps1

3. Chọn option 1
   └─> Nhập: 1

4. Confirm
   └─> Nhập: yes

5. Đợi 30 giây
   └─> Script tự động chạy

6. Kiểm tra kết quả
   └─> Xem thống kê hiển thị

7. Test API
   └─> Dùng Postman hoặc browser

8. Start coding! 🚀
```

### Khi cần reset lại:

```
1. Chạy script
   └─> .\run-init-with-data.ps1

2. Chọn option 1 và confirm yes
   └─> Tất cả data sẽ được reset

3. Đợi 30 giây → Done!
```

### Khi chỉ cần update data:

```
1. Sửa file init-with-data.sql
   └─> Thêm/sửa INSERT statements

2. Chạy script với option 2
   └─> .\run-init-with-data.ps1 → Chọn 2

3. Data mới sẽ được import
```

---

## 📊 TIMELINE DỰ KIẾN

| Bước | Thời gian | Mô tả |
|------|-----------|-------|
| Chạy script | 1 giây | Hiển thị menu |
| Chọn option & confirm | 5 giây | Nhập lựa chọn |
| Dừng containers | 5 giây | docker-compose down |
| Xóa volume | 2 giây | docker volume rm |
| Khởi động PostgreSQL | 10 giây | docker-compose up postgres |
| Chạy init script | 10 giây | Tạo DB + import data |
| Khởi động services | 5 giây | docker-compose up |
| Kiểm tra kết quả | 3 giây | Queries kiểm tra |
| **TỔNG** | **~40 giây** | **Từ bắt đầu đến hoàn tất** |

---

## ✨ TÓM TẮT 1 LỆNH

```powershell
# TẤT CẢ TRONG 1 LỆNH
.\run-init-with-data.ps1
# Chọn 1 → yes → Đợi 30 giây → DONE!
```

---

## 🎯 CHECKLIST SAU KHI HOÀN TẤT

- [ ] Tất cả containers đang chạy (`docker-compose ps`)
- [ ] 6 databases đã được tạo (authdb, userdb, etc.)
- [ ] 160+ records data đã được import
- [ ] API Gateway trả về status UP (http://localhost:8080/actuator/health)
- [ ] Eureka Dashboard hiển thị services (http://localhost:8761)
- [ ] Login thành công với user@example.com / password123
- [ ] Postman collection sẵn sàng để test

**Nếu tất cả checklist đều ✅ → Bạn đã setup thành công! 🎉**

---

## 📞 CẦN TRỢ GIÚP?

### Tài liệu liên quan:
- `HUONG-DAN-CHAY-INIT-WITH-DATA.md` - Hướng dẫn chi tiết init-with-data.sql
- `DATABASE-README.md` - Tổng quan về databases
- `API-SPECIFICATION.md` - Đặc tả API đầy đủ
- `postman-collections/HUONG-DAN-IMPORT.md` - Hướng dẫn test với Postman

### Kiểm tra logs nếu có lỗi:
```powershell
docker-compose logs postgres
docker-compose logs user-service
docker-compose logs question-service
```

---

**Happy Coding! 🚀**
