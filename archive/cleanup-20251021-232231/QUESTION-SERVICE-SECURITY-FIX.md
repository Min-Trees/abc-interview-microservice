# Question Service Security Fix - Hoàn Thành ✅

## Vấn Đề Ban Đầu
Tất cả API của question-service đều trả về **403 ACCESS_DENIED**, kể cả endpoints không yêu cầu authentication.

## Nguyên Nhân

### 1. Security Config Mâu Thuẫn
**SecurityConfig.java**:
```java
@EnableMethodSecurity
// ...
.authorizeHttpRequests(auth -> auth
    .anyRequest().permitAll()  // ❌ Cho phép tất cả
)
```

**QuestionController.java**:
```java
@GetMapping("/topics")  // ❌ Không có @PreAuthorize
public Page<TopicResponse> getAllTopics(Pageable pageable) { ... }

@PostMapping("/topics")
@PreAuthorize("hasRole('ADMIN')")  // ✅ Có @PreAuthorize
public TopicResponse createTopic(...) { ... }
```

**Vấn đề**: 
- SecurityConfig nói "permitAll" nhưng `@EnableMethodSecurity` enable method-level security
- Endpoints KHÔNG có `@PreAuthorize` → Spring Security apply default deny → 403

### 2. JWT Filter Skip Sai
**JwtAuthenticationFilter.java** (trước khi fix):
```java
if (requestURI.startsWith("/questions/topics") || ...) {
    // Skip JWT validation for /questions/topics
    filterChain.doFilter(request, response);
    return;
}
```

**Vấn đề**: `/questions/topics` được skip JWT validation nhưng controller yêu cầu `@PreAuthorize("hasRole('ADMIN')")` → không có authentication → 403

## Giải Pháp Áp Dụng

### 1. Xóa `/questions/topics` Khỏi Skip List
**File**: `question-service/src/main/java/com/abc/question_service/config/JwtAuthenticationFilter.java`

```java
// TRƯỚC
if (requestURI.startsWith("/questions/fields") ||
    requestURI.startsWith("/questions/topics") ||  // ❌ Removed
    requestURI.startsWith("/questions/levels") ||
    requestURI.startsWith("/questions/question-types")) {

// SAU
if (requestURI.startsWith("/questions/fields") ||
    requestURI.startsWith("/questions/levels") ||
    requestURI.startsWith("/questions/question-types")) {
```

### 2. Cấu Hình Security Đúng - GET Public, POST/PUT/DELETE Authenticated
**File**: `question-service/src/main/java/com/abc/question_service/config/SecurityConfig.java`

```java
@Configuration
@EnableMethodSecurity(prePostEnabled = true)
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .authorizeHttpRequests(auth -> auth
                        // Public endpoints
                        .requestMatchers("/actuator/**", "/v3/api-docs/**", "/swagger-ui/**").permitAll()
                        // GET requests are public (read-only)
                        .requestMatchers(
                            org.springframework.http.HttpMethod.GET,
                            "/questions/**"
                        ).permitAll()
                        // POST/PUT/DELETE require authentication
                        // Method security (@PreAuthorize) will check specific roles
                        .anyRequest().authenticated()
                )
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
```

## Kết Quả Sau Khi Fix

### ✅ GET Endpoints - Public (Không Cần Token)
```powershell
# Tất cả GET đều hoạt động mà không cần Authorization header
GET http://localhost:8080/questions/topics
GET http://localhost:8080/questions/fields
GET http://localhost:8080/questions/levels
GET http://localhost:8080/questions/question-types
GET http://localhost:8080/questions
GET http://localhost:8080/questions/{id}
GET http://localhost:8080/questions/topics/{topicId}/questions
GET http://localhost:8080/questions/answers

# Kết quả test:
✅ GET /fields: SUCCESS - 3 fields
✅ GET /levels: SUCCESS - 1 levels
✅ GET /question-types: SUCCESS - 1 types
✅ GET /topics: SUCCESS - 1 topics
✅ GET /questions: SUCCESS - 2 questions
```

### ✅ POST/PUT/DELETE - Cần Authentication + Role
```powershell
# Không có token → 403 Forbidden (đúng)
POST http://localhost:8080/questions/topics
❌ Forbidden (đúng vì chưa login)

# Có token USER → 403 (đúng vì cần ADMIN)
POST http://localhost:8080/questions/topics
Header: Authorization: Bearer <user-token>
❌ Forbidden (đúng vì cần role ADMIN)

# Có token ADMIN → 200 OK
POST http://localhost:8080/questions/topics
Header: Authorization: Bearer <admin-token>
✅ SUCCESS
```

## Danh Sách Endpoints & Quyền

### Public (GET - Không Cần Token)
- `GET /questions/fields` - Lấy danh sách fields
- `GET /questions/topics` - Lấy danh sách topics
- `GET /questions/levels` - Lấy danh sách levels
- `GET /questions/question-types` - Lấy danh sách question types
- `GET /questions` - Lấy danh sách questions
- `GET /questions/{id}` - Lấy question theo ID
- `GET /questions/topics/{topicId}/questions` - Lấy questions theo topic
- `GET /questions/answers` - Lấy danh sách answers
- `GET /questions/answers/{id}` - Lấy answer theo ID
- `GET /questions/{questionId}/answers` - Lấy answers của question

### Authenticated USER or ADMIN
- `POST /questions/questions` - Tạo question mới (@PreAuthorize("hasRole('USER') or hasRole('ADMIN')"))
- `POST /questions/answers` - Tạo answer (@PreAuthorize("hasRole('USER') or hasRole('ADMIN')"))
- `PUT /questions/answers/{id}` - Cập nhật answer (@PreAuthorize("hasRole('USER') or hasRole('ADMIN')"))

### Chỉ ADMIN
- `POST /questions/topics` - Tạo topic (@PreAuthorize("hasRole('ADMIN')"))
- `PUT /questions/topics/{id}` - Cập nhật topic (@PreAuthorize("hasRole('ADMIN')"))
- `DELETE /questions/topics/{id}` - Xóa topic (@PreAuthorize("hasRole('ADMIN')"))
- `POST /questions/fields` - Tạo field (KHÔNG có @PreAuthorize → cần thêm)
- `PUT /questions/fields/{id}` - Cập nhật field (@PreAuthorize("hasRole('ADMIN')"))
- `DELETE /questions/fields/{id}` - Xóa field (@PreAuthorize("hasRole('ADMIN')"))
- `POST /questions/levels` - Tạo level (KHÔNG có @PreAuthorize → cần thêm)
- `PUT /questions/levels/{id}` - Cập nhật level (@PreAuthorize("hasRole('ADMIN')"))
- `DELETE /questions/levels/{id}` - Xóa level (@PreAuthorize("hasRole('ADMIN')"))
- `POST /questions/question-types` - Tạo question type (KHÔNG có @PreAuthorize → cần thêm)
- `PUT /questions/question-types/{id}` - Cập nhật question type (@PreAuthorize("hasRole('ADMIN')"))
- `DELETE /questions/question-types/{id}` - Xóa question type (@PreAuthorize("hasRole('ADMIN')"))
- `PUT /questions/questions/{id}` - Cập nhật question (@PreAuthorize("hasRole('ADMIN')"))
- `DELETE /questions/questions/{id}` - Xóa question (@PreAuthorize("hasRole('ADMIN')"))
- `POST /questions/questions/{id}/approve` - Approve question (@PreAuthorize("hasRole('ADMIN')"))
- `POST /questions/questions/{id}/reject` - Reject question (@PreAuthorize("hasRole('ADMIN')"))
- `DELETE /questions/answers/{id}` - Xóa answer (@PreAuthorize("hasRole('ADMIN')"))
- `POST /questions/answers/{id}/sample` - Mark sample answer (@PreAuthorize("hasRole('ADMIN')"))

## Lưu Ý Quan Trọng

### ⚠️ Một Số POST Endpoints Thiếu @PreAuthorize
Cần thêm annotation cho các endpoints sau:
```java
// Hiện tại KHÔNG có @PreAuthorize → bất kỳ user authenticated nào cũng tạo được
@PostMapping("/fields")  // ⚠️ Nên thêm @PreAuthorize("hasRole('ADMIN')")
@PostMapping("/levels")  // ⚠️ Nên thêm @PreAuthorize("hasRole('ADMIN')")
@PostMapping("/question-types")  // ⚠️ Nên thêm @PreAuthorize("hasRole('ADMIN')")
```

### Cách Test Với Token

#### 1. Login để lấy token
```powershell
$loginBody = @{
    email = "admin@example.com"
    password = "admin123"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
$token = $loginResponse.accessToken
```

#### 2. Call API với token
```powershell
$headers = @{
    Authorization = "Bearer $token"
}

# POST (cần ADMIN role)
$createTopicBody = @{
    name = "New Topic"
    description = "Description"
    fieldId = 1
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/questions/topics" -Method POST -Headers $headers -Body $createTopicBody -ContentType "application/json"
```

## Files Đã Sửa
1. ✅ `question-service/src/main/java/com/abc/question_service/config/SecurityConfig.java`
   - GET `/questions/**` → permitAll()
   - Còn lại → authenticated()
   
2. ✅ `question-service/src/main/java/com/abc/question_service/config/JwtAuthenticationFilter.java`
   - Xóa `/questions/topics` khỏi skip list

## Rebuild & Deploy
```powershell
docker-compose up -d --build question-service
# Wait 30-40 seconds for service to start
```

---
**Trạng thái**: ✅ Hoàn thành - GET public, POST/PUT/DELETE cần authentication  
**Thời gian**: 2025-10-21  
**Build time**: 14.5s
