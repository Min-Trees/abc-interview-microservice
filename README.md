# Interview Microservice ABC

A comprehensive microservices-based interview platform built with Spring Boot and Spring Cloud.

## Quick Start

1. Copy environment variables:
```bash
cp environment-variables.txt .env
```

2. Update .env file with your configuration

3. Start services:
```bash
docker-compose up -d
```

4. Access Swagger UI:
- Open `swagger-aggregator.html` in browser
- Or access individual services:
  - Auth Service: http://localhost:8081/swagger-ui.html
  - User Service: http://localhost:8082/swagger-ui.html
  - Career Service: http://localhost:8084/swagger-ui.html
  - Question Service: http://localhost:8085/swagger-ui.html
  - Exam Service: http://localhost:8086/swagger-ui.html
  - News Service: http://localhost:8087/swagger-ui.html
  - NLP Service: http://localhost:8088/swagger-ui.html

## Test Accounts

- **USER**: test@example.com / password123
- **RECRUITER**: recruiter@example.com / recruiter123
- **ADMIN**: admin2@example.com / admin123

## Architecture

- **Gateway Service**: API Gateway (Port 8080)
- **Auth Service**: Authentication & JWT (Port 8081)
- **User Service**: User Management (Port 8082)
- **Career Service**: Career Preferences (Port 8084)
- **Question Service**: Questions & Answers (Port 8085)
- **Exam Service**: Exams & Results (Port 8086)
- **News Service**: News & Recruitment (Port 8087)
- **NLP Service**: Natural Language Processing & Essay Grading (Port 8088)
- **Discovery Service**: Eureka Server (Port 8761)
- **Config Service**: Configuration Server (Port 8888)

## Environment Variables

All configuration is managed through environment variables. See `environment-variables.txt` for available options.
