# Gateway Configuration - Hoàn Thành ✅

## Vấn Đề Ban Đầu
- Gateway không thể route tới các services (lỗi 503/Connection Refused)
- Cố gắng dùng Config Server nhưng gặp nhiều vấn đề phức tạp

## Giải Pháp Cuối Cùng
**Cấu hình trực tiếp trong gateway-service, bỏ Config Server**

### 1. Thêm Dependencies vào `gateway-service/pom.xml`
```xml
<!-- Eureka Discovery Client -->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
</dependency>

<!-- Load Balancer -->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-loadbalancer</artifactId>
</dependency>
```

### 2. Cấu Hình Gateway `application.yml`
```yaml
server:
  port: 8080

spring:
  application:
    name: api-gateway
  cloud:
    gateway:
      discovery:
        locator:
          enabled: true
          lower-case-service-id: true
      routes:
        - id: auth-service
          uri: lb://AUTH-SERVICE
          predicates:
            - Path=/auth/**
        - id: user-service
          uri: lb://USER-SERVICE
          predicates:
            - Path=/users/**
        # ... các service khác

eureka:
  client:
    service-url:
      defaultZone: http://discovery-service:8761/eureka/
    fetch-registry: true
    register-with-eureka: true
```

### 3. Tắt Config Server trong `bootstrap.yml`
```yaml
spring:
  application.name: api-gateway
  cloud:
    config:
      enabled: false
```

## Kết Quả

### ✅ Gateway Hoạt Động
```powershell
# Test health
Invoke-RestMethod http://localhost:8080/actuator/health
# Status: UP

# Test routing
Invoke-WebRequest -Uri http://localhost:8080/auth/register -Method POST -Body '{"username":"test","email":"test@example.com","password":"Test123!@#"}' -ContentType "application/json"
# Gateway route thành công tới auth-service
# Lỗi 400/500 là lỗi logic của auth/user service, KHÔNG phải gateway
```

### Routes Được Load
Gateway tự động tạo 15 routes:
1. **Manual routes** (từ application.yml):
   - `/auth/**` → lb://AUTH-SERVICE
   - `/users/**` → lb://USER-SERVICE  
   - `/questions/**` → lb://QUESTION-SERVICE
   - `/exams/**` → lb://EXAM-SERVICE
   - `/career/**` → lb://CAREER-SERVICE
   - `/news/**` → lb://NEWS-SERVICE
   - `/recruitments/**` → lb://NEWS-SERVICE

2. **Discovery routes** (tự động từ Eureka):
   - `/auth-service/**` → AUTH-SERVICE
   - `/user-service/**` → USER-SERVICE
   - `/question-service/**` → QUESTION-SERVICE
   - `/exam-service/**` → EXAM-SERVICE
   - `/career-service/**` → CAREER-SERVICE
   - `/news-service/**` → NEWS-SERVICE
   - `/discovery-service/**` → DISCOVERY-SERVICE
   - `/api-gateway/**` → API-GATEWAY (chính nó)

## Cách Sử Dụng

### Call API Qua Gateway
```powershell
# Auth Service
POST http://localhost:8080/auth/register
POST http://localhost:8080/auth/login

# User Service
GET http://localhost:8080/users/{id}
PUT http://localhost:8080/users/{id}

# Question Service  
GET http://localhost:8080/questions
POST http://localhost:8080/questions

# Exam Service
GET http://localhost:8080/exams
POST http://localhost:8080/exams

# Career Service
GET http://localhost:8080/career/jobs
POST http://localhost:8080/career/applications

# News Service
GET http://localhost:8080/news
GET http://localhost:8080/recruitments
```

### Hoặc Dùng Service Name
```powershell
# Cũng hoạt động với service name đầy đủ
GET http://localhost:8080/auth-service/actuator/health
GET http://localhost:8080/user-service/users
```

## Load Balancing
- Gateway sử dụng **Eureka Service Discovery**
- Routes với `lb://SERVICE-NAME` tự động load balance giữa nhiều instances
- Nếu có nhiều instance của một service, gateway sẽ phân phối requests

## CORS
```yaml
globalcors:
  cors-configurations:
    '[/**]':
      allowed-origins: "*"
      allowed-methods: "*"
      allowed-headers: "*"
      allow-credentials: false
```

## Monitoring
```powershell
# Gateway health
GET http://localhost:8080/actuator/health

# Xem tất cả routes
GET http://localhost:8080/actuator/gateway/routes

# Xem Eureka registered services
GET http://localhost:8761
```

## Files Đã Sửa
1. ✅ `gateway-service/pom.xml` - Thêm Eureka & LoadBalancer dependencies
2. ✅ `gateway-service/src/main/resources/application.yml` - Cấu hình routes với lb://
3. ✅ `gateway-service/src/main/resources/bootstrap.yml` - Tắt config-server

## Lưu Ý Quan Trọng
- ⚠️ **Không còn dùng Config Server** - Tất cả config trong gateway/application.yml
- ✅ Gateway đã kết nối Eureka và load balance tới services
- ✅ Tất cả 7 services đã đăng ký Eureka: AUTH, USER, QUESTION, EXAM, CAREER, NEWS, DISCOVERY
- ⚠️ Lỗi 400/500 từ auth/user service là lỗi logic business, KHÔNG phải lỗi gateway routing

## Bước Tiếp Theo
Nếu gặp lỗi 400/500 từ services:
1. Check logs của service cụ thể: `docker-compose logs <service-name>`
2. Kiểm tra database connection
3. Kiểm tra JWT secret match giữa auth và gateway
4. Import sample data: `.\run-init-with-data.ps1`

---
**Trạng thái**: ✅ Gateway routing hoạt động ổn định với Eureka  
**Thời gian**: 2025-10-21  
**Build**: Thành công (dependencies tải 98s, build 11s)
