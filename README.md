# 🎓 Interview Microservice ABC

> Hệ thống phỏng vấn trực tuyến hoàn chỉnh với kiến trúc microservices, ELO ranking và AI grading

[![Java](https://img.shields.io/badge/Java-17-orange.svg)](https://www.oracle.com/java/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-green.svg)](https://spring.io/projects/spring-boot)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue.svg)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)

---

## 📋 MỤC LỤC

- [Giới thiệu](#-giới-thiệu)
- [Kiến trúc](#️-kiến-trúc-hệ-thống)
- [Cài đặt](#-cài-đặt-3-phút)
- [API Endpoints](#-api-endpoints)
- [Authentication](#-authentication)
- [Testing](#-testing)
- [Documentation](#-documentation)

---

## 🎯 GIỚI THIỆU

### Tính năng chính

✅ **Authentication & Authorization** - JWT-based với role management (USER, RECRUITER, ADMIN)  
✅ **User Management** - Profile, ELO ranking system (NEWBIE → MASTER)  
✅ **Question Bank** - Quản lý câu hỏi theo fields, topics, levels  
✅ **Exam System** - Technical & Behavioral exams với auto-grading  
✅ **Career Matching** - Gợi ý career path dựa trên kỹ năng  
✅ **News & Recruitment** - Tin tức và cơ hội việc làm  
✅ **NLP Service** - AI grading và similarity detection (Python FastAPI)

### Tech Stack

**Backend:** Spring Boot 3.x, Spring Cloud (Gateway, Eureka, Config), Spring Security, JPA  
**Database:** PostgreSQL 15 (6 databases)  
**Container:** Docker & Docker Compose  
**NLP:** FastAPI, spaCy, scikit-learn

---

## 🏗️ KIẾN TRÚC HỆ THỐNG

### Microservices Architecture

```
┌──────────────┐
│ API Gateway  │  :8080
└──────┬───────┘
       │
   ┌───┴────────────────────────┐
   │                            │
┌──▼──────┐  ┌──────────┐  ┌───▼──────┐
│  Auth   │  │   User   │  │ Question │
│  :8081  │  │  :8082   │  │  :8085   │
│ authdb  │  │ userdb   │  │questiondb│
└─────────┘  └──────────┘  └──────────┘

┌──────────┐  ┌──────────┐  ┌─────────┐
│   Exam   │  │  Career  │  │  News   │
│  :8086   │  │  :8084   │  │  :8087  │
│ examdb   │  │ careerdb │  │ newsdb  │
└──────────┘  └──────────┘  └─────────┘

  ┌────────┐   ┌────────┐   ┌────────┐
  │ Eureka │   │ Config │   │  NLP   │
  │  :8761 │   │  :8888 │   │ :5000  │
  └────────┘   └────────┘   └────────┘
```

### ⚡ Phân tách trách nhiệm

**🔐 Auth Service** - Authentication ONLY
- Register, Login, JWT token generation
- Gọi User Service để tạo user data

**👤 User Service** - User Management ONLY  
- CRUD users, ELO system, Role management
- Nhận request từ Auth Service qua `/internal/create`

**📦 Other Services** - Business Logic
- Question, Exam, News, Career
- Mỗi service có database riêng

---

## 🚀 CÀI ĐẶT (3 PHÚT)

### 1. Start Services

```bash
docker-compose up -d
```

### 2. Import Data (160+ records)

```powershell
.\run-init-with-data.ps1
# Chọn: 1 → yes
```

### 3. Verify

```powershell
.\quick-test.ps1
```

**✅ Xong! Hệ thống sẵn sàng**

---

## 📊 API ENDPOINTS

### Tổng quan: **78 endpoints**

| Service | Endpoints | Port | Database |
|---------|-----------|------|----------|
| Auth | 5 | 8081 | authdb |
| User | 9 | 8082 | userdb |
| Career | 5 | 8084 | careerdb |
| Question | 21 | 8085 | questiondb |
| Exam | 23 | 8086 | examdb |
| News | 15 | 8087 | newsdb |

### 🔐 Auth Service

```
POST /auth/register      Register new user
POST /auth/login         Login & get JWT
POST /auth/refresh       Refresh token
GET  /auth/verify        Verify token
```

### 👤 User Service

```
GET  /users                Get all (ADMIN, paginated)
GET  /users/{id}           Get by ID
PUT  /users/{id}           Update
PUT  /users/{id}/role      Update role (ADMIN)
PUT  /users/{id}/status    Update status (ADMIN)
POST /users/elo            Apply ELO change
```

### ❓ Question Service

```
GET  /fields               Get all fields ✨
GET  /topics               Get all topics ✨
GET  /levels               Get all levels ✨
GET  /question-types       Get all types ✨
GET  /questions            Get all questions ✨
POST /questions            Create question
POST /questions/{id}/approve  Approve (ADMIN)
```

### 📝 Exam Service

```
GET  /exams                Get all exams ✨
POST /exams                Create exam
GET  /exams/{id}           Get by ID
GET  /exams/type/{type}    By type (paginated)
POST /exams/{id}/publish   Publish (ADMIN/RECRUITER)
POST /exams/registrations  Register for exam
GET  /exams/results/user/{userId}  User results
```

### 📰 News Service

```
GET  /news                 Get all news ✨
POST /news                 Create news
GET  /news/type/{type}     By type (paginated)
POST /news/{id}/approve    Approve (ADMIN)
POST /recruitments         Create recruitment
GET  /recruitments         Get all recruitments
```

**✨ = Endpoints mới được thêm**

Chi tiết đầy đủ: [API-SPECIFICATION.md](API-SPECIFICATION.md)

---

## 🔐 AUTHENTICATION

### Flow

```
Client                      Auth Service              User Service
  │                              │                         │
  ├─POST /auth/register────────>│                         │
  │                              ├─Hash password          │
  │                              ├─POST /internal/create─>│
  │                              │                    Save to DB
  │                              │<────────user────────────┤
  │                              ├─Generate JWT            │
  │<────{token, user}────────────┤                         │
  │                              │                         │
  ├─POST /auth/login──────────>│                         │
  │                              ├─Verify password         │
  │                              ├─Generate JWT            │
  │<────{token, user}────────────┤                         │
  │                              │                         │
  ├─GET /users/3────────────────────────────────────────>│
  │  (Authorization: Bearer token)                   Query DB
  │<─────────────────────────user────────────────────────┤
```

### Test Accounts

**Password cho tất cả:** `password123`

| Email | Role | ELO | Rank |
|-------|------|-----|------|
| admin@example.com | ADMIN | 0 | NEWBIE |
| recruiter@example.com | RECRUITER | 0 | NEWBIE |
| user@example.com | USER | 1200 | BRONZE |
| developer@example.com | USER | 1500 | SILVER |
| expert@example.com | USER | 2100 | GOLD |

---

## 🧪 TESTING

### 1. Import Postman Collection

**Khuyến nghị: Import từ Swagger**

```
http://localhost:8081/v3/api-docs  (Auth)
http://localhost:8082/v3/api-docs  (User)
http://localhost:8085/v3/api-docs  (Question)
http://localhost:8086/v3/api-docs  (Exam)
http://localhost:8087/v3/api-docs  (News)
```

Xem chi tiết: [POSTMAN-IMPORT-INSTRUCTIONS.md](POSTMAN-IMPORT-INSTRUCTIONS.md)

### 2. Test Scripts

```powershell
# Test authentication flow
.\test-auth-flow.ps1

# Test new endpoints
.\test-new-endpoints.ps1

# Verify database
.\check-database-data.ps1
```

### 3. Test với cURL

```bash
# Login
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'

# Get profile (replace TOKEN)
curl http://localhost:8080/users/3 \
  -H "Authorization: Bearer TOKEN"
```

---

## 🗄️ DATABASE

### 6 Databases với 160+ sample records

**authdb:** 3 roles  
**userdb:** 8 users, 20+ ELO history (passwords BCrypt encrypted)  
**questiondb:** 6 fields, 25+ topics, 15+ approved questions  
**examdb:** 8+ exams, 10+ results, 15+ registrations  
**newsdb:** 8 news, 10 recruitment posts  
**careerdb:** 20+ career preferences

Hướng dẫn: [HUONG-DAN-IMPORT-DU-LIEU.md](HUONG-DAN-IMPORT-DU-LIEU.md)

---

## 🛠️ DEVELOPMENT

### Rebuild Services

```powershell
.\rebuild-services.ps1
```

### View Logs

```powershell
docker-compose logs -f user-service
docker-compose logs -f auth-service
```

### Restart Service

```powershell
docker-compose restart user-service
```

### Reset Database

```powershell
docker-compose down -v
docker-compose up -d
.\run-init-with-data.ps1
```

---

## 🌐 SERVICE URLS

| Service | URL | Swagger |
|---------|-----|---------|
| API Gateway | http://localhost:8080 | - |
| Auth Service | http://localhost:8081 | [Swagger](http://localhost:8081/swagger-ui.html) |
| User Service | http://localhost:8082 | [Swagger](http://localhost:8082/swagger-ui.html) |
| Question Service | http://localhost:8085 | [Swagger](http://localhost:8085/swagger-ui.html) |
| Exam Service | http://localhost:8086 | [Swagger](http://localhost:8086/swagger-ui.html) |
| News Service | http://localhost:8087 | [Swagger](http://localhost:8087/swagger-ui.html) |
| Eureka Dashboard | http://localhost:8761 | - |

---

## 📚 DOCUMENTATION

### Core Files

1. **README.md** (this file) - Main documentation
2. **ARCHITECTURE-CLARIFICATION.md** - Auth/User separation explained
3. **POSTMAN-IMPORT-INSTRUCTIONS.md** - API testing guide
4. **HUONG-DAN-IMPORT-DU-LIEU.md** - Database setup guide
5. **API-SPECIFICATION.md** - Complete API specifications

### Scripts

- `run-init-with-data.ps1` - Import 160+ sample records
- `test-auth-flow.ps1` - Test authentication flow
- `test-new-endpoints.ps1` - Test GET ALL endpoints
- `rebuild-services.ps1` - Rebuild modified services
- `check-database-data.ps1` - Verify database content
- `quick-test.ps1` - Quick health check

---

## 🐛 TROUBLESHOOTING

### Services không start

```powershell
docker-compose logs service-name
docker-compose restart service-name
```

### Không có dữ liệu

```powershell
.\run-init-with-data.ps1  # Option 1 → yes
```

### Authentication fails

```powershell
# Test với existing user
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'
```

### Port conflicts

```powershell
# Check ports
netstat -ano | findstr "8080 8081 8082"

# Stop all
docker-compose down
```

---

## ✅ SYSTEM STATUS

**Architecture:** Clean, no duplication ✅  
**Services:** 9 microservices ✅  
**Databases:** 6 PostgreSQL databases ✅  
**Endpoints:** 78 APIs ✅  
**Security:** JWT + BCrypt ✅  
**Documentation:** Complete ✅  
**Testing:** Scripts + Swagger ✅  

**Status: PRODUCTION READY** 🚀

---

## 📞 SUPPORT

### Documentation
- [Architecture](ARCHITECTURE-CLARIFICATION.md) - System design explained
- [API Testing](POSTMAN-IMPORT-INSTRUCTIONS.md) - Postman guide
- [Database](HUONG-DAN-IMPORT-DU-LIEU.md) - Data import guide
- [API Specs](API-SPECIFICATION.md) - Complete endpoint documentation

### Quick Links
- Swagger UIs: http://localhost:8081/swagger-ui.html (and 8082, 8085, 8086, 8087)
- Eureka Dashboard: http://localhost:8761
- Gateway Health: http://localhost:8080/actuator/health

---

## 🎓 PROJECT STRUCTURE

```
Interview Microservice ABC/
├── auth-service/           Authentication service
├── user-service/           User management service
├── career-service/         Career preference service
├── question-service/       Question bank service
├── exam-service/           Exam management service
├── news-service/           News & recruitment service
├── gateway-service/        API Gateway
├── discovery-service/      Eureka server
├── config-service/         Config server
├── nlp-service/            NLP service (Python)
├── docker-compose.yml      Docker orchestration
├── init-with-data.sql      Database initialization
└── README.md               This file
```

---

## 🚀 QUICK START CHECKLIST

- [ ] Docker Desktop running
- [ ] Run `docker-compose up -d`
- [ ] Run `.\run-init-with-data.ps1` (Option 1)
- [ ] Run `.\quick-test.ps1` to verify
- [ ] Open Swagger UI: http://localhost:8081/swagger-ui.html
- [ ] Test login with `user@example.com / password123`
- [ ] Import Postman collection from Swagger
- [ ] Start developing! 🎉

---

**Last Updated:** 2025-10-09  
**Version:** 3.0 - Clean & Complete  
**License:** MIT  
**Author:** ABC Company
