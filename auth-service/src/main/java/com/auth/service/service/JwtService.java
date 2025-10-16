package com.auth.service.service;

import com.auth.service.dto.UserDto;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class JwtService {

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.access-minutes}")
    private long accessMinutes;

    @Value("${jwt.refresh-days}")
    private long refreshDays;

    @Value("${jwt.issuer}")
    private String jwtIssuer;

    public String generateAccessToken(UserDto user) {
        return Jwts.builder()
                .setSubject(user.getId().toString()) // Claim `sub`
                .claim("roles", List.of("USER")) // Claim `roles`, có thể lấy từ UserDto
                .setIssuer(jwtIssuer) // Claim `iss`
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + accessMinutes * 60 * 1000))
                .signWith(SignatureAlgorithm.HS256, jwtSecret)
                .compact();
    }

    public String generateRefreshToken(UserDto user) {
        return Jwts.builder()
                .setSubject(user.getId().toString()) // Claim `sub`
                .setIssuer(jwtIssuer) // Claim `iss`
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + refreshDays * 24 * 60 * 60 * 1000))
                .signWith(SignatureAlgorithm.HS256, jwtSecret)
                .compact();
    }

    public io.jsonwebtoken.Claims parse(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(jwtSecret)
                .build()
                .parseClaimsJws(token)
                .getBody();
    }
}