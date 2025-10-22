# 🏗️ ARCHITECTURE CLARIFICATION

## ❗ VẤN ĐỀ PHÁT HIỆN

### Trùng lặp nghiêm trọng giữa Auth Service và User Service:

**Auth Service (`/auth`):**
```java
POST /auth/register    → Register user
POST /auth/login       → Login
POST /auth/refresh     → Refresh token
GET  /auth/verify      → Verify token
GET  /auth/users/{id}  → Get user by ID
```

**User Service (`/users`):**
```java
POST /users/register   → Register user (TRÙNG!)
POST /users/login      → Login (TRÙNG!)
GET  /users/verify     → Verify (TRÙNG!)
GET  /users/{id}       → Get user (TRÙNG!)
PUT  /users/{id}       → Update user
DELETE /users/{id}     → Delete user
...và 6 endpoints khác
```

---

## ✅ GIẢI PHÁP: PHÂN TÁCH TRÁCH NHIỆM RÕ RÀNG

### 🔐 Auth Service - CHỈ LÀM AUTHENTICATION

**Mục đích:** Xác thực, cấp token, quản lý session

**Endpoints giữ lại:**
```
POST /auth/register     → Register user mới (gọi sang User Service)
POST /auth/login        → Login và cấp JWT token
POST /auth/refresh      → Refresh access token
GET  /auth/verify       → Verify JWT token
POST /auth/logout       → Logout (nếu cần)
```

**Luồng hoạt động:**
1. User gọi `/auth/register` → Auth Service gọi User Service để tạo user → Trả về token
2. User gọi `/auth/login` → Auth Service verify password → Cấp token
3. User dùng token để gọi các API khác

**KHÔNG LÀM:**
- ❌ CRUD users
- ❌ Get user details
- ❌ Update user info

---

### 👤 User Service - CHỈ LÀM USER MANAGEMENT

**Mục đích:** Quản lý thông tin user, ELO, roles, status

**Endpoints:**
```
# Core CRUD (Protected với JWT từ Auth Service)
GET    /users              → Get all users (ADMIN)
GET    /users/{id}         → Get user by ID
PUT    /users/{id}         → Update user info
DELETE /users/{id}         → Delete user (ADMIN)

# User Management (ADMIN only)
PUT    /users/{id}/role    → Update role
PUT    /users/{id}/status  → Update status
GET    /users/role/{roleId} → Get users by role
GET    /users/status/{status} → Get users by status

# ELO Management
POST   /users/elo          → Apply ELO change

# Internal endpoints (gọi từ Auth Service)
POST   /users/internal/create → Create user (called by Auth Service)
```

**KHÔNG LÀM:**
- ❌ Register (để Auth Service làm)
- ❌ Login (để Auth Service làm)  
- ❌ JWT generation/validation

---

## 🔄 AUTHENTICATION FLOW

```
┌─────────────┐
│   Client    │
│  (Postman)  │
└──────┬──────┘
       │
       │ 1. POST /auth/register
       │    { email, password, ... }
       ▼
┌─────────────────┐
│  API Gateway    │
│  (Port 8080)    │
└────────┬────────┘
         │
         │ 2. Route to Auth Service
         ▼
┌─────────────────────┐         ┌──────────────────┐
│   Auth Service      │         │  User Service    │
│   (Port 8081)       │────────►│  (Port 8082)     │
│                     │ 3. Call │                  │
│  - Hash password    │ /internal│  - Save to DB   │
│  - Generate JWT     │ /create  │  - Return user  │
│  - Return token     │◄────────│                  │
└─────────────────────┘         └──────────────────┘
         │
         │ 4. Return { accessToken, user }
         ▼
┌─────────────┐
│   Client    │
│ (Save token)│
└─────────────┘
```

---

## 🔄 USER PROFILE UPDATE FLOW

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       │ 1. PUT /users/3
       │    Authorization: Bearer <token>
       │    { fullName: "New Name" }
       ▼
┌─────────────────┐
│  API Gateway    │
│  - Verify JWT   │ ← Token validation
└────────┬────────┘
         │
         │ 2. Route to User Service
         ▼
┌──────────────────┐
│  User Service    │
│  - Update DB     │
│  - Return user   │
└──────────────────┘
```

---

## 🗄️ DATABASE SEPARATION

### authdb (Auth Service)
```sql
- roles (id, role_name, description)
```

### userdb (User Service)
```sql
- roles (id, role_name, description)  -- Duplicate for reference
- users (id, role_id, email, password, ...)
- elo_history (id, user_id, action, points, ...)
```

**Lưu ý:** Password hashing vẫn làm ở Auth Service trước khi gửi sang User Service!

---

## 🔧 REFACTORING CẦN LÀM

### 1. ✅ GIỮ NGUYÊN Auth Service
- Endpoints hiện tại đã đúng
- Chỉ cần đảm bảo gọi User Service khi register

### 2. ❌ XÓA khỏi User Service
**Xóa các endpoints trùng lặp:**
```java
// XÓA
@PostMapping("/register")  // Để Auth Service làm
@PostMapping("/login")     // Để Auth Service làm
@GetMapping("/verify")     // Để Auth Service làm
```

**GIỮ LẠI:**
```java
// User CRUD
@GetMapping
@GetMapping("/{id}")
@PutMapping("/{id}")
@DeleteMapping("/{id}")

// User Management
@PutMapping("/{id}/role")
@PutMapping("/{id}/status")
@GetMapping("/role/{roleId}")
@GetMapping("/status/{status}")

// ELO
@PostMapping("/elo")
```

**THÊM MỚI (Internal):**
```java
@PostMapping("/internal/create")  // Called by Auth Service only
```

---

## 📋 API ENDPOINTS - SAU KHI REFACTOR

### Auth Service (`/auth`) - 5 endpoints
```
POST /auth/register     → Register new user
POST /auth/login        → Login
POST /auth/refresh      → Refresh token
GET  /auth/verify       → Verify token
POST /auth/logout       → Logout (optional)
```

### User Service (`/users`) - 9 endpoints
```
# CRUD
GET    /users              → Get all (ADMIN)
GET    /users/{id}         → Get by ID
PUT    /users/{id}         → Update
DELETE /users/{id}         → Delete (ADMIN)

# Management
PUT    /users/{id}/role    → Update role (ADMIN)
PUT    /users/{id}/status  → Update status (ADMIN)
GET    /users/role/{roleId} → By role (ADMIN)
GET    /users/status/{status} → By status (ADMIN)

# ELO
POST   /users/elo          → Apply ELO change
```

**TỔNG: 14 endpoints (giảm từ 18 endpoints)**

---

## ✅ LỢI ÍCH

1. **Rõ ràng hơn:**
   - Auth Service = Authentication only
   - User Service = User data management only

2. **Không trùng lặp:**
   - Mỗi endpoint chỉ ở 1 service
   - Dễ maintain

3. **Scalable:**
   - Auth Service có thể scale riêng
   - User Service có thể scale riêng

4. **Security:**
   - JWT generation tập trung tại Auth Service
   - User Service chỉ verify token qua Gateway

---

## 🚀 IMPLEMENTATION PLAN

### Phase 1: Refactor User Service
1. Xóa `/register`, `/login`, `/verify` endpoints
2. Thêm `/internal/create` endpoint
3. Update documentation

### Phase 2: Update Auth Service
1. Gọi User Service `/internal/create` khi register
2. Test luồng register → login → get profile

### Phase 3: Update Gateway
1. Remove routing cho `/users/register`, `/users/login`
2. Ensure `/auth/*` routes to Auth Service
3. Ensure `/users/*` routes to User Service

### Phase 4: Update Documentation
1. Clear API specification
2. Update Postman collection
3. Update architecture diagrams

---

## 📊 COMPARISON

### Before (Trùng lặp):
```
/auth/register     → Auth Service
/users/register    → User Service (TRÙNG!)

/auth/login        → Auth Service
/users/login       → User Service (TRÙNG!)

Total: 18 endpoints, nhiều confusion
```

### After (Clean):
```
/auth/register     → Auth Service ONLY
/auth/login        → Auth Service ONLY

/users/{id}        → User Service ONLY
/users/elo         → User Service ONLY

Total: 14 endpoints, clear separation
```

---

**Created:** 2025-10-09  
**Purpose:** Clarify architecture & eliminate duplication  
**Impact:** CRITICAL - Affects entire system design  
**Status:** ⚠️ NEEDS REFACTORING




