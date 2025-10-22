package com.abc.user_service.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtConfig jwtConfig;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String requestURI = request.getRequestURI();
        System.out.println("JWT Filter - Request URI: " + requestURI);
        
        // Skip JWT validation for internal endpoints
        if (requestURI.startsWith("/users/internal/") || 
            requestURI.startsWith("/users/check-email/") ||
            requestURI.startsWith("/users/by-email/") ||
            requestURI.startsWith("/users/validate-password") ||
            requestURI.startsWith("/users/verify-token") ||
            requestURI.startsWith("/actuator/")) {
            System.out.println("JWT Filter - Skipping JWT validation for internal endpoint");
            filterChain.doFilter(request, response);
            return;
        }

        String authHeader = request.getHeader("Authorization");
        System.out.println("JWT Filter - Authorization header: " + authHeader);
        
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            System.out.println("JWT Filter - Token: " + token);
            
            if (jwtConfig.validateToken(token)) {
                try {
                    var authentication = jwtConfig.getAuthentication(token);
                    System.out.println("JWT Filter - Authentication: " + authentication);
                    System.out.println("JWT Filter - Authorities: " + authentication.getAuthorities());
                    SecurityContextHolder.getContext().setAuthentication(authentication);
                } catch (Exception e) {
                    System.out.println("JWT Filter - Error parsing token: " + e.getMessage());
                    e.printStackTrace();
                }
            } else {
                System.out.println("JWT Filter - Token validation failed");
            }
        } else {
            System.out.println("JWT Filter - No valid Authorization header");
        }

        filterChain.doFilter(request, response);
    }
}
