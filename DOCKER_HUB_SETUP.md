# 🐳 Docker Hub Setup Guide - Interview Microservice ABC

## 📋 Mục lục
- [Tổng quan](#tổng-quan)
- [Cấu hình Docker Hub](#cấu-hình-docker-hub)
- [Build và Push Images](#build-và-push-images)
- [Deploy từ Docker Hub](#deploy-từ-docker-hub)
- [Quản lý Images](#quản-lý-images)
- [Troubleshooting](#troubleshooting)

## 🎯 Tổng quan

Hệ thống Interview Microservice ABC được thiết kế để dễ dàng triển khai sử dụng Docker Hub images. Tất cả các microservices đã được đóng gói thành Docker images và lưu trữ trên Docker Hub với username `mintreestdmu`.

### 🏗️ Kiến trúc hệ thống

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   API Gateway   │    │  Auth Service   │    │  User Service   │
│   (Port 8080)   │    │   (Port 8081)   │    │   (Port 8082)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│Career Service   │    │Question Service │    │  Exam Service   │
│  (Port 8084)    │    │  (Port 8085)    │    │  (Port 8086)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ News Service    │    │  NLP Service    │    │Discovery Service│
│  (Port 8087)    │    │  (Port 8088)    │    │  (Port 8761)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔐 Cấu hình Docker Hub

### 1. Đăng ký tài khoản Docker Hub

1. Truy cập: https://hub.docker.com
2. Click "Sign Up" để tạo tài khoản mới
3. Xác thực email của bạn
4. Username hiện tại: `mintreestdmu`

### 2. Đăng nhập Docker Hub

```bash
# Đăng nhập vào Docker Hub
docker login

# Nhập thông tin:
# Username: mintreestdmu
# Password: [password của bạn]
# Email: [email của bạn]
```

### 3. Kiểm tra đăng nhập

```bash
# Kiểm tra thông tin đăng nhập
docker system info | grep Username

# Hoặc kiểm tra bằng cách pull một image
docker pull hello-world
```

## 🚀 Build và Push Images

### Phương pháp 1: Sử dụng Quick Push Script (Khuyến nghị)

```powershell
# Push tất cả services với tag latest
.\quick-push.ps1

# Push với tag cụ thể
.\quick-push.ps1 -Tag v1.0.0

# Push chỉ một service
.\quick-push.ps1 -Service auth-service -Tag v1.0.0

# Push với verbose output
.\quick-push.ps1 -Verbose -NoCache

# Xem help
.\quick-push.ps1 -Help
```

### Phương pháp 2: Manual Build và Push

#### 1. Build từng service

```bash
# Build config-service
docker build -t mintreestdmu/interview-config-service:latest ./config-service

# Build discovery-service
docker build -t mintreestdmu/interview-discovery-service:latest ./discovery-service

# Build gateway-service
docker build -t mintreestdmu/interview-gateway-service:latest ./gateway-service

# Build auth-service
docker build -t mintreestdmu/interview-auth-service:latest ./auth-service

# Build user-service
docker build -t mintreestdmu/interview-user-service:latest ./user-service

# Build career-service
docker build -t mintreestdmu/interview-career-service:latest ./career-service

# Build question-service
docker build -t mintreestdmu/interview-question-service:latest ./question-service

# Build exam-service
docker build -t mintreestdmu/interview-exam-service:latest ./exam-service

# Build news-service
docker build -t mintreestdmu/interview-news-service:latest ./news-service

# Build nlp-service
docker build -t mintreestdmu/interview-nlp-service:latest ./nlp-service
```

#### 2. Tag images

```bash
# Tag với version cụ thể
docker tag mintreestdmu/interview-auth-service:latest mintreestdmu/interview-auth-service:v1.0.0
docker tag mintreestdmu/interview-user-service:latest mintreestdmu/interview-user-service:v1.0.0
# ... (lặp lại cho tất cả services)
```

#### 3. Push images

```bash
# Push tất cả images
docker push mintreestdmu/interview-config-service:latest
docker push mintreestdmu/interview-discovery-service:latest
docker push mintreestdmu/interview-gateway-service:latest
docker push mintreestdmu/interview-auth-service:latest
docker push mintreestdmu/interview-user-service:latest
docker push mintreestdmu/interview-career-service:latest
docker push mintreestdmu/interview-question-service:latest
docker push mintreestdmu/interview-exam-service:latest
docker push mintreestdmu/interview-news-service:latest
docker push mintreestdmu/interview-nlp-service:latest
```

### Phương pháp 3: Batch Script

```bash
# Tạo script batch để build và push tất cả
#!/bin/bash

SERVICES=("config-service" "discovery-service" "gateway-service" "auth-service" "user-service" "career-service" "question-service" "exam-service" "news-service" "nlp-service")
TAG=${1:-latest}

for service in "${SERVICES[@]}"; do
    echo "Building $service..."
    docker build -t mintreestdmu/interview-$service:$TAG ./$service
    
    echo "Pushing $service..."
    docker push mintreestdmu/interview-$service:$TAG
    
    echo "✅ $service completed"
done

echo "🎉 All services built and pushed successfully!"
```

## 🚀 Deploy từ Docker Hub

### Phương pháp 1: Sử dụng Production Deploy Script

```powershell
# Deploy tất cả services từ Docker Hub
.\quick-deploy-prod.ps1

# Deploy với tag cụ thể
.\quick-deploy-prod.ps1 -Tag v1.0.0

# Deploy chỉ một service
.\quick-deploy-prod.ps1 -Service auth-service -Tag v1.0.0

# Deploy với monitoring
.\quick-deploy-prod.ps1 -Monitor

# Xem help
.\quick-deploy-prod.ps1 -Help
```

### Phương pháp 2: Sử dụng Docker Compose

#### 1. Tạo file .env

```bash
# Copy file .env từ template
cp .env.example .env

# Hoặc tạo file .env mới
cat > .env << EOF
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

# Docker Image Tag
IMAGE_TAG=latest
EOF
```

#### 2. Deploy hệ thống

```bash
# Deploy tất cả services
docker-compose -f docker-compose.prod.yml up -d

# Deploy với tag cụ thể
IMAGE_TAG=v1.0.0 docker-compose -f docker-compose.prod.yml up -d

# Xem logs
docker-compose -f docker-compose.prod.yml logs -f

# Dừng hệ thống
docker-compose -f docker-compose.prod.yml down
```

### Phương pháp 3: Deploy từng service riêng lẻ

```bash
# Deploy infrastructure services trước
docker run -d --name interview-postgres -e POSTGRES_PASSWORD=123456 -p 5432:5432 postgres:15-alpine
docker run -d --name interview-redis -p 6379:6379 redis:7-alpine

# Deploy core services
docker run -d --name interview-config-service -p 8888:8888 mintreestdmu/interview-config-service:latest
docker run -d --name interview-discovery-service -p 8761:8761 mintreestdmu/interview-discovery-service:latest

# Deploy microservices
docker run -d --name interview-gateway-service -p 8080:8080 mintreestdmu/interview-gateway-service:latest
docker run -d --name interview-auth-service -p 8081:8081 mintreestdmu/interview-auth-service:latest
# ... (lặp lại cho tất cả services)
```

## 📊 Quản lý Images

### Xem danh sách images

```bash
# Xem images local
docker images | grep mintreestdmu

# Xem images trên Docker Hub
# Truy cập: https://hub.docker.com/r/mintreestdmu
```

### Xóa images cũ

```bash
# Xóa images local
docker rmi mintreestdmu/interview-auth-service:latest

# Xóa tất cả images cũ
docker image prune -f

# Xóa images không sử dụng
docker system prune -f
```

### Backup và Restore

```bash
# Backup image
docker save mintreestdmu/interview-auth-service:latest | gzip > auth-service-backup.tar.gz

# Restore image
gunzip -c auth-service-backup.tar.gz | docker load
```

### Tag Management

```bash
# Tạo tag mới
docker tag mintreestdmu/interview-auth-service:latest mintreestdmu/interview-auth-service:v1.1.0

# Push tag mới
docker push mintreestdmu/interview-auth-service:v1.1.0

# Xóa tag local
docker rmi mintreestdmu/interview-auth-service:v1.1.0
```

## 🔍 Kiểm tra và Monitoring

### Kiểm tra trạng thái services

```bash
# Xem trạng thái containers
docker ps

# Xem logs của service
docker logs interview-auth-service

# Xem logs real-time
docker logs -f interview-auth-service

# Kiểm tra health
curl http://localhost:8081/actuator/health
```

### Monitoring với Docker Stats

```bash
# Xem resource usage
docker stats

# Xem stats của service cụ thể
docker stats interview-auth-service
```

### Log Management

```bash
# Xem logs tất cả services
docker-compose -f docker-compose.prod.yml logs

# Xem logs service cụ thể
docker-compose -f docker-compose.prod.yml logs auth-service

# Xem logs với timestamp
docker-compose -f docker-compose.prod.yml logs -t
```

## 🛠️ Troubleshooting

### Lỗi thường gặp

#### 1. Không thể pull images

```bash
# Kiểm tra đăng nhập
docker login

# Kiểm tra kết nối mạng
ping hub.docker.com

# Thử pull image khác
docker pull hello-world
```

#### 2. Images không tồn tại

```bash
# Kiểm tra images trên Docker Hub
# Truy cập: https://hub.docker.com/r/mintreestdmu

# Kiểm tra tag
docker pull mintreestdmu/interview-auth-service:latest
```

#### 3. Lỗi permission

```bash
# Thêm user vào docker group (Linux)
sudo usermod -aG docker $USER

# Logout và login lại
```

#### 4. Out of disk space

```bash
# Xóa images không sử dụng
docker system prune -f

# Xóa volumes không sử dụng
docker volume prune -f

# Xóa networks không sử dụng
docker network prune -f
```

### Debug Commands

```bash
# Xem thông tin Docker
docker system info

# Xem disk usage
docker system df

# Xem chi tiết container
docker inspect interview-auth-service

# Xem logs với debug level
docker logs --details interview-auth-service
```

## 📚 Tài liệu tham khảo

### Docker Hub
- [Docker Hub Documentation](https://docs.docker.com/docker-hub/)
- [Docker Hub Best Practices](https://docs.docker.com/docker-hub/builds/)
- [Docker Hub Security](https://docs.docker.com/docker-hub/security/)

### Docker Compose
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Compose Environment Variables](https://docs.docker.com/compose/environment-variables/)

### Microservices
- [Microservices Patterns](https://microservices.io/)
- [Spring Cloud Documentation](https://spring.io/projects/spring-cloud)

## 🆘 Hỗ trợ

### Liên hệ
- **Email**: support@example.com
- **GitHub Issues**: [Tạo issue mới](https://github.com/your-repo/issues)
- **Docker Hub**: [mintreestdmu](https://hub.docker.com/r/mintreestdmu)

### Community
- **Discord**: [Join our Discord](https://discord.gg/your-server)
- **Stack Overflow**: Tag `interview-microservice-abc`
- **Reddit**: r/microservices

---

## 🎉 Kết luận

Với Docker Hub setup này, bạn có thể:

1. ✅ **Dễ dàng deploy** hệ thống trên bất kỳ máy nào có Docker
2. ✅ **Quản lý versions** thông qua Docker tags
3. ✅ **Scale horizontally** bằng cách chạy nhiều instances
4. ✅ **Backup và restore** images một cách dễ dàng
5. ✅ **Share** hệ thống với team members

Hãy bắt đầu khám phá và tận dụng sức mạnh của Docker Hub! 🚀




