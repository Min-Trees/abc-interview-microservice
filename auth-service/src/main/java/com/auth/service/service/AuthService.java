package com.auth.service.service;

import com.auth.service.dto.*;
import com.auth.service.exception.*;
import com.auth.service.service.EmailService;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.Base64;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@Slf4j
public class AuthService {

    private final WebClient webClient;
    private final Key key;
    private final long accessMinutes;
    private final long refreshDays;
    private final String jwtIssuer;
    private final EmailService emailService;

    public AuthService(
            WebClient.Builder webClientBuilder,
            @Value("${app.user-service.base-url:http://user-service:8082}") String userServiceBaseUrl,
            @Value("${jwt.secret}") String jwtSecret,
            @Value("${jwt.access-minutes}") long accessMinutes,
            @Value("${jwt.refresh-days}") long refreshDays,
            @Value("${jwt.issuer}") String jwtIssuer,
            EmailService emailService
    ) {
        // WebClient
        this.webClient = webClientBuilder.baseUrl(userServiceBaseUrl).build();

        // Kiểm tra secret
        if (jwtSecret == null || jwtSecret.isBlank()) {
            throw new IllegalStateException("jwt.secret is missing or empty");
        }

        // Nếu secret là Base64 -> decode
        byte[] keyBytes;
        try {
            keyBytes = Base64.getDecoder().decode(jwtSecret);
        } catch (IllegalArgumentException ex) {
            keyBytes = jwtSecret.getBytes(StandardCharsets.UTF_8);
        }
        if (keyBytes.length < 32) {
            throw new IllegalStateException("jwt.secret must be at least 32 bytes for HS256");
        }
        this.key = Keys.hmacShaKeyFor(keyBytes);

        this.accessMinutes = accessMinutes;
        this.refreshDays = refreshDays;
        this.jwtIssuer = jwtIssuer;
        this.emailService = emailService;
    }

    @Transactional
    public Mono<TokenResponse> register(RegisterRequest request) {
        // 1. Check for duplicate email in User Service
        return webClient.get()
                .uri("/users/check-email/{email}", request.getEmail())
                .retrieve()
                .bodyToMono(Boolean.class)
                .flatMap(emailExists -> {
                    if (emailExists != null && emailExists) {
                        return Mono.error(new DuplicateResourceException("User", "email", request.getEmail()));
                    }
                    
                    // 2. Get roleId from roleName if needed
                    Long roleId = request.getRoleId();
                    if (roleId == null && request.getRoleName() != null) {
                        // Convert roleName to roleId (USER=1, RECRUITER=2, ADMIN=3)
                        switch (request.getRoleName().toUpperCase()) {
                            case "USER":
                                roleId = 1L;
                                break;
                            case "RECRUITER":
                                roleId = 2L;
                                break;
                            case "ADMIN":
                                roleId = 3L;
                                break;
                            default:
                                return Mono.error(new BusinessException("Invalid role name: " + request.getRoleName(), "INVALID_ROLE"));
                        }
                    }
                    
                    // 3. Create user in User Service
                    UserCreateRequest userRequest = new UserCreateRequest();
                    userRequest.setRoleId(roleId);
                    userRequest.setEmail(request.getEmail());
                    userRequest.setPassword(request.getPassword());
                    userRequest.setFullName(request.getFullName());
                    userRequest.setDateOfBirth(request.getDateOfBirth());
                    userRequest.setAddress(request.getAddress());
                    userRequest.setIsStudying(request.getIsStudying());
                    
                    return webClient.post()
                            .uri("/users/internal/create")
                            .bodyValue(userRequest)
                            .retrieve()
                            .onStatus(status -> status.isError(), response -> {
                                log.error("Error response from User Service: {}", response.statusCode());
                                return response.bodyToMono(String.class)
                                        .flatMap(body -> Mono.error(new RuntimeException("User Service error: " + body)));
                            })
                            .bodyToMono(UserDto.class)
                            .doOnNext(userDto -> log.info("User created successfully: {}", userDto))
                            .doOnError(error -> log.error("Error creating user: {}", error.getMessage()));
                })
                .flatMap(userDto -> {
                    if (userDto == null) {
                        return Mono.error(new BusinessException("Failed to create user in User Service", "USER_CREATION_FAILED"));
                    }

                    log.info("User registered successfully: {}", userDto.getEmail());

                    // 3. Send verification email (async, non-blocking)
                    emailService.sendVerificationEmail(userDto.getEmail(), userDto.getVerifyToken());

                    // 4. Generate tokens
                    String accessToken = generateAccessToken(userDto);
                    String refreshToken = generateRefreshToken(userDto);

                    return Mono.just(new TokenResponse(accessToken, "Bearer", refreshToken, accessMinutes * 60, userDto.getVerifyToken()));
                });
    }

    @Transactional
    public Mono<TokenResponse> login(LoginRequest request) {
        // 1. Get user from User Service
        return webClient.get()
                .uri("/users/by-email/{email}", request.getEmail())
                .retrieve()
                .bodyToMono(UserDto.class)
                .flatMap(userDto -> {
                    if (userDto == null) {
                        return Mono.error(new InvalidCredentialsException("Invalid email or password"));
                    }

                    // 2. Check password
                    return webClient.post()
                            .uri("/users/validate-password")
                            .bodyValue(Map.of("email", request.getEmail(), "password", request.getPassword()))
                            .retrieve()
                            .bodyToMono(Boolean.class)
                            .flatMap(passwordValid -> {
                                if (passwordValid == null || !passwordValid) {
                                    return Mono.error(new InvalidCredentialsException("Invalid email or password"));
                                }

                                // 3. Check status
                                if (!"ACTIVE".equals(userDto.getStatus())) {
                                    return Mono.error(new BusinessException("User account is not active. Please verify your email.", "ACCOUNT_NOT_ACTIVE"));
                                }

                                log.info("User logged in successfully: {}", userDto.getEmail());

                                // 4. Generate tokens
                                String accessToken = generateAccessToken(userDto);
                                String refreshToken = generateRefreshToken(userDto);

                                return Mono.just(new TokenResponse(accessToken, "Bearer", refreshToken, accessMinutes * 60));
                            });
                });
    }

    public Mono<TokenResponse> refresh(RefreshRequest request) {
        String token = request.getRefreshToken();
        try {
            Long userId = Long.valueOf(Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token)
                    .getBody()
                    .getSubject());
            
            // Get user from User Service
            return webClient.get()
                    .uri("/users/{id}", userId)
                    .retrieve()
                    .bodyToMono(UserDto.class)
                    .flatMap(userDto -> {
                        if (userDto == null) {
                            return Mono.error(new ResourceNotFoundException("User", "id", userId));
                        }

                        String accessToken = generateAccessToken(userDto);
                        String refreshToken = generateRefreshToken(userDto);
                        
                        return Mono.just(new TokenResponse(accessToken, "Bearer", refreshToken, accessMinutes * 60));
                    });
        } catch (Exception e) {
            return Mono.error(new TokenExpiredException("Refresh token is invalid or expired"));
        }
    }

    @Transactional
    public Mono<TokenResponse> verify(String token) {
        // 1. Verify token in User Service
        return webClient.post()
                .uri("/users/verify-token")
                .bodyValue(Map.of("token", token))
                .retrieve()
                .bodyToMono(UserDto.class)
                .flatMap(userDto -> {
                    if (userDto == null) {
                        return Mono.error(new TokenExpiredException("Verification token is invalid or expired"));
                    }
                    
                    log.info("User verified successfully: {}", userDto.getEmail());

                    // 2. Generate tokens
                    String accessToken = generateAccessToken(userDto);
                    String refreshToken = generateRefreshToken(userDto);

                    return Mono.just(new TokenResponse(accessToken, "Bearer", refreshToken, accessMinutes * 60));
                });
    }

    // User management methods removed - handled by User Service

    public Mono<UserDto> getUserInfoByToken(String token) {
        try {
            Claims claims = Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token)
                    .getBody();

            Long userId = Long.valueOf(claims.getSubject());
            
            return webClient.get()
                    .uri("/users/{id}", userId)
                    .retrieve()
                    .bodyToMono(UserDto.class)
                    .doOnNext(userDto -> log.info("User info retrieved for: {}", userDto.getEmail()))
                    .doOnError(error -> log.error("Error retrieving user info: {}", error.getMessage()));
                    
        } catch (Exception e) {
            log.error("Invalid token: {}", e.getMessage());
            return Mono.error(new BusinessException("Invalid token", "INVALID_TOKEN"));
        }
    }

    // Helper methods removed - User Service handles all user data

    private String generateAccessToken(UserDto user) {
        Instant now = Instant.now();
        return Jwts.builder()
                .setSubject(String.valueOf(user.getId()))
                .claim("email", user.getEmail())
                .claim("roles", user.getRoleName() != null ? List.of(user.getRoleName()) : List.of("USER"))
                .setIssuer(jwtIssuer)
                .setIssuedAt(Date.from(now))
                .setExpiration(Date.from(now.plus(accessMinutes, ChronoUnit.MINUTES)))
                .signWith(key)
                .compact();
    }

    private String generateRefreshToken(UserDto user) {
        Instant now = Instant.now();
        return Jwts.builder()
                .setSubject(String.valueOf(user.getId()))
                .setIssuer(jwtIssuer)
                .setIssuedAt(Date.from(now))
                .setExpiration(Date.from(now.plus(refreshDays, ChronoUnit.DAYS)))
                .signWith(key)
                .compact();
    }

    // Helper methods removed - User Service handles all user data
}
