package com.abc.question_service.config;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.security.Key;
import javax.crypto.SecretKey;
import java.util.List;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
@Slf4j
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final Key jwtSecretKey;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        String requestURI = request.getRequestURI();
        String method = request.getMethod();
        log.debug("JWT Filter - Request URI: {}, Method: {}", requestURI, method);
        
        // Skip JWT validation for public endpoints
        if (requestURI.startsWith("/actuator/") || 
            requestURI.startsWith("/v3/api-docs") ||
            requestURI.startsWith("/swagger-ui")) {
            log.debug("JWT Filter - Skipping JWT validation for public endpoint");
            filterChain.doFilter(request, response);
            return;
        }
        
        // Allow GET requests to taxonomy endpoints without authentication
        if ("GET".equals(method) && 
            (requestURI.startsWith("/questions/fields") ||
             requestURI.startsWith("/questions/levels") ||
             requestURI.startsWith("/questions/topics") ||
             requestURI.startsWith("/questions/question-types") ||
             requestURI.matches("/questions(/\\d+)?$") ||
             requestURI.startsWith("/questions/answers"))) {
            log.debug("JWT Filter - Skipping JWT validation for GET request to public endpoint");
            filterChain.doFilter(request, response);
            return;
        }

        String header = request.getHeader("Authorization");

        if (header == null || !header.startsWith("Bearer ")) {
            log.debug("JWT Filter - No valid Authorization header");
            filterChain.doFilter(request, response);
            return;
        }

        String token = header.replace("Bearer ", "");

        try {
            Claims claims = Jwts.parser()
                    .verifyWith((SecretKey) jwtSecretKey)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

            String userId = claims.getSubject();
            List<String> roles = claims.get("roles", List.class);

            if (userId != null && roles != null) {
                List<SimpleGrantedAuthority> authorities = roles.stream()
                        .map(role -> new SimpleGrantedAuthority("ROLE_" + role))
                        .collect(Collectors.toList());

                UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                        userId, null, authorities);

                SecurityContextHolder.getContext().setAuthentication(authentication);
                log.debug("JWT Filter - Authentication set for user: {} with roles: {}", userId, authorities);
            }

        } catch (Exception e) {
            log.error("JWT validation failed: {}", e.getMessage());
            SecurityContextHolder.clearContext();
        }

        filterChain.doFilter(request, response);
    }
}
