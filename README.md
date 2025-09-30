# Đặc Tả Hệ Thống Interview Microservice ABC

## 📋 Tổng Quan Hệ Thống

**Interview Microservice ABC** là một nền tảng phỏng vấn trực tuyến được xây dựng theo kiến trúc microservice, sử dụng Spring Boot và Spring Cloud. Hệ thống cung cấp các chức năng quản lý người dùng, tạo câu hỏi, tổ chức thi, và xử lý ngôn ngữ tự nhiên cho việc chấm điểm tự động.

### 🎯 Mục Tiêu Hệ Thống
- Cung cấp nền tảng phỏng vấn trực tuyến toàn diện
- Hỗ trợ đa vai trò: Sinh viên, Nhà tuyển dụng, Quản trị viên
- Tích hợp AI/ML cho chấm điểm tự động
- Đảm bảo khả năng mở rộng và bảo trì cao

---

## 🏗️ Kiến Trúc Tổng Thể

### Kiến Trúc Microservice
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Client Apps   │    │   Web Browser   │    │   Mobile Apps   │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────▼─────────────┐
                    │     API Gateway           │
                    │   (Spring Cloud Gateway)  │
                    └─────────────┬─────────────┘
                                  │
        ┌─────────────────────────┼─────────────────────────┐
        │                         │                         │
┌───────▼────────┐    ┌──────────▼──────────┐    ┌─────────▼─────────┐
│  Auth Service  │    │   User Service      │    │  Career Service    │
│   (Port 8081)  │    │   (Port 8082)       │    │   (Port 8084)     │
└────────────────┘    └─────────────────────┘    └───────────────────┘
        │                         │                         │
┌───────▼────────┐    ┌──────────▼──────────┐    ┌─────────▼─────────┐
│Question Service│    │   Exam Service      │    │   News Service     │
│  (Port 8085)   │    │   (Port 8086)       │    │   (Port 8087)     │
└────────────────┘    └─────────────────────┘    └───────────────────┘
        │                         │                         │
        └─────────────────────────┼─────────────────────────┘
                                  │
                    ┌─────────────▼─────────────┐
                    │     NLP Service           │
                    │   (Python FastAPI)        │
                    │     (Port 8088)           │
                    └───────────────────────────┘
                                  │
        ┌─────────────────────────┼─────────────────────────┐
        │                         │                         │
┌───────▼────────┐    ┌──────────▼──────────┐    ┌─────────▼─────────┐
│Discovery Service│    │  Config Service     │    │   PostgreSQL      │
│  (Port 8761)   │    │   (Port 8888)       │    │   (Port 5432)     │
└────────────────┘    └─────────────────────┘    └───────────────────┘
        │                         │                         │
        └─────────────────────────┼─────────────────────────┘
                                  │
                    ┌─────────────▼─────────────┐
                    │       Redis Cache         │
                    │       (Port 6379)         │
                    └───────────────────────────┘
```

---

## 🛠️ Công Nghệ Sử Dụng

### Backend Services (Java/Spring)
- **Spring Boot 3.5.5** - Framework chính
- **Spring Cloud 2025.0.0** - Microservice ecosystem
- **Spring Security** - Authentication & Authorization
- **Spring Data JPA** - ORM cho database
- **Spring WebFlux** - Reactive programming
- **Eureka Server** - Service Discovery
- **Spring Cloud Gateway** - API Gateway
- **Spring Cloud Config** - Configuration Management

### Database & Caching
- **PostgreSQL 15** - Primary database
- **Redis 7** - Caching và session management

### AI/ML Service (Python)
- **FastAPI 0.104.1** - Web framework
- **PyTorch 2.1.1** - Deep learning
- **Transformers 4.35.2** - NLP models
- **Sentence-Transformers 2.2.2** - Text embeddings
- **Scikit-learn 1.3.2** - Machine learning
- **NLTK 3.8.1** - Natural language processing
- **SpaCy 3.7.2** - Advanced NLP

### Containerization & Orchestration
- **Docker** - Containerization
- **Docker Compose** - Multi-container orchestration
- **Docker Hub** - Image registry

### Monitoring & Observability
- **Prometheus** - Metrics collection
- **Grafana** - Visualization
- **Spring Actuator** - Health checks

### Development Tools
- **Maven** - Build tool
- **Lombok** - Code generation
- **Swagger/OpenAPI** - API documentation
- **JWT** - Token-based authentication

---

## 🔧 Chi Tiết Các Service

### 1. 🔐 Auth Service (Port 8081)
**Chức năng chính:**
- Xác thực người dùng (Login/Register)
- Quản lý JWT tokens (Access & Refresh)
- Xác thực email
- Quản lý roles và permissions

**Công nghệ:**
- Spring Boot WebFlux
- Spring Security
- JWT (jjwt)
- Spring Mail
- PostgreSQL

**API Endpoints:**
- `POST /auth/register` - Đăng ký tài khoản
- `POST /auth/login` - Đăng nhập
- `POST /auth/refresh` - Làm mới token
- `GET /auth/verify` - Xác thực email
- `POST /auth/logout` - Đăng xuất

### 2. 👤 User Service (Port 8082)
**Chức năng chính:**
- Quản lý thông tin người dùng
- Hệ thống ELO rating
- Quản lý profile và preferences

**Công nghệ:**
- Spring Boot WebFlux
- Spring Data JPA
- PostgreSQL

**API Endpoints:**
- `GET /users/profile` - Lấy thông tin profile
- `PUT /users/profile` - Cập nhật profile
- `GET /users/elo-history` - Lịch sử ELO
- `GET /users/ranking` - Bảng xếp hạng

### 3. 🎯 Career Service (Port 8084)
**Chức năng chính:**
- Quản lý sở thích nghề nghiệp
- Phân loại theo lĩnh vực và chủ đề
- Gợi ý nghề nghiệp

**Công nghệ:**
- Spring Boot WebFlux
- Spring Data JPA
- PostgreSQL

**API Endpoints:**
- `GET /careers/preferences` - Lấy sở thích nghề nghiệp
- `POST /careers/preferences` - Cập nhật sở thích
- `GET /careers/fields` - Danh sách lĩnh vực
- `GET /careers/topics` - Danh sách chủ đề

### 4. ❓ Question Service (Port 8085)
**Chức năng chính:**
- Quản lý câu hỏi và câu trả lời
- Phân loại theo lĩnh vực, chủ đề, mức độ
- Hệ thống vote và đánh giá
- Tích hợp AI để tính similarity score

**Công nghệ:**
- Spring Boot WebFlux
- Spring Data JPA
- PostgreSQL

**API Endpoints:**
- `GET /questions` - Danh sách câu hỏi
- `POST /questions` - Tạo câu hỏi mới
- `PUT /questions/{id}` - Cập nhật câu hỏi
- `POST /questions/{id}/answers` - Thêm câu trả lời
- `POST /questions/{id}/vote` - Vote câu hỏi

### 5. 📝 Exam Service (Port 8086)
**Chức năng chính:**
- Tạo và quản lý bài thi
- Đăng ký thi
- Chấm điểm và đánh giá kết quả
- Quản lý lịch thi

**Công nghệ:**
- Spring Boot WebFlux
- Spring Data JPA
- PostgreSQL

**API Endpoints:**
- `GET /exams` - Danh sách bài thi
- `POST /exams` - Tạo bài thi mới
- `POST /exams/{id}/register` - Đăng ký thi
- `POST /exams/{id}/submit` - Nộp bài
- `GET /exams/{id}/results` - Kết quả thi

### 6. 📰 News Service (Port 8087)
**Chức năng chính:**
- Quản lý tin tức và thông báo
- Đăng tin tuyển dụng
- Phân loại theo lĩnh vực
- Hệ thống vote và tương tác

**Công nghệ:**
- Spring Boot WebFlux
- Spring Data JPA
- PostgreSQL

**API Endpoints:**
- `GET /news` - Danh sách tin tức
- `POST /news` - Tạo tin mới
- `GET /news/recruitment` - Tin tuyển dụng
- `POST /news/{id}/vote` - Vote tin tức

### 7. 🤖 NLP Service (Port 8088)
**Chức năng chính:**
- Chấm điểm tự động bài luận
- Tính toán similarity score
- Phân tích ngôn ngữ tự nhiên
- Tích hợp AI/ML models

**Công nghệ:**
- FastAPI
- PyTorch
- Transformers
- Sentence-Transformers
- Scikit-learn
- NLTK, SpaCy

**API Endpoints:**
- `POST /nlp/grade-essay` - Chấm điểm bài luận
- `POST /nlp/calculate-similarity` - Tính similarity
- `POST /nlp/analyze-text` - Phân tích văn bản
- `GET /nlp/health` - Health check

### 8. 🌐 Gateway Service (Port 8080)
**Chức năng chính:**
- API Gateway cho toàn bộ hệ thống
- Load balancing
- Rate limiting
- Authentication routing
- CORS handling

**Công nghệ:**
- Spring Cloud Gateway
- Redis (cho caching)
- JWT validation

### 9. 🔍 Discovery Service (Port 8761)
**Chức năng chính:**
- Service discovery và registration
- Health monitoring
- Load balancing support

**Công nghệ:**
- Eureka Server
- Spring Cloud Netflix

### 10. ⚙️ Config Service (Port 8888)
**Chức năng chính:**
- Centralized configuration management
- Environment-specific configs
- Dynamic configuration updates

**Công nghệ:**
- Spring Cloud Config Server
- Git-based configuration

---

## 🐳 Triển Khai Docker

### Cấu Trúc Docker

#### 1. Docker Compose Development (`docker-compose.yml`)
```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: postgres
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: 123456
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  # Các service được build từ source code
  config-service:
    build: ./config-service
    ports:
      - "8888:8888"
    depends_on:
      - postgres

  # ... các service khác
```

#### 2. Docker Compose Production (`docker-compose.prod.yml`)
```yaml
version: '3.8'
services:
  # Sử dụng images từ Docker Hub
  config-service:
    image: mintreestdmu/interview-config-service:latest
    ports:
      - "8888:8888"
    environment:
      SPRING_PROFILES_ACTIVE: native

  # ... các service khác
```

### Dockerfile Template
```dockerfile
# Multi-stage build cho Java services
FROM openjdk:17-jdk-slim as builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN ./mvnw clean package -DskipTests

FROM openjdk:17-jre-slim
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Triển Khai Tự Động

#### Script Triển Khai Production (`quick-deploy-prod.ps1`)
```powershell
# Các tính năng chính:
- Pull images từ Docker Hub
- Deploy theo thứ tự dependency
- Health checks tự động
- Monitoring real-time
- Error handling và retry logic
- Environment configuration
```

**Thứ tự triển khai:**
1. **Infrastructure**: PostgreSQL, Redis
2. **Core Services**: Config Service, Discovery Service
3. **Gateway**: API Gateway
4. **Microservices**: Auth, User, Career, Question, Exam, News, NLP

---

## 🔄 Luồng Hoạt Động Hệ Thống

### 1. Luồng Đăng Ký/Đăng Nhập
```
1. Client → Gateway Service
2. Gateway → Auth Service
3. Auth Service → PostgreSQL (lưu user)
4. Auth Service → Mail Service (gửi verification)
5. Auth Service → Gateway (trả JWT token)
6. Gateway → Client
```

### 2. Luồng Tạo Câu Hỏi
```
1. Client → Gateway Service (với JWT)
2. Gateway → Auth Service (validate JWT)
3. Gateway → Question Service
4. Question Service → PostgreSQL (lưu question)
5. Question Service → NLP Service (tính similarity)
6. NLP Service → Question Service (trả similarity score)
7. Question Service → Gateway (trả response)
8. Gateway → Client
```

### 3. Luồng Thi Trực Tuyến
```
1. Client → Gateway Service (với JWT)
2. Gateway → Auth Service (validate JWT)
3. Gateway → Exam Service
4. Exam Service → Question Service (lấy questions)
5. Question Service → PostgreSQL (query questions)
6. Question Service → Exam Service (trả questions)
7. Exam Service → Gateway (trả exam)
8. Gateway → Client

# Khi submit bài:
1. Client → Gateway Service (submit answers)
2. Gateway → Exam Service
3. Exam Service → NLP Service (chấm điểm)
4. NLP Service → Exam Service (trả scores)
5. Exam Service → PostgreSQL (lưu results)
6. Exam Service → User Service (cập nhật ELO)
7. Exam Service → Gateway (trả results)
8. Gateway → Client
```

### 4. Luồng Chấm Điểm AI
```
1. Exam Service → NLP Service (gửi essay + sample answer)
2. NLP Service → AI Models (tính similarity)
3. AI Models → NLP Service (trả similarity score)
4. NLP Service → Exam Service (trả score)
5. Exam Service → PostgreSQL (lưu score)
```

---

## 🗄️ Cơ Sở Dữ Liệu

### Cấu Trúc Database
- **authdb**: Quản lý authentication và roles
- **userdb**: Thông tin người dùng và ELO system
- **careerdb**: Sở thích nghề nghiệp
- **questiondb**: Câu hỏi, câu trả lời, fields, topics
- **examdb**: Bài thi, kết quả, đăng ký
- **newsdb**: Tin tức và tuyển dụng

### Các Bảng Chính
```sql
-- Auth Service
roles (id, role_name, description)
users (id, role_id, email, password, ...)

-- User Service  
users (id, role_id, email, full_name, elo_score, ...)
elo_history (id, user_id, action, points, ...)

-- Question Service
fields (id, field_name, description)
topics (id, field_id, topic_name, ...)
questions (id, user_id, topic_id, question_content, ...)
answers (id, question_id, answer_content, ...)

-- Exam Service
exams (id, user_id, title, duration, status, ...)
results (id, exam_id, user_id, score, ...)
user_answers (id, exam_id, question_id, answer_content, ...)

-- News Service
news (id, user_id, title, content, news_type, ...)
```

---

## 🔒 Bảo Mật

### Authentication & Authorization
- **JWT Tokens**: Access token (30 phút) + Refresh token (7 ngày)
- **Role-based Access Control**: USER, RECRUITER, ADMIN
- **Password Hashing**: BCrypt
- **Email Verification**: Required cho registration

### API Security
- **CORS**: Configured cho cross-origin requests
- **Rate Limiting**: Implemented ở Gateway level
- **Input Validation**: Spring Validation annotations
- **SQL Injection Prevention**: JPA/Hibernate parameterized queries

### Network Security
- **Internal Communication**: Services communicate qua internal network
- **External Access**: Chỉ Gateway Service expose ra ngoài
- **Health Checks**: Tất cả services có health endpoints

---

## 📊 Monitoring & Observability

### Health Checks
- **Spring Actuator**: `/actuator/health` cho tất cả services
- **Docker Health Checks**: Built-in container health monitoring
- **Service Discovery**: Eureka monitoring

### Metrics & Logging
- **Prometheus**: Metrics collection
- **Grafana**: Visualization dashboards
- **Application Logs**: Structured logging với timestamps

### Performance Monitoring
- **Response Times**: Tracked qua Gateway
- **Database Performance**: PostgreSQL query monitoring
- **Cache Hit Rates**: Redis performance metrics

---

## 🚀 Triển Khai và Vận Hành

### Development Environment
```bash
# Clone repository
git clone <repository-url>
cd interview-microservice-abc

# Copy environment file
cp environment-variables.txt .env

# Start services
docker-compose up -d

# Check status
docker-compose ps
```

### Production Deployment
```bash
# Deploy với production images
.\quick-deploy-prod.ps1

# Deploy specific service
.\quick-deploy-prod.ps1 -Service auth-service

# Deploy với custom tag
.\quick-deploy-prod.ps1 -Tag v1.0.0

# Monitor real-time
.\quick-deploy-prod.ps1 -Monitor
```

### Scaling
- **Horizontal Scaling**: Deploy multiple instances của services
- **Load Balancing**: Eureka + Gateway load balancing
- **Database Scaling**: Read replicas cho PostgreSQL
- **Cache Scaling**: Redis cluster mode

---

## 🔧 Maintenance & Troubleshooting

### Common Commands
```bash
# Check service status
.\quick-status.ps1

# View logs
.\quick-logs.ps1 [service-name]

# Restart service
.\quick-restart.ps1 [service-name]

# Stop all services
.\quick-stop.ps1

# Update specific service
.\quick-deploy-prod.ps1 -Service [service-name] -Tag [new-tag]
```

### Troubleshooting Guide
1. **Service không start**: Check logs và dependencies
2. **Database connection issues**: Verify PostgreSQL status
3. **JWT validation errors**: Check JWT_SECRET configuration
4. **NLP Service errors**: Verify Python dependencies và models

---

## 📈 Roadmap & Future Enhancements

### Planned Features
- **Real-time Notifications**: WebSocket integration
- **Advanced Analytics**: Detailed performance metrics
- **Mobile App**: React Native mobile application
- **Advanced AI**: More sophisticated NLP models
- **Multi-language Support**: Internationalization
- **Video Interview**: WebRTC integration

### Technical Improvements
- **Kubernetes Deployment**: Container orchestration
- **Service Mesh**: Istio integration
- **Advanced Monitoring**: Jaeger tracing
- **API Versioning**: Backward compatibility
- **Event Sourcing**: CQRS pattern implementation

---

## 📞 Support & Contact

### Documentation
- **API Documentation**: Swagger UI tại mỗi service
- **System Architecture**: Chi tiết trong file này
- **Deployment Guide**: `DOCKER_DEPLOYMENT_GUIDE.md`
- **Testing Guide**: `TESTING_GUIDE.md`

### Test Accounts
- **USER**: test@example.com / password123
- **RECRUITER**: recruiter@example.com / recruiter123  
- **ADMIN**: admin2@example.com / admin123

### Service URLs
- **Gateway**: http://localhost:8080
- **Discovery**: http://localhost:8761
- **Config**: http://localhost:8888
- **Swagger Aggregator**: `swagger-aggregator.html`

---

*Tài liệu này được cập nhật lần cuối: [Ngày hiện tại]*
*Phiên bản hệ thống: 2.0.0*
