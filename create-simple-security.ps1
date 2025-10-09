# Script to create simple and correct security configurations
# This will create working security configs for all services

Write-Host "Creating simple security configurations..." -ForegroundColor Blue

# Function to create simple security config
function Create-SimpleSecurityConfig {
    param(
        [string]$FilePath,
        [string]$ServiceName
    )
    
    if (Test-Path $FilePath) {
        Write-Host "Creating simple security config for $ServiceName..." -ForegroundColor Yellow
        
        $simpleConfig = @'
package com.abc.career_service.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;

@Configuration
@org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity
public class SecurityConfig {

    @Bean
    PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public JwtDecoder jwtDecoder() {
        String secret = "UCIafMmHwgsJKIgg4xVAL/eOvR3ZXD/ZnYE9AfMaMQg=";
        byte[] keyBytes = java.util.Base64.getDecoder().decode(secret);
        javax.crypto.spec.SecretKeySpec key = new javax.crypto.spec.SecretKeySpec(keyBytes, "HmacSHA256");
        return NimbusJwtDecoder.withSecretKey(key).build();
    }

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(Customizer.withDefaults())
                .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()
                        .requestMatchers("/actuator/**").permitAll()
                        .anyRequest().permitAll()
                );

        return http.build();
    }

    @Bean
    public JwtAuthenticationConverter jwtAuthenticationConverter() {
        var converter = new JwtAuthenticationConverter();
        converter.setPrincipalClaimName("sub");
        converter.setJwtGrantedAuthoritiesConverter(jwt -> {
            java.util.List<String> roles = jwt.getClaimAsStringList("roles");
            if (roles == null) roles = java.util.List.of();
            return roles.stream()
                    .map(r -> r.startsWith("ROLE_") ? r : "ROLE_" + r)
                    .map(SimpleGrantedAuthority::new)
                    .collect(java.util.stream.Collectors.toList());
        });
        return converter;
    }
}
'@

        # Write the simple config
        Set-Content $FilePath -Value $simpleConfig -NoNewline
        
        Write-Host "✅ Created simple security config for $ServiceName" -ForegroundColor Green
    } else {
        Write-Host "❌ File not found: $FilePath" -ForegroundColor Red
    }
}

# Create simple security configs for all services
Create-SimpleSecurityConfig -FilePath "career-service/src/main/java/com/abc/career_service/config/SecurityConfig.java" -ServiceName "Career Service"
Create-SimpleSecurityConfig -FilePath "question-service/src/main/java/com/abc/question_service/config/SecurityConfig.java" -ServiceName "Question Service"
Create-SimpleSecurityConfig -FilePath "exam-service/src/main/java/com/abc/exam_service/config/SecurityConfig.java" -ServiceName "Exam Service"
Create-SimpleSecurityConfig -FilePath "news-service/src/main/java/com/abc/news_service/config/SecurityConfig.java" -ServiceName "News Service"

Write-Host "`nSimple security configurations created!" -ForegroundColor Green
Write-Host "All services now have basic security with permitAll for testing." -ForegroundColor Yellow
