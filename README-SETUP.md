# Interview Microservice ABC - Quick Setup

## Prerequisites
- Docker Desktop installed and running
- Internet connection

## Quick Start

### 1. Pull all images from Docker Hub
```powershell
.\quick-pull.ps1
```

### 2. Deploy the system
```powershell
.\quick-deploy-prod.ps1
```

### 3. Check system status
```powershell
.\quick-status.ps1
```

## Service URLs

| Service | URL | Description |
|---------|-----|-------------|
| API Gateway | http://localhost:8080/swagger-ui.html | Main API Gateway |
| Auth Service | http://localhost:8081/swagger-ui.html | Authentication |
| User Service | http://localhost:8082/swagger-ui.html | User Management |
| Career Service | http://localhost:8084/swagger-ui.html | Career Management |
| Question Service | http://localhost:8085/swagger-ui.html | Question Management |
| Exam Service | http://localhost:8086/swagger-ui.html | Exam Management |
| News Service | http://localhost:8087/swagger-ui.html | News Management |
| Discovery Service | http://localhost:8761 | Service Discovery |
| Config Service | http://localhost:8888 | Configuration |

## Test Accounts

| Role | Email | Password |
|------|-------|----------|
| USER | test@example.com | password123 |
| RECRUITER | recruiter@example.com | recruiter123 |
| ADMIN | admin2@example.com | admin123 |

## Management Commands

```powershell
# View logs
.\quick-logs.ps1 [service-name]

# Restart service
.\quick-restart.ps1 [service-name]

# Stop all services
.\quick-stop.ps1

# Check status
.\quick-status.ps1
```

## Documentation

- [Installation Guide](INSTALLATION_GUIDE.md)
- [Docker Hub Setup](DOCKER_HUB_SETUP.md)

## Support

If you encounter any issues, please check the troubleshooting section in the installation guide.

---
**Docker Hub Images**: https://hub.docker.com/r/mintreestdmu
