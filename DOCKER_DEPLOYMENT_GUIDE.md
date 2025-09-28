# 🐳 Docker Deployment Guide - Interview Microservice ABC

## 📋 Tổng quan

Hướng dẫn này sẽ giúp bạn triển khai hệ thống Interview Microservice ABC từ Docker Hub một cách nhanh chóng và dễ dàng.

## 🚀 Quick Start

### 1. Yêu cầu hệ thống

- **Docker Desktop** (phiên bản 20.10.0 trở lên)
- **Docker Compose** (phiên bản 2.0.0 trở lên)
- **PowerShell** (Windows) hoặc **Bash** (Linux/Mac)
- **Internet connection** để pull images từ Docker Hub

### 2. Clone repository

```bash
git clone <repository-url>
cd "Interview Microservice ABC"
```

### 3. Deploy từ Docker Hub

```powershell
# Pull tất cả images từ Docker Hub
.\quick-pull.ps1

# Deploy hệ thống với images đã pull
.\quick-deploy-prod.ps1
```

## 📖 Chi tiết các bước

### Bước 1: Kiểm tra môi trường

```powershell
# Kiểm tra Docker đang chạy
docker --version
docker-compose --version

# Kiểm tra trạng thái Docker
docker ps
```

### Bước 2: Pull images từ Docker Hub

```powershell
# Pull tất cả services với tag latest
.\quick-pull.ps1

# Pull với tag cụ thể
.\quick-pull.ps1 -Tag v1.0.0

# Pull service cụ thể
.\quick-pull.ps1 -Service auth-service

# Pull tất cả tags có sẵn
.\quick-pull.ps1 -AllTags

# Xem chi tiết quá trình pull
.\quick-pull.ps1 -Verbose
```

### Bước 3: Deploy hệ thống

```powershell
# Deploy tất cả services
.\quick-deploy-prod.ps1

# Deploy với tag cụ thể
.\quick-deploy-prod.ps1 -Tag v1.0.0

# Deploy service cụ thể
.\quick-deploy-prod.ps1 -Service auth-service

# Deploy với monitoring real-time
.\quick-deploy-prod.ps1 -Monitor

# Deploy với thời gian chờ tùy chỉnh
.\quick-deploy-prod.ps1 -WaitTime 20

# Bỏ qua health check
.\quick-deploy-prod.ps1 -SkipHealthCheck
```

### Bước 4: Kiểm tra trạng thái

```powershell
# Xem trạng thái tất cả services
.\quick-status.ps1

# Xem logs của service cụ thể
.\quick-logs.ps1 auth-service

# Xem logs của tất cả services
.\quick-logs.ps1
```

## 🔧 Cấu hình Environment

File `.env` sẽ được tự động tạo với cấu hình mặc định:

```env
# Database Configuration
POSTGRES_DB=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=123456
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

# Redis Configuration
REDIS_HOST=redis
REDIS_PORT=6379

# JWT Configuration
JWT_SECRET=UCIafMmHwgsJKIgg4xVAL/eOvR3ZXD/ZnYE9AfMaMQg=
JWT_ACCESS_MINUTES=30
JWT_REFRESH_DAYS=7
JWT_ISSUER=http://auth-service:8081

# Email Configuration (Cần cấu hình)
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password

# Service Ports
AUTH_SERVICE_PORT=8081
USER_SERVICE_PORT=8082
CAREER_SERVICE_PORT=8084
QUESTION_SERVICE_PORT=8085
EXAM_SERVICE_PORT=8086
NEWS_SERVICE_PORT=8087
NLP_SERVICE_PORT=8088
GATEWAY_SERVICE_PORT=8080
DISCOVERY_SERVICE_PORT=8761
CONFIG_SERVICE_PORT=8888

# Database Names
AUTH_DB=authdb
USER_DB=userdb
CAREER_DB=careerdb
QUESTION_DB=questiondb
EXAM_DB=examdb
NEWS_DB=newsdb

# Eureka Configuration
EUREKA_DEFAULT_ZONE=http://discovery-service:8761/eureka/

# Config Server
CONFIG_SERVER_URI=http://config-service:8888

# Verification URL
VERIFICATION_URL=http://gateway-service:8080/auth/verify

# Docker Image Tag
IMAGE_TAG=latest
```

## 🌐 Service URLs

Sau khi deploy thành công, các services sẽ có sẵn tại:

| Service | URL | Mô tả |
|---------|-----|-------|
| 🔐 Auth Service | http://localhost:8081/swagger-ui.html | Xác thực và phân quyền |
| 👤 User Service | http://localhost:8082/swagger-ui.html | Quản lý người dùng |
| 🎯 Career Service | http://localhost:8084/swagger-ui.html | Quản lý nghề nghiệp |
| ❓ Question Service | http://localhost:8085/swagger-ui.html | Quản lý câu hỏi |
| 📝 Exam Service | http://localhost:8086/swagger-ui.html | Quản lý bài thi |
| 📰 News Service | http://localhost:8087/swagger-ui.html | Quản lý tin tức |
| 🤖 NLP Service | http://localhost:8088/docs | Xử lý ngôn ngữ tự nhiên |
| 🌐 Gateway Service | http://localhost:8080/swagger-ui.html | API Gateway |
| 🔍 Discovery Service | http://localhost:8761 | Service Discovery |
| 🔧 Config Service | http://localhost:8888 | Configuration Server |

## 👥 Test Accounts

Hệ thống cung cấp các tài khoản test sẵn:

| Role | Email | Password |
|------|-------|----------|
| USER | test@example.com | password123 |
| RECRUITER | recruiter@example.com | recruiter123 |
| ADMIN | admin2@example.com | admin123 |

## 🛠️ Troubleshooting

### Lỗi thường gặp

1. **Docker không chạy**
   ```powershell
   # Khởi động Docker Desktop
   # Hoặc kiểm tra trạng thái
   docker ps
   ```

2. **Không pull được images**
   ```powershell
   # Kiểm tra kết nối internet
   # Kiểm tra Docker Hub username
   docker pull mintreestdmu/interview-auth-service:latest
   ```

3. **Service không khởi động**
   ```powershell
   # Xem logs chi tiết
   .\quick-logs.ps1 auth-service
   
   # Kiểm tra health check
   curl http://localhost:8081/actuator/health
   ```

4. **Database connection lỗi**
   ```powershell
   # Kiểm tra PostgreSQL
   docker logs interview-postgres
   
   # Restart database
   docker restart interview-postgres
   ```

### Commands hữu ích

```powershell
# Xem tất cả containers
docker ps -a

# Xem tất cả images
docker images | findstr mintreestdmu

# Xóa tất cả containers
docker-compose -f docker-compose.prod.yml down

# Xóa tất cả images
docker rmi $(docker images -q mintreestdmu/*)

# Xem logs real-time
docker-compose -f docker-compose.prod.yml logs -f

# Restart service cụ thể
docker-compose -f docker-compose.prod.yml restart auth-service

# Scale service
docker-compose -f docker-compose.prod.yml up -d --scale auth-service=2
```

## 📊 Monitoring

### Real-time Monitoring

```powershell
# Bật monitoring real-time
.\quick-deploy-prod.ps1 -Monitor
```

### Health Checks

```powershell
# Kiểm tra health của tất cả services
.\quick-status.ps1

# Kiểm tra health của service cụ thể
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health
curl http://localhost:8084/actuator/health
curl http://localhost:8085/actuator/health
curl http://localhost:8086/actuator/health
curl http://localhost:8087/actuator/health
curl http://localhost:8088/health
```

### Prometheus & Grafana (Optional)

```powershell
# Deploy với monitoring stack
docker-compose -f docker-compose.prod.yml --profile monitoring up -d

# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000 (admin/admin)
```

## 🔄 Update & Maintenance

### Update services

```powershell
# Pull version mới
.\quick-pull.ps1 -Tag v2.0.0

# Deploy version mới
.\quick-deploy-prod.ps1 -Tag v2.0.0
```

### Backup & Restore

```powershell
# Backup database
docker exec interview-postgres pg_dump -U postgres postgres > backup.sql

# Restore database
docker exec -i interview-postgres psql -U postgres postgres < backup.sql
```

## 📚 Additional Resources

- **Swagger Aggregator**: Mở file `swagger-aggregator.html` trong browser
- **Postman Collection**: Import file `INTERVIEW_APIS.postman_collection.json`
- **API Testing Guide**: Xem file `POSTMAN_TESTING_GUIDE.md`
- **Comprehensive Testing**: Chạy `comprehensive-test.ps1`

## 🆘 Support

Nếu gặp vấn đề, hãy:

1. Kiểm tra logs: `.\quick-logs.ps1`
2. Kiểm tra status: `.\quick-status.ps1`
3. Xem help: `.\quick-deploy-prod.ps1 -Help`
4. Kiểm tra Docker: `docker ps` và `docker logs <container-name>`

---

**Lưu ý**: Hướng dẫn này được thiết kế để triển khai nhanh chóng từ Docker Hub. Để phát triển và build từ source code, hãy sử dụng `quick-build.ps1` và `quick-deploy.ps1`.

