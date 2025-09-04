package com.auth.service.service;

import com.auth.service.dto.*;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Base64;
import java.util.Date;
import java.util.List;

@Service
public class AuthService {

    private final WebClient webClient;
    private final Key key;
    private final long accessMinutes;
    private final long refreshDays;
    private final String jwtIssuer;

    public AuthService(
            WebClient.Builder webClientBuilder,
            @Value("${app.user-service.base-url:http://user-service:8082}") String userServiceBaseUrl,
            @Value("${jwt.secret}") String jwtSecret,
            @Value("${jwt.access-minutes}") long accessMinutes,
            @Value("${jwt.refresh-days}") long refreshDays,
            @Value("${jwt.issuer}") String jwtIssuer
    ) {
        // WebClient
        this.webClient = webClientBuilder.baseUrl(userServiceBaseUrl).build();

        // Kiểm tra secret
        if (jwtSecret == null || jwtSecret.isBlank()) {
            throw new IllegalStateException("jwt.secret is missing or empty");
        }

        // Nếu secret là Base64 (chuỗi của bạn trông như Base64) -> decode:
        byte[] keyBytes;
        try {
            keyBytes = Base64.getDecoder().decode(jwtSecret);
        } catch (IllegalArgumentException ex) {
            // Nếu KHÔNG phải Base64 thì dùng bytes thô (yêu cầu >= 32 bytes cho HS256)
            keyBytes = jwtSecret.getBytes(StandardCharsets.UTF_8);
        }
        if (keyBytes.length < 32) {
            throw new IllegalStateException("jwt.secret must be at least 32 bytes for HS256");
        }
        this.key = Keys.hmacShaKeyFor(keyBytes);

        this.accessMinutes = accessMinutes;
        this.refreshDays = refreshDays;
        this.jwtIssuer = jwtIssuer;
    }

    public Mono<UserDto> register(RegisterRequest request) {
        return webClient.post()
                .uri("/users/register")
                .bodyValue(request)
                .retrieve()
                .bodyToMono(UserDto.class)
                .onErrorMap(e -> new RuntimeException("Đăng ký thất bại: " + e.getMessage()));
    }

    public Mono<TokenResponse> login(LoginRequest request) {
        return webClient.post()
                .uri("/users/login")
                .bodyValue(request)
                .retrieve()
                .bodyToMono(UserDto.class)
                .map(user -> {
                    String accessToken = generateAccessToken(user);
                    String refreshToken = generateRefreshToken(user);
                    return new TokenResponse(accessToken, "Bearer", refreshToken, accessMinutes * 60);
                })
                .onErrorMap(e -> new RuntimeException("Đăng nhập thất bại: " + e.getMessage()));
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
            return webClient.get()
                    .uri("/users/{id}", userId)
                    .retrieve()
                    .bodyToMono(UserDto.class)
                    .map(user -> {
                        String accessToken = generateAccessToken(user);
                        String refreshToken = generateRefreshToken(user);
                        return new TokenResponse(accessToken, "Bearer", refreshToken, accessMinutes * 60);
                    });
        } catch (Exception e) {
            throw new RuntimeException("Refresh token không hợp lệ: " + e.getMessage());
        }
    }

    public Mono<TokenResponse> verify(String token) {
        return webClient.get()
                .uri("/users/verify?token={token}", token)
                .retrieve()
                .bodyToMono(UserDto.class)
                .map(user -> {
                    String accessToken = generateAccessToken(user);
                    String refreshToken = generateRefreshToken(user);
                    return new TokenResponse(accessToken, "Bearer", refreshToken, accessMinutes * 60);
                })
                .onErrorMap(e -> new RuntimeException("Xác minh thất bại: " + e.getMessage()));
    }

    public Mono<UserDto> getUserById(Long id) {
        return webClient.get()
                .uri("/users/{id}", id)
                .retrieve()
                .bodyToMono(UserDto.class)
                .onErrorMap(e -> new RuntimeException("Không lấy được thông tin người dùng: " + e.getMessage()));
    }

    private String generateAccessToken(UserDto user) {
        Instant now = Instant.now();
        return Jwts.builder()
                .setSubject(String.valueOf(user.getId()))
                .claim("roles", List.of("USER"))
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
}
