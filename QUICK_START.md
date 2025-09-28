# 🚀 Quick Start Guide - Interview Microservice ABC

## 📋 Yêu cầu hệ thống
- **Docker Desktop** đã cài đặt và đang chạy
- **Internet** để tải images từ Docker Hub
- **RAM**: Tối thiểu 8GB (khuyến nghị 16GB)

## ⚡ Cài đặt nhanh (3 bước)

### Bước 1: Tải source code
```bash
# Clone repository hoặc tải file ZIP
git clone <repository-url>
cd "Interview Microservice ABC"
```

### Bước 2: Chạy setup tự động
```powershell
# Windows PowerShell
.\quick-setup.ps1

# Hoặc với tag cụ thể
.\quick-setup.ps1 -Tag v1.0.0
```

### Bước 3: Kiểm tra hệ thống
```powershell
# Kiểm tra trạng thái
.\quick-status.ps1

# Xem logs nếu cần
.\quick-logs.ps1 auth-service
```

## 🎯 Các lệnh hữu ích

### Pull images từ Docker Hub
```powershell
# Pull tất cả images
.\quick-pull.ps1

# Pull với tag cụ thể
.\quick-pull.ps1 -Tag v1.0.0

# Pull chỉ một service
.\quick-pull.ps1 -Service auth-service
```

### Deploy hệ thống
```powershell
# Deploy từ Docker Hub images
.\quick-deploy-prod.ps1

# Deploy với tag cụ thể
.\quick-deploy-prod.ps1 -Tag v1.0.0
```

### Quản lý services
```powershell
# Xem trạng thái
.\quick-status.ps1

# Xem logs
.\quick-logs.ps1 [service-name]

# Restart service
.\quick-restart.ps1 [service-name]

# Dừng tất cả
.\quick-stop.ps1
```

## 🌐 Truy cập hệ thống

### API Gateway (Điểm vào chính)
- **URL**: http://localhost:8080
- **Swagger UI**: http://localhost:8080/swagger-ui.html

### Các Microservices
| Service | URL | Mô tả |
|---------|-----|-------|
| 🔐 Auth Service | http://localhost:8081/swagger-ui.html | Xác thực |
| 👤 User Service | http://localhost:8082/swagger-ui.html | Quản lý người dùng |
| 🎯 Career Service | http://localhost:8084/swagger-ui.html | Quản lý nghề nghiệp |
| ❓ Question Service | http://localhost:8085/swagger-ui.html | Quản lý câu hỏi |
| 📝 Exam Service | http://localhost:8086/swagger-ui.html | Quản lý bài thi |
| 📰 News Service | http://localhost:8087/swagger-ui.html | Quản lý tin tức |
| 🔍 Discovery Service | http://localhost:8761 | Service Discovery |
| 🔧 Config Service | http://localhost:8888 | Cấu hình |

## 👥 Tài khoản test

| Vai trò | Email | Mật khẩu |
|---------|-------|----------|
| USER | test@example.com | password123 |
| RECRUITER | recruiter@example.com | recruiter123 |
| ADMIN | admin2@example.com | admin123 |

## 🛠️ Troubleshooting

### Lỗi thường gặp

#### 1. Docker không chạy
```bash
# Khởi động Docker Desktop từ Start Menu
# Hoặc kiểm tra Docker Desktop đang chạy
```

#### 2. Port đã được sử dụng
```bash
# Kiểm tra port đang sử dụng
netstat -tulpn | grep :8080

# Dừng process sử dụng port
# Hoặc thay đổi port trong file .env
```

#### 3. Không thể pull images
```bash
# Kiểm tra kết nối internet
ping hub.docker.com

# Thử pull thủ công
docker pull mintreestdmu/interview-auth-service:latest
```

#### 4. Memory không đủ
```bash
# Kiểm tra memory usage
docker stats

# Tăng memory cho Docker Desktop
# Settings > Resources > Memory
```

### Debug Commands

```bash
# Xem logs tất cả services
docker-compose -f docker-compose.prod.yml logs

# Xem logs service cụ thể
docker-compose -f docker-compose.prod.yml logs auth-service

# Xem trạng thái containers
docker ps

# Xem images đã tải
docker images | findstr mintreestdmu
```

## 📚 Tài liệu chi tiết

- **[Installation Guide](INSTALLATION_GUIDE.md)** - Hướng dẫn cài đặt chi tiết
- **[Docker Hub Setup](DOCKER_HUB_SETUP.md)** - Cấu hình Docker Hub
- **[API Documentation](swagger-aggregator.html)** - Tài liệu API

## 🆘 Hỗ trợ

- **GitHub Issues**: [Tạo issue mới](https://github.com/your-repo/issues)
- **Email**: support@example.com
- **Docker Hub**: [mintreestdmu](https://hub.docker.com/r/mintreestdmu)

---

## 🎉 Chúc mừng!

Bạn đã cài đặt thành công hệ thống Interview Microservice ABC! 

Hãy bắt đầu khám phá các API endpoints thông qua Swagger UI và tạo ra những ứng dụng tuyệt vời! 🚀

### 🔗 Links hữu ích
- **Docker Hub**: https://hub.docker.com/r/mintreestdmu
- **API Gateway**: http://localhost:8080/swagger-ui.html
- **Service Discovery**: http://localhost:8761




