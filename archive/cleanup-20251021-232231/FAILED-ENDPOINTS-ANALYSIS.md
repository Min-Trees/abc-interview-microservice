# 🔧 6 ENDPOINTS FAILED - PHÂN TÍCH VÀ GIẢI PHÁP

## TÓM TẮT

| # | Endpoint | Method | Status | Vấn đề | Giải pháp |
|---|----------|--------|--------|--------|-----------|
| 1 | `/auth/user-info` | GET | ❌ 400 | Auth-service gọi user-service bị 403 | Fix security config |
| 2 | `/questions/1` | GET | ⚠️ 400 | ID không tồn tại | Dùng ID hợp lệ (ID=2 OK) |
| 3 | `/questions` | POST | ❌ 400 | Thiếu required fields | Thêm userId, fieldId, answer, language |
| 4 | `/exams/1` | GET | ⚠️ 400 | Không có exam nào | Tạo exam trước khi test |
| 5 | `/exams` | POST | ❌ 400 | Sai format array | topics/questionTypes phải là [1,2] không phải "[1]" |
| 6 | `/news/1` | GET | ⚠️ 400 | ID không tồn tại | Dùng ID hợp lệ (ID=2 OK) |

---

## 1️⃣ GET /auth/user-info - CRITICAL ERROR

### Vấn đề
```
GET http://localhost:8080/auth/user-info
Authorization: Bearer <token>

Response: 400 Bad Request
{
  "detail": "403 Forbidden from GET http://user-service:8082/users/1"
}
```

### Nguyên nhân
Auth-service gọi sang user-service để lấy thông tin user, nhưng bị chặn bởi security config.

### Code hiện tại (AuthService.java)
```java
public Mono<UserDto> getUserInfoByToken(String token) {
    Long userId = jwtUtil.getUserIdFromToken(token);
    return webClient.get()
        .uri("http://user-service:8082/users/" + userId)
        .retrieve()
        .bodyToMono(UserDto.class);  // ← BỊ CHẶN 403
}
```

### Giải pháp

#### Option 1: Thêm internal endpoint không cần auth (KHUYẾN NGHỊ)
**File:** `user-service/src/main/java/com/abc/user_service/controller/UserController.java`

```java
// Thêm endpoint mới cho internal calls
@GetMapping("/internal/user/{id}")
public ResponseEntity<UserResponse> getUserInternal(@PathVariable Long id) {
    return ResponseEntity.ok(userService.getUserById(id));
}
```

**File:** `user-service/src/main/java/com/abc/user_service/config/SecurityConfig.java`
```java
@Bean
public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    http
        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/internal/**").permitAll()  // ← CHO PHÉP
            .requestMatchers("/{id}").authenticated()
            // ... other rules
        );
    return http.build();
}
```

**File:** `auth-service/src/main/java/com/auth/service/service/AuthService.java`
```java
public Mono<UserDto> getUserInfoByToken(String token) {
    Long userId = jwtUtil.getUserIdFromToken(token);
    return webClient.get()
        .uri("http://user-service:8082/users/internal/user/" + userId)  // ← ĐỔI URL
        .retrieve()
        .bodyToMono(UserDto.class);
}
```

#### Option 2: Thêm service-to-service token
Tạo một JWT đặc biệt cho inter-service communication (phức tạp hơn).

---

## 2️⃣ GET /questions/1 - FALSE ALARM

### Vấn đề
```
GET http://localhost:8080/questions/1
Response: 400 (nhưng /questions/2 trả về 200)
```

### Nguyên nhân
ID=1 không tồn tại trong database. API hoạt động bình thường.

### Giải pháp
**Không cần sửa code.** Chỉ cần test với ID hợp lệ:

```powershell
# Lấy danh sách questions trước
$questions = Invoke-RestMethod "http://localhost:8080/questions?page=0&size=5"
$firstId = $questions.content[0].id

# Test với ID hợp lệ
Invoke-RestMethod "http://localhost:8080/questions/$firstId"  # ← OK
```

**Update Postman:** Dùng `{{questionId}}` variable từ response của GET all.

---

## 3️⃣ POST /questions - VALIDATION ERROR

### Vấn đề
```json
POST http://localhost:8080/questions
{
  "topicId": 1,
  "levelId": 1,
  "typeId": 1,
  "content": "Test?",
  "createdBy": 1
}

Response: 400 Bad Request
```

### Nguyên nhân
**QuestionRequest** requires nhiều fields hơn:

```java
@Data
public class QuestionRequest {
    @NotNull private Long userId;           // ← THIẾU
    @NotNull private Long topicId;
    @NotNull private Long fieldId;          // ← THIẾU
    @NotNull private Long levelId;
    @NotNull private Long questionTypeId;   // ← SAI TÊN (không phải typeId)
    @NotBlank private String content;
    @NotBlank private String answer;        // ← THIẾU
    @NotBlank private String language;      // ← THIẾU
}
```

### Giải pháp - Request Body Đúng

```json
{
  "userId": 1,
  "topicId": 1,
  "fieldId": 1,
  "levelId": 1,
  "questionTypeId": 1,
  "content": "What is the difference between ArrayList and LinkedList?",
  "answer": "ArrayList uses dynamic array, LinkedList uses doubly-linked list",
  "language": "Vietnamese"
}
```

### Update Postman Collection
```json
{
  "name": "Create Question",
  "request": {
    "method": "POST",
    "url": "{{baseUrl}}/questions",
    "header": [{"key": "Authorization", "value": "Bearer {{token}}"}],
    "body": {
      "mode": "raw",
      "raw": "{\n  \"userId\": 1,\n  \"topicId\": 1,\n  \"fieldId\": 1,\n  \"levelId\": 1,\n  \"questionTypeId\": 1,\n  \"content\": \"What is PowerShell?\",\n  \"answer\": \"A task automation framework\",\n  \"language\": \"Vietnamese\"\n}"
    }
  }
}
```

---

## 4️⃣ GET /exams/1 - FALSE ALARM

### Vấn đề
```
GET http://localhost:8080/exams/1
Response: 400 (database trống, chưa có exam nào)
```

### Nguyên nhân
Không có exam nào trong database.

### Giải pháp
**Không cần sửa code.** Tạo exam trước:

```powershell
# 1. Tạo exam trước
$examBody = @{
    userId = 1
    examType = "VIRTUAL"
    title = "Java Interview"
    position = "Backend Developer"
    topics = @(1, 2)
    questionTypes = @(1)
    questionCount = 10
    duration = 30
    language = "Vietnamese"
} | ConvertTo-Json

$newExam = Invoke-RestMethod -Uri "http://localhost:8080/exams" `
    -Method POST -Body $examBody -ContentType "application/json" `
    -Headers @{"Authorization"="Bearer $token"}

# 2. Test GET với ID vừa tạo
Invoke-RestMethod "http://localhost:8080/exams/$($newExam.id)"  # ← OK
```

---

## 5️⃣ POST /exams - VALIDATION ERROR (CRITICAL)

### Vấn đề
```json
POST http://localhost:8080/exams
{
  "userId": 1,
  "examType": "VIRTUAL",
  "title": "Test",
  "position": "Dev",
  "topics": "[1]",           // ← SAI: String thay vì Array
  "questionTypes": "[1]",    // ← SAI: String thay vì Array
  "questionCount": 10,
  "duration": 30,
  "language": "Vietnamese"
}

Response: 400 Bad Request
```

### Nguyên nhân
**ExamRequest** expects arrays, not strings:

```java
@Data
public class ExamRequest {
    @NotNull private Long userId;
    @NotBlank private String examType;
    @NotBlank private String title;
    private String position;
    @NotEmpty private List<Long> topics;          // ← PHẢI LÀ ARRAY
    @NotEmpty private List<Long> questionTypes;   // ← PHẢI LÀ ARRAY
    @NotNull private Integer questionCount;
    @NotNull private Integer duration;
    @NotBlank private String language;
}
```

### Giải pháp - Request Body Đúng

#### JSON (Postman/API calls)
```json
{
  "userId": 1,
  "examType": "VIRTUAL",
  "title": "Java Backend Interview",
  "position": "Backend Developer",
  "topics": [1, 2, 3],
  "questionTypes": [1, 2],
  "questionCount": 15,
  "duration": 45,
  "language": "Vietnamese"
}
```

#### PowerShell
```powershell
$examBody = @{
    userId = 1
    examType = "VIRTUAL"
    title = "Java Interview"
    position = "Backend"
    topics = @(1, 2)           # ← ARRAY
    questionTypes = @(1)       # ← ARRAY
    questionCount = 10
    duration = 30
    language = "Vietnamese"
} | ConvertTo-Json
```

### Update Postman Collection
```json
{
  "name": "Create Exam",
  "request": {
    "method": "POST",
    "url": "{{baseUrl}}/exams",
    "header": [{"key": "Authorization", "value": "Bearer {{token}}"}],
    "body": {
      "mode": "raw",
      "raw": "{\n  \"userId\": 1,\n  \"examType\": \"VIRTUAL\",\n  \"title\": \"Java Backend Interview\",\n  \"position\": \"Backend Developer\",\n  \"topics\": [1, 2],\n  \"questionTypes\": [1],\n  \"questionCount\": 10,\n  \"duration\": 30,\n  \"language\": \"Vietnamese\"\n}"
    }
  }
}
```

---

## 6️⃣ GET /news/1 - FALSE ALARM

### Vấn đề
```
GET http://localhost:8080/news/1
Response: 400 (nhưng /news/2 trả về 200)
```

### Nguyên nhân
ID=1 không tồn tại. API hoạt động bình thường.

### Giải pháp
**Không cần sửa code.** Test với ID hợp lệ (ID=2).

---

## 📋 CHECKLIST SỬA CHỮA

### Critical (Cần sửa ngay)
- [ ] **#1: Auth user-info** - Thêm `/internal/user/{id}` endpoint
- [ ] **#3: POST questions** - Update Postman với đủ required fields
- [ ] **#5: POST exams** - Sửa topics/questionTypes thành arrays

### Low Priority (Chỉ cần update docs/tests)
- [x] **#2: GET questions/1** - Dùng ID hợp lệ
- [x] **#4: GET exams/1** - Tạo exam trước khi test
- [x] **#6: GET news/1** - Dùng ID hợp lệ

---

## 🚀 HÀNH ĐỘNG TIẾP THEO

### Bước 1: Sửa Auth Service (30 phút)
```bash
1. Thêm /internal/user/{id} vào UserController
2. Update SecurityConfig cho phép /internal/**
3. Update AuthService đổi URL sang /internal/user/{id}
4. Rebuild auth-service và user-service
5. Test lại GET /auth/user-info
```

### Bước 2: Update Postman Collection (10 phút)
```bash
1. Sửa POST /questions - thêm userId, fieldId, answer, language
2. Sửa POST /exams - đổi topics/questionTypes sang arrays
3. Sửa GET /{id} endpoints - dùng variables
4. Export collection mới
```

### Bước 3: Update Test Scripts (10 phút)
```bash
1. Sửa test-comprehensive.ps1 với đúng DTOs
2. Thêm logic lấy IDs hợp lệ trước khi test GET by ID
3. Chạy lại test
4. Xác nhận 100% pass rate
```

---

## ✅ KẾT QUẢ MONG ĐỢI

Sau khi sửa:
```
Total Tests: 52
  Passed: 52 (100%)
  Failed: 0

Success Rate: 100%
```

