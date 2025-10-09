# 🗄️ DATABASE SETUP - INTERVIEW MICROSERVICE ABC

## 📚 Tổng Quan

Project có **2 file SQL chính** để khởi tạo database:

| File | Mô tả | Dữ liệu | Khuyến nghị |
|------|-------|---------|-------------|
| **init.sql** | Tạo databases + tables + taxonomy cơ bản | Roles, Fields, Topics, Levels, Question Types | Development |
| **init-with-data.sql** | Tạo databases + tables + **FULL dữ liệu mẫu** | 160+ records đầy đủ | **Demo/Testing** ✅ |

---

## 🎯 KHUYẾN NGHỊ: Sử dụng init-with-data.sql

### Tại sao?
- ✅ **160+ records** data mẫu hoàn chỉnh
- ✅ **8 Users** với roles và ELO ranks khác nhau
- ✅ **15 Questions** approved sẵn sàng test
- ✅ **8 Exams** với results và feedback
- ✅ **18 News/Recruitment** posts
- ✅ **Complete workflow** từ đầu đến cuối
- ✅ **Ready-to-demo** không cần import thêm

---

## 🚀 CÁCH SỬ DỤNG NHANH

### Cách 1: Chạy Script PowerShell (DỄ NHẤT)

```powershell
.\run-init-with-data.ps1
```

Chọn option 1 (xóa volume và khởi tạo lại) → Nhập `yes`

**Chờ 30 giây** → Xong!

### Cách 2: Thủ Công với Docker

```powershell
# Bước 1: Dừng và xóa volume
docker-compose down
docker volume rm "interview microservice abc_postgres_data"

# Bước 2: Sửa docker-compose.yml
# Dòng 16: ./init-with-data.sql:/docker-entrypoint-initdb.d/init.sql

# Bước 3: Khởi động
docker-compose up -d
```

### Cách 3: Chạy vào Container đang chạy

```powershell
docker cp init-with-data.sql interview-postgres:/init-with-data.sql
docker exec -i interview-postgres psql -U postgres -f /init-with-data.sql
docker-compose restart
```

---

## 📊 DỮ LIỆU MẪU CHI TIẾT

### 1. AUTH SERVICE (authdb)
```
✅ 3 Roles: USER, RECRUITER, ADMIN
```

### 2. USER SERVICE (userdb)
```
✅ 8 Users:
   - 1 Admin (admin@example.com)
   - 1 Recruiter (recruiter@example.com)
   - 6 Users với ELO từ NEWBIE → GOLD
   
✅ 11 ELO History records
✅ 3 Roles
```

**Sample Users:**
| Email | Password | Role | ELO Score | ELO Rank |
|-------|----------|------|-----------|----------|
| admin@example.com | password123 | ADMIN | 0 | NEWBIE |
| recruiter@example.com | password123 | RECRUITER | 0 | NEWBIE |
| user@example.com | password123 | USER | 1200 | BRONZE |
| developer@example.com | password123 | USER | 1500 | SILVER |
| expert@example.com | password123 | USER | 2100 | GOLD |

### 3. QUESTION SERVICE (questiondb)
```
✅ 6 Fields (Lập trình, BA, Tester, DevOps, Data Science, UI/UX)
✅ 25 Topics (ReactJS, VueJS, Spring Boot, Docker, ML, etc.)
✅ 6 Levels (Fresher → Architect)
✅ 8 Question Types (Multiple Choice, Open Ended, System Design, etc.)
✅ 15 Questions (14 APPROVED, 1 PENDING)
✅ 15 Answers (bao gồm sample answers)
```

**Sample Questions:**
- "ReactJS là gì và các tính năng chính?"
- "Giải thích Virtual DOM trong ReactJS"
- "Spring Boot auto-configuration hoạt động thế nào?"
- "Thiết kế hệ thống e-commerce có khả năng mở rộng"
- "Machine Learning là gì và ứng dụng?"

### 4. CAREER SERVICE (careerdb)
```
✅ 20 Career Preferences
   - Users link với fields và topics yêu thích
   - Timestamps cho created_at và updated_at
```

### 5. EXAM SERVICE (examdb)
```
✅ 8 Exams:
   - 7 TECHNICAL exams (ReactJS, Java, Full Stack, DevOps, Data Science, JS, Python)
   - 1 BEHAVIORAL exam
   - Mix của DRAFT và PUBLISHED status
   
✅ 17 Exam Questions mappings
✅ 10 Results với scores và feedback chi tiết
✅ 13 User Answers với similarity scores
✅ 15 Exam Registrations (1 cancelled, 14 active)
```

**Sample Exams:**
| Title | Type | Questions | Duration | Status |
|-------|------|-----------|----------|--------|
| Đánh giá ReactJS Developer | TECHNICAL | 20 | 60 min | PUBLISHED |
| Phỏng vấn Java Spring Boot | TECHNICAL | 25 | 90 min | PUBLISHED |
| Kiểm tra Full Stack Developer | TECHNICAL | 30 | 120 min | PUBLISHED |

### 6. NEWS SERVICE (newsdb)
```
✅ 8 News Articles về công nghệ
   - ReactJS 18 features
   - Spring Boot 3.0 updates
   - Docker best practices
   - Machine Learning trends
   - Kubernetes guide
   
✅ 10 Recruitment Posts:
   - Senior ReactJS Developer - ABC Tech
   - Java Spring Boot Developer - XYZ Corp
   - Full Stack Developer - TechStart
   - DevOps Engineer - CloudTech
   - Data Scientist - DataCorp
   - UI/UX Designer - DesignStudio
   - Business Analyst - FinanceTech
   - Junior Python Developer - AIStart
   - Flutter Developer - MobileHub
   - QA Automation Engineer - TestPro
```

---

## ✅ KIỂM TRA SAU KHI CHẠY

### Quick Check
```powershell
# Xem tất cả databases
docker exec -i interview-postgres psql -U postgres -c "\l"

# Check số lượng data
docker exec -i interview-postgres psql -U postgres -d userdb -c "SELECT COUNT(*) FROM users;"
docker exec -i interview-postgres psql -U postgres -d questiondb -c "SELECT COUNT(*) FROM questions;"
docker exec -i interview-postgres psql -U postgres -d examdb -c "SELECT COUNT(*) FROM exams;"
docker exec -i interview-postgres psql -U postgres -d newsdb -c "SELECT COUNT(*) FROM news;"
```

### Expected Results
```
✅ 6 databases: authdb, userdb, careerdb, questiondb, examdb, newsdb
✅ 8 users
✅ 15 questions
✅ 8 exams
✅ 18 news (8 NEWS + 10 RECRUITMENT)
```

---

## 🔧 TROUBLESHOOTING

### Vấn đề: Init script không chạy
**Nguyên nhân:** Volume cũ vẫn còn

**Giải pháp:**
```powershell
docker-compose down
docker volume ls
docker volume rm <volume_name_with_postgres_data>
docker-compose up -d
```

### Vấn đề: Data không hiển thị trong API
**Nguyên nhân:** Microservices cache hoặc chưa connect DB

**Giải pháp:**
```powershell
docker-compose restart
# Hoặc restart từng service
docker-compose restart user-service
docker-compose restart question-service
```

### Vấn đề: Duplicate key error
**Nguyên nhân:** Đã chạy script nhiều lần

**Giải pháp:**
```powershell
# Drop toàn bộ và chạy lại
docker exec -i interview-postgres psql -U postgres -c "DROP DATABASE IF EXISTS authdb;"
docker exec -i interview-postgres psql -U postgres -c "DROP DATABASE IF EXISTS userdb;"
# ... (drop các DB khác)
# Rồi chạy lại init-with-data.sql
```

---

## 📁 CẤU TRÚC FILES

```
Interview Microservice ABC/
├── init.sql                           # Basic setup (databases + tables + taxonomy)
├── init-with-data.sql                 # Full setup (+ 160+ sample data) ⭐
├── run-init-sql.ps1                   # Script cho init.sql
├── run-init-with-data.ps1            # Script cho init-with-data.sql ⭐
├── HUONG-DAN-CHAY-INIT-SQL.md        # Hướng dẫn init.sql
├── HUONG-DAN-CHAY-INIT-WITH-DATA.md  # Hướng dẫn init-with-data.sql ⭐
├── DATABASE-README.md                 # File này
└── database-import/                   # Import files riêng lẻ (optional)
    ├── authdb-sample-data.sql
    ├── userdb-sample-data.sql
    ├── questiondb-sample-data.sql
    ├── careerdb-sample-data.sql
    ├── examdb-sample-data.sql
    ├── newsdb-sample-data.sql
    ├── quick-import-data.ps1
    └── README.md
```

---

## 🎯 WORKFLOWS

### Workflow 1: Setup từ đầu (Khuyến nghị)
```
1. Chạy: .\run-init-with-data.ps1
2. Chọn option 1 (xóa volume)
3. Đợi 30 giây
4. Test với Postman
```

### Workflow 2: Import thêm data riêng
```
1. Chạy init.sql (cấu trúc cơ bản)
2. Import data riêng của bạn
3. Hoặc dùng database-import/ files
```

### Workflow 3: Reset toàn bộ
```
1. docker-compose down
2. docker volume rm <postgres_volume>
3. Chạy lại init-with-data.sql
```

---

## 📚 TÀI LIỆU LIÊN QUAN

| File | Mô tả |
|------|-------|
| `API-SPECIFICATION.md` | Đặc tả API chi tiết 80+ endpoints |
| `postman-collections/HUONG-DAN-IMPORT.md` | Hướng dẫn test với Postman |
| `postman-collections/Interview-Microservice-ABC.postman_collection.json` | Postman collection |
| `HUONG-DAN-CHAY-INIT-WITH-DATA.md` | Hướng dẫn chi tiết init-with-data.sql |

---

## 🎉 TÓM TẮT

**Để có ngay môi trường demo đầy đủ:**

```powershell
# 1 lệnh duy nhất
.\run-init-with-data.ps1
```

**Chọn option 1 → Nhập "yes" → Đợi 30 giây → DONE!** ✅

Bạn sẽ có:
- ✅ 6 databases
- ✅ 160+ records data mẫu
- ✅ 8 user accounts để test
- ✅ Questions, Exams, Results đầy đủ
- ✅ News & Recruitment posts
- ✅ Ready to demo & test

---

**Happy Coding! 🚀**
