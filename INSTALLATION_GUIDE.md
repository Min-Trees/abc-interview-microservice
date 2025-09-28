# 🚀 Interview Microservice ABC - Hướng dẫn Cài đặt và Triển khai

## 📋 Mục lục
- [Yêu cầu hệ thống](#yêu-cầu-hệ-thống)
- [Cài đặt Docker](#cài-đặt-docker)
- [Cài đặt Docker Compose](#cài-đặt-docker-compose)
- [Cấu hình Docker Hub](#cấu-hình-docker-hub)
- [Triển khai hệ thống](#triển-khai-hệ-thống)
- [Kiểm tra và sử dụng](#kiểm-tra-và-sử-dụng)
- [Troubleshooting](#troubleshooting)
- [Hỗ trợ](#hỗ-trợ)

## 🖥️ Yêu cầu hệ thống

### Phần cứng tối thiểu
- **RAM**: 8GB (khuyến nghị 16GB)
- **CPU**: 4 cores (khuyến nghị 8 cores)
- **Dung lượng ổ cứng**: 20GB trống
- **Kết nối mạng**: Internet để tải Docker images

### Hệ điều hành hỗ trợ
- ✅ Windows 10/11 (64-bit)
- ✅ macOS 10.15+
- ✅ Ubuntu 18.04+
- ✅ CentOS 7+
- ✅ RHEL 7+

## 🐳 Cài đặt Docker

### Windows

#### Phương pháp 1: Docker Desktop (Khuyến nghị)
1. **Tải Docker Desktop**:
   - Truy cập: https://www.docker.com/products/docker-desktop
   - Tải phiên bản Windows

2. **Cài đặt**:
   - Chạy file `Docker Desktop Installer.exe`
   - Làm theo hướng dẫn cài đặt
   - Khởi động lại máy tính

3. **Kiểm tra cài đặt**:
   ```powershell
   docker --version
   docker-compose --version
   ```

#### Phương pháp 2: PowerShell Script
```powershell
# Chạy PowerShell với quyền Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/docker/docker-install/master/install.ps1'))
```

### macOS

#### Phương pháp 1: Docker Desktop
1. **Tải Docker Desktop**:
   - Truy cập: https://www.docker.com/products/docker-desktop
   - Tải phiên bản macOS

2. **Cài đặt**:
   - Mở file `.dmg` đã tải
   - Kéo Docker vào Applications folder
   - Chạy Docker Desktop từ Applications

#### Phương pháp 2: Homebrew
```bash
# Cài đặt Homebrew (nếu chưa có)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Cài đặt Docker
brew install --cask docker
```

### Linux (Ubuntu/Debian)

```bash
# Cập nhật package list
sudo apt-get update

# Cài đặt dependencies
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Thêm Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Thêm Docker repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Cài đặt Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Thêm user vào docker group
sudo usermod -aG docker $USER

# Khởi động Docker service
sudo systemctl start docker
sudo systemctl enable docker
```

## 🔧 Cài đặt Docker Compose

### Windows/macOS
Docker Compose được cài đặt cùng với Docker Desktop.

### Linux
```bash
# Tải Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Cấp quyền thực thi
sudo chmod +x /usr/local/bin/docker-compose

# Tạo symbolic link
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Kiểm tra cài đặt
docker-compose --version
```

## 🔐 Cấu hình Docker Hub

### 1. Đăng ký tài khoản Docker Hub
- Truy cập: https://hub.docker.com
- Tạo tài khoản miễn phí
- Xác thực email

### 2. Đăng nhập Docker Hub
```bash
docker login
# Nhập username: mintreestdmu
# Nhập password của bạn
```

### 3. Kiểm tra đăng nhập
```bash
docker system info | grep Username
```

## 🚀 Triển khai hệ thống

### Phương pháp 1: Sử dụng Docker Hub Images (Khuyến nghị)

#### 1. Tải source code
```bash
# Clone repository
git clone <repository-url>
cd "Interview Microservice ABC"

# Hoặc tải file ZIP và giải nén
```

#### 2. Tạo file cấu hình
```bash
# Tạo file .env
cp .env.example .env

# Hoặc chạy script tự động tạo
.\quick-build.ps1
```

#### 3. Triển khai hệ thống
```powershell
# Windows PowerShell
.\quick-deploy.ps1

# Linux/macOS
./quick-deploy.sh
```

### Phương pháp 2: Build từ source code

#### 1. Build tất cả services
```powershell
# Windows
.\quick-build.ps1

# Linux/macOS
./quick-build.sh
```

#### 2. Deploy hệ thống
```powershell
# Windows
.\quick-deploy.ps1

# Linux/macOS
./quick-deploy.sh
```

### Phương pháp 3: Manual Docker Compose

#### 1. Tạo file .env
```bash
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

# Email Configuration
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
```

#### 2. Chạy hệ thống
```bash
# Khởi động tất cả services
docker-compose up -d

# Xem logs
docker-compose logs -f

# Dừng hệ thống
docker-compose down
```

## 🔍 Kiểm tra và sử dụng

### 1. Kiểm tra trạng thái hệ thống
```powershell
# Windows
.\quick-status.ps1

# Linux/macOS
./quick-status.sh
```

### 2. Truy cập các services

#### 🌐 API Gateway
- **URL**: http://localhost:8080
- **Swagger UI**: http://localhost:8080/swagger-ui.html

#### 🔐 Authentication Service
- **URL**: http://localhost:8081
- **Swagger UI**: http://localhost:8081/swagger-ui.html

#### 👤 User Service
- **URL**: http://localhost:8082
- **Swagger UI**: http://localhost:8082/swagger-ui.html

#### 🎯 Career Service
- **URL**: http://localhost:8084
- **Swagger UI**: http://localhost:8084/swagger-ui.html

#### ❓ Question Service
- **URL**: http://localhost:8085
- **Swagger UI**: http://localhost:8085/swagger-ui.html

#### 📝 Exam Service
- **URL**: http://localhost:8086
- **Swagger UI**: http://localhost:8086/swagger-ui.html

#### 📰 News Service
- **URL**: http://localhost:8087
- **Swagger UI**: http://localhost:8087/swagger-ui.html

#### 🤖 NLP Service
- **URL**: http://localhost:8088
- **API Docs**: http://localhost:8088/docs

#### 🔍 Service Discovery
- **URL**: http://localhost:8761

#### 🔧 Config Service
- **URL**: http://localhost:8888

### 3. Tài khoản test

| Role | Email | Password |
|------|-------|----------|
| USER | test@example.com | password123 |
| RECRUITER | recruiter@example.com | recruiter123 |
| ADMIN | admin2@example.com | admin123 |

### 4. Các lệnh quản lý

```powershell
# Xem logs của service cụ thể
.\quick-logs.ps1 auth-service

# Restart service
.\quick-restart.ps1 auth-service

# Dừng tất cả services
.\quick-stop.ps1

# Xem trạng thái
.\quick-status.ps1
```

## 🛠️ Troubleshooting

### Lỗi thường gặp

#### 1. Docker không chạy
```bash
# Windows
# Khởi động Docker Desktop từ Start Menu

# Linux
sudo systemctl start docker
sudo systemctl enable docker

# macOS
# Mở Docker Desktop từ Applications
```

#### 2. Port đã được sử dụng
```bash
# Kiểm tra port đang sử dụng
netstat -tulpn | grep :8080

# Dừng process sử dụng port
sudo kill -9 <PID>

# Hoặc thay đổi port trong .env file
```

#### 3. Không thể kết nối database
```bash
# Kiểm tra container postgres
docker ps | grep postgres

# Xem logs postgres
docker logs interview-postgres

# Restart postgres
docker restart interview-postgres
```

#### 4. Memory không đủ
```bash
# Kiểm tra memory usage
docker stats

# Giảm số lượng services chạy đồng thời
# Hoặc tăng memory cho Docker Desktop
```

#### 5. Lỗi build
```bash
# Clean build
.\quick-build.ps1 -Clean -NoCache

# Xem logs chi tiết
.\quick-build.ps1 -Verbose
```

### Logs và Debug

```bash
# Xem logs tất cả services
docker-compose logs

# Xem logs service cụ thể
docker-compose logs auth-service

# Xem logs real-time
docker-compose logs -f

# Xem logs với timestamp
docker-compose logs -t
```

### Performance Tuning

#### 1. Tăng memory cho Docker
- **Windows/macOS**: Docker Desktop Settings > Resources > Memory
- **Linux**: Tăng memory cho container

#### 2. Tối ưu database
```sql
-- Tăng connection pool
-- Trong application.yml của mỗi service
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
```

#### 3. Caching
```yaml
# Redis configuration
spring:
  redis:
    host: redis
    port: 6379
    timeout: 2000ms
    lettuce:
      pool:
        max-active: 8
        max-idle: 8
        min-idle: 0
```

## 📚 Tài liệu tham khảo

### Docker
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Hub](https://hub.docker.com/)

### Spring Boot
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Spring Cloud Documentation](https://spring.io/projects/spring-cloud)

### Microservices
- [Microservices Patterns](https://microservices.io/)
- [Spring Cloud Netflix](https://spring.io/projects/spring-cloud-netflix)

## 🆘 Hỗ trợ

### Liên hệ
- **Email**: support@example.com
- **GitHub Issues**: [Tạo issue mới](https://github.com/your-repo/issues)
- **Documentation**: [Wiki](https://github.com/your-repo/wiki)

### Community
- **Discord**: [Join our Discord](https://discord.gg/your-server)
- **Stack Overflow**: Tag `interview-microservice-abc`
- **Reddit**: r/microservices

### FAQ

**Q: Tôi có thể chạy hệ thống trên máy có 4GB RAM không?**
A: Có thể, nhưng khuyến nghị tắt một số services không cần thiết và tăng swap space.

**Q: Làm sao để thay đổi port của services?**
A: Chỉnh sửa file `.env` và restart hệ thống.

**Q: Tôi có thể deploy lên cloud không?**
A: Có, hệ thống hỗ trợ deploy lên AWS, Azure, GCP, và các cloud provider khác.

**Q: Làm sao để backup database?**
A: Sử dụng `docker exec` để backup PostgreSQL:
```bash
docker exec interview-postgres pg_dump -U postgres postgres > backup.sql
```

---

## 🎉 Chúc mừng!

Bạn đã cài đặt thành công hệ thống Interview Microservice ABC! 

Hãy bắt đầu khám phá các API endpoints thông qua Swagger UI và tạo ra những ứng dụng tuyệt vời! 🚀




