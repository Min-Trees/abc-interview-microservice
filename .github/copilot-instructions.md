## Quick orientation for AI coding agents

This repository is a multi-service Spring Boot + FastAPI system for an interview platform. The goal of this file is to capture the minimal, accurate knowledge an AI agent needs to be immediately productive: architecture, important files, developer workflows, notable conventions, and concrete examples.

1) Big-picture architecture
- Microservices behind an API Gateway. Main components (directories): `gateway-service/`, `auth-service/`, `user-service/`, `question-service/`, `exam-service/`, `career-service/`, `news-service/`, `nlp-service/` (Python FastAPI). Each service owns its own database and generally one Spring Boot app per directory.
- Centralized configuration is provided by `config-repo/` (YAML files used by Spring Cloud Config). Discovery via Eureka (`discovery-service/`). Gateway registers with Eureka and routes to services by service id (example in `config-repo/api-gateway.yml`).

2) Why things are structured this way (discovered evidence)
- Responsibility separation: `auth-service` handles authentication (JWT), delegates persistent user creation to `user-service` (see `ARCHITECTURE-CLARIFICATION.md`). This explains duplicated endpoints and the decision to keep Auth focused only on tokens.
- Each business service has its own DB for isolation and easier scaling. See `README.md` architecture diagram and service `pom.xml` and `application.yml` files for DB configs.

3) Key integration points and examples (copy/paste friendly)
- Gateway routing (two sources):
  - `config-repo/api-gateway.yml` (used in containerized environment). Example route shows discovery locator + filters and rate-limiter with Redis key resolver:

    - id: auth-service
      uri: lb://AUTH-SERVICE
      predicates: [ Path=/auth/** ]
      filters:
        - name: RequestRateLimiter
          args:
            redis-rate-limiter.replenishRate: 5
            redis-rate-limiter.burstCapacity: 10
            key-resolver: "#{@remoteAddrKeyResolver}"

  - `gateway-service/src/main/resources/application.yml` (local dev; static URIs to localhost). Example: `uri: http://localhost:8081` for `auth-service`.

- Configuration server: `config-repo/` contains per-service YAML (e.g., `auth-service.yml`, `user-service.yml`). Services import config with `spring.config.import: optional:configserver:http://localhost:8888` or point to `config-service:8888` in Docker compose.

- Discovery/Eureka: gateway and services register with Eureka at `http://discovery-service:8761/eureka/` (see `config-repo/api-gateway.yml` and service `bootstrap.yml` files). Use service ids (uppercase) in gateway when using lb:// URIs.

- JWT secret: Gateway and Auth share a base64 secret in `config-repo/api-gateway.yml` under `jwt.secret`. When modifying auth logic, update both gateway and auth-service secrets.

4) Developer workflows and commands (concrete)
- Local quick start (development):

```powershell
# start all services with docker-compose (project has multi-service compose)
docker-compose up -d

# run a single Spring Boot service in IDE or via wrapper in service dir
cd gateway-service; .\mvnw spring-boot:run

# import initial data (script present in repository)
.\run-init-with-data.ps1
```

- Common Maven usage: use the included wrapper (`mvnw`/`mvnw.cmd`) in each service directory to build/test. Example:

```powershell
cd user-service; .\mvnw clean package -DskipTests
```

- NLP service (Python): `nlp-service` runs on FastAPI. Use `requirements.txt` to install and run with `uvicorn app.main:app --reload --port 5000` in that folder.

5) Project-specific conventions and patterns
- Service naming: Eureka service ids are uppercase (e.g., `AUTH-SERVICE`, `USER-SERVICE`). Gateway uses `lb://SERVICE-ID` for discovery. Local `application.yml` sometimes uses explicit `http://localhost:PORT` for development.
- Config precedence: `bootstrap.yml`/`application.yml` in each service may import the Config Server. When debugging config, check `config-repo/` first.
- Rates & security: Gateway applies `RequestRateLimiter` and adds headers like `AddUserInfoToHeader` to forward user context. See `config-repo/api-gateway.yml` and `gateway-service/src/main/resources/application.yml`.
- Logging: gateway logging level is set in `config-repo/api-gateway.yml` to DEBUG for `org.springframework.cloud.gateway` (used for troubleshooting routing issues).

6) Files to inspect first when changing gateway or cross-cutting behavior
- `config-repo/api-gateway.yml` (production/container configuration)
- `gateway-service/src/main/resources/application.yml` and `bootstrap.yml` (local dev overrides)
- `gateway-service/src/main/java/com/abc/gateway_service/config/GatewayConfig.java` (custom filters/resolvers)
- `config-repo/*.yml` for service-specific properties (DB credentials, JWT secret, ports)
- `ARCHITECTURE-CLARIFICATION.md` and `API_DOCUMENTATION.md` for expected API shapes and flows

7) Edge cases & gotchas (observed)
- Duplicate endpoints found historically between Auth and User (see `ARCHITECTURE-CLARIFICATION.md`). Avoid changing one without validating the other.
- Two different gateway configs may exist (local `application.yml` vs config server `api-gateway.yml`). Always confirm which config the running gateway is using (check `spring.config.import` or if running under Docker, the config server URL).
- JWT secret is Base64 in `config-repo/api-gateway.yml`; do not accidentally double-encode or change format.

8) Quick examples for common changes
- Add a new route to gateway (dev): edit `gateway-service/src/main/resources/application.yml` and add a route with `uri: http://localhost:<port>`; for container change `config-repo/api-gateway.yml` with `uri: lb://SERVICE-ID` and update `config-service` index if necessary.
- Debugging routing: set `logging.level.org.springframework.cloud.gateway=DEBUG` in the gateway config (already enabled in `config-repo/api-gateway.yml`) and inspect gateway actuator `/actuator/gateway` and Eureka UI at `http://localhost:8761`.

9) What I could not discover automatically (ask human)
- The intended authoritative source of truth between `gateway-service/application.yml` and `config-repo/api-gateway.yml` for production vs dev (assume `config-repo` is authoritative when Config Server runs).
- Any runtime secrets that differ from `config-repo` (CI/CD injects secrets at deploy time).

If you want, I will commit this file (or merge into an existing `.github/copilot-instructions.md` if present) and then run a short checklist to validate configuration values (ports, secrets) across `config-repo` and `gateway-service`.

---
Please tell me if you want more details in specific parts (e.g., the exact route filters implementation in Java, or a checklist verifying port/secret consistency across services).
