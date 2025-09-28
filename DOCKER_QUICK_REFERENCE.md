# 🚀 Docker Quick Reference - Interview Microservice ABC

## 📋 Quick Commands

### 🐳 Basic Docker Operations

```powershell
# Pull all services from Docker Hub
.\quick-pull.ps1

# Deploy all services
.\quick-deploy-prod.ps1

# Check service status
.\quick-status.ps1

# View service logs
.\quick-logs.ps1

# Stop all services
.\quick-stop.ps1

# Restart all services
.\quick-restart.ps1
```

### 🎯 Service-Specific Operations

```powershell
# Pull specific service
.\quick-pull.ps1 -Service auth-service

# Deploy specific service
.\quick-deploy-prod.ps1 -Service auth-service

# View specific service logs
.\quick-logs.ps1 auth-service
```

### 🏷️ Tag Management

```powershell
# Pull with specific tag
.\quick-pull.ps1 -Tag v1.0.0

# Deploy with specific tag
.\quick-deploy-prod.ps1 -Tag v1.0.0

# Pull all available tags
.\quick-pull.ps1 -AllTags
```

### 🔧 Advanced Options

```powershell
# Deploy with monitoring
.\quick-deploy-prod.ps1 -Monitor

# Deploy with custom wait time
.\quick-deploy-prod.ps1 -WaitTime 20

# Skip health checks
.\quick-deploy-prod.ps1 -SkipHealthCheck

# Verbose output
.\quick-pull.ps1 -Verbose
.\quick-deploy-prod.ps1 -Verbose
```

## 🌐 Service URLs

| Service | URL | Health Check |
|---------|-----|--------------|
| Auth | http://localhost:8081/swagger-ui.html | http://localhost:8081/actuator/health |
| User | http://localhost:8082/swagger-ui.html | http://localhost:8082/actuator/health |
| Career | http://localhost:8084/swagger-ui.html | http://localhost:8084/actuator/health |
| Question | http://localhost:8085/swagger-ui.html | http://localhost:8085/actuator/health |
| Exam | http://localhost:8086/swagger-ui.html | http://localhost:8086/actuator/health |
| News | http://localhost:8087/swagger-ui.html | http://localhost:8087/actuator/health |
| NLP | http://localhost:8088/docs | http://localhost:8088/health |
| Gateway | http://localhost:8080/swagger-ui.html | http://localhost:8080/actuator/health |
| Discovery | http://localhost:8761 | - |
| Config | http://localhost:8888 | - |

## 👥 Test Accounts

| Role | Email | Password |
|------|-------|----------|
| USER | test@example.com | password123 |
| RECRUITER | recruiter@example.com | recruiter123 |
| ADMIN | admin2@example.com | admin123 |

## 🛠️ Troubleshooting Commands

```powershell
# Check Docker status
docker ps
docker images | findstr mintreestdmu

# View container logs
docker logs interview-auth-service
docker logs interview-postgres

# Restart specific container
docker restart interview-auth-service

# Remove all containers
docker-compose -f docker-compose.prod.yml down

# Remove all images
docker rmi $(docker images -q mintreestdmu/*)

# Clean up system
docker system prune -a
```

## 📊 Health Check Commands

```powershell
# Check all services health
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health
curl http://localhost:8084/actuator/health
curl http://localhost:8085/actuator/health
curl http://localhost:8086/actuator/health
curl http://localhost:8087/actuator/health
curl http://localhost:8088/health
curl http://localhost:8080/actuator/health
```

## 🔄 Update Commands

```powershell
# Update to latest version
.\quick-pull.ps1
.\quick-deploy-prod.ps1

# Update to specific version
.\quick-pull.ps1 -Tag v2.0.0
.\quick-deploy-prod.ps1 -Tag v2.0.0

# Update specific service
.\quick-pull.ps1 -Service auth-service
.\quick-deploy-prod.ps1 -Service auth-service
```

## 📱 Additional Resources

- **Swagger Aggregator**: `swagger-aggregator.html`
- **Postman Collection**: `INTERVIEW_APIS.postman_collection.json`
- **API Testing**: `comprehensive-test.ps1`
- **Full Guide**: `DOCKER_DEPLOYMENT_GUIDE.md`

## 🆘 Emergency Commands

```powershell
# Stop everything
.\quick-stop.ps1

# Clean restart
docker-compose -f docker-compose.prod.yml down
.\quick-deploy-prod.ps1

# Reset everything
docker-compose -f docker-compose.prod.yml down -v
docker system prune -a
.\quick-pull.ps1
.\quick-deploy-prod.ps1
```

