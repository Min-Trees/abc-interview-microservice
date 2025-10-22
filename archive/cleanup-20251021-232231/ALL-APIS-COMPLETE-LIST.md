# 📋 DANH SÁCH ĐẦY ĐỦ TẤT CẢ API TRONG HỆ THỐNG
## ABC Interview Platform - Complete API Reference

**Tổng số:** 100+ endpoints across 7 services

---

## 1. 🔐 AUTH SERVICE (5 endpoints)

**Base URL:** `http://localhost:8080/auth`

| Method | Endpoint | Auth | Description | Request Body Example |
|--------|----------|:----:|-------------|---------------------|
| POST | `/register` | ❌ | Đăng ký tài khoản mới | `{"email":"user@example.com","password":"pass123","fullName":"John Doe"}` |
| POST | `/login` | ❌ | Đăng nhập | `{"email":"admin@example.com","password":"admin123"}` |
| POST | `/refresh` | ❌ | Refresh access token | `{"refreshToken":"xxx"}` |
| GET | `/verify?token=xxx` | ❌ | Xác thực token | - |
| GET | `/user-info` | ✅ | Lấy thông tin user hiện tại | - |

**⚠️ Known Issues:**
- `/user-info` trả về 403 vì user-service không cho phép gọi internal từ auth-service

---

## 2. 👤 USER SERVICE (15 endpoints)

**Base URL:** `http://localhost:8080/users`

### Public Endpoints
| Method | Endpoint | Auth | Description |
|--------|----------|:----:|-------------|
| GET | `/roles` | ❌ | Lấy danh sách tất cả roles |
| GET | `/check-email/{email}` | ❌ | Kiểm tra email đã tồn tại |

### Internal Endpoints (dùng cho inter-service communication)
| Method | Endpoint | Auth | Description | Request Body |
|--------|----------|:----:|-------------|--------------|
| POST | `/internal/create` | ❌ | Tạo user (internal) | `{"email":"...","password":"...","fullName":"...","roleId":1}` |
| GET | `/by-email/{email}` | ❌ | Lấy user by email (internal) | - |
| POST | `/validate-password` | ❌ | Validate password (internal) | `{"email":"...","password":"..."}` |
| POST | `/verify-token` | ❌ | Verify JWT token (internal) | `{"token":"..."}` |

### Protected Endpoints
| Method | Endpoint | Auth | Roles | Description | Request Body |
|--------|----------|:----:|-------|-------------|--------------|
| GET | `/{id}` | ✅ | ALL | Lấy user by ID | - |
| PUT | `/{id}` | ✅ | ADMIN | Cập nhật user | `{"fullName":"...","phone":"..."}` |
| DELETE | `/{id}` | ✅ | ADMIN | Xóa user | - |
| PUT | `/{id}/role` | ✅ | ADMIN | Đổi role | `{"roleId":2}` |
| PUT | `/{id}/status` | ✅ | ADMIN | Đổi status | `{"status":"ACTIVE"}` |
| POST | `/elo` | ✅ | USER/ADMIN | Apply ELO rating | `{"userId":1,"eloChange":10}` |
| GET | `` | ✅ | ADMIN | List users (paginated) | - |
| GET | `/role/{roleId}` | ✅ | ADMIN | List users by role | - |
| GET | `/status/{status}` | ✅ | ADMIN | List users by status | - |

---

## 3. ❓ QUESTION SERVICE (43 endpoints)

**Base URL:** `http://localhost:8080/questions`

### A. Fields Management (5 endpoints)
| Method | Endpoint | Auth | Roles | Description | Request Body |
|--------|----------|:----:|-------|-------------|--------------|
| POST | `/fields` | ✅ | ADMIN | Tạo field mới | `{"name":"Mobile Development","description":"..."}` |
| GET | `/fields` | ❌ | - | List tất cả fields (paginated) | - |
| GET | `/fields/{id}` | ❌ | - | Lấy field by ID | - |
| PUT | `/fields/{id}` | ✅ | ADMIN | Cập nhật field | `{"name":"...","description":"..."}` |
| DELETE | `/fields/{id}` | ✅ | ADMIN | Xóa field | - |

### B. Topics Management (5 endpoints)
| Method | Endpoint | Auth | Roles | Description | Request Body |
|--------|----------|:----:|-------|-------------|--------------|
| POST | `/topics` | ✅ | ADMIN | Tạo topic mới | `{"name":"Flutter","description":"...","fieldId":1}` |
| GET | `/topics` | ❌ | - | List tất cả topics | - |
| GET | `/topics/{id}` | ❌ | - | Lấy topic by ID | - |
| PUT | `/topics/{id}` | ✅ | ADMIN | Cập nhật topic | `{"name":"...","description":"...","fieldId":1}` |
| DELETE | `/topics/{id}` | ✅ | ADMIN | Xóa topic | - |

### C. Levels Management (5 endpoints)
| Method | Endpoint | Auth | Roles | Description | Request Body |
|--------|----------|:----:|-------|-------------|--------------|
| POST | `/levels` | ✅ | ADMIN | Tạo level mới | `{"name":"Expert","description":"..."}` |
| GET | `/levels` | ❌ | - | List tất cả levels | - |
| GET | `/levels/{id}` | ❌ | - | Lấy level by ID | - |
| PUT | `/levels/{id}` | ✅ | ADMIN | Cập nhật level | `{"name":"...","description":"..."}` |
| DELETE | `/levels/{id}` | ✅ | ADMIN | Xóa level | - |

### D. Question Types Management (5 endpoints)
| Method | Endpoint | Auth | Roles | Description | Request Body |
|--------|----------|:----:|-------|-------------|--------------|
| POST | `/question-types` | ✅ | ADMIN | Tạo question type | `{"name":"Coding","description":"..."}` |
| GET | `/question-types` | ❌ | - | List tất cả types | - |
| GET | `/question-types/{id}` | ❌ | - | Lấy type by ID | - |
| PUT | `/question-types/{id}` | ✅ | ADMIN | Cập nhật type | `{"name":"...","description":"..."}` |
| DELETE | `/question-types/{id}` | ✅ | ADMIN | Xóa type | - |

### E. Questions Management (8 endpoints)
| Method | Endpoint | Auth | Roles | Description | Request Body |
|--------|----------|:----:|-------|-------------|--------------|
| POST | `` | ✅ | USER/ADMIN | Tạo câu hỏi mới | `{"userId":1,"topicId":1,"fieldId":1,"levelId":1,"questionTypeId":1,"content":"...","answer":"...","language":"Vietnamese"}` |
| GET | `` | ❌ | - | List tất cả questions | - |
| GET | `/{id}` | ❌ | - | Lấy question by ID | - |
| PUT | `/{id}` | ✅ | ADMIN | Cập nhật question | Same as POST |
| DELETE | `/{id}` | ✅ | ADMIN | Xóa question | - |
| POST | `/{id}/approve` | ✅ | ADMIN | Duyệt câu hỏi | Query: `?adminId=1` |
| POST | `/{id}/reject` | ✅ | ADMIN | Từ chối câu hỏi | Query: `?adminId=1` |
| GET | `/topics/{topicId}/questions` | ❌ | - | List questions by topic | - |

### F. Answers Management (7 endpoints)
| Method | Endpoint | Auth | Roles | Description | Request Body |
|--------|----------|:----:|-------|-------------|--------------|
| POST | `/answers` | ✅ | USER/ADMIN | Tạo answer mới | `{"questionId":1,"userId":1,"content":"...","language":"Vietnamese"}` |
| GET | `/answers` | ❌ | - | List tất cả answers | - |
| GET | `/answers/{id}` | ❌ | - | Lấy answer by ID | - |
| PUT | `/answers/{id}` | ✅ | USER/ADMIN | Cập nhật answer | Same as POST |