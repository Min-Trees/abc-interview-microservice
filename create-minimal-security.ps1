# Script to create minimal security configurations
# This will create the simplest possible security configs for testing

Write-Host "Creating minimal security configurations..." -ForegroundColor Blue

# Function to create minimal security config
function Create-MinimalSecurityConfig {
    param(
        [string]$FilePath,
        [string]$ServiceName
    )
    
    if (Test-Path $FilePath) {
        Write-Host "Creating minimal security config for $ServiceName..." -ForegroundColor Yellow
        
        $minimalConfig = @'
package com.abc.career_service.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .authorizeHttpRequests(auth -> auth
                        .anyRequest().permitAll()
                );

        return http.build();
    }
}
'@

        # Write the minimal config
        Set-Content $FilePath -Value $minimalConfig -NoNewline
        
        Write-Host "✅ Created minimal security config for $ServiceName" -ForegroundColor Green
    } else {
        Write-Host "❌ File not found: $FilePath" -ForegroundColor Red
    }
}

# Create minimal security configs for all services
Create-MinimalSecurityConfig -FilePath "career-service/src/main/java/com/abc/career_service/config/SecurityConfig.java" -ServiceName "Career Service"
Create-MinimalSecurityConfig -FilePath "question-service/src/main/java/com/abc/question_service/config/SecurityConfig.java" -ServiceName "Question Service"
Create-MinimalSecurityConfig -FilePath "exam-service/src/main/java/com/abc/exam_service/config/SecurityConfig.java" -ServiceName "Exam Service"
Create-MinimalSecurityConfig -FilePath "news-service/src/main/java/com/abc/news_service/config/SecurityConfig.java" -ServiceName "News Service"
Create-MinimalSecurityConfig -FilePath "user-service/src/main/java/com/abc/user_service/config/SecurityConfig.java" -ServiceName "User Service"

Write-Host "`nMinimal security configurations created!" -ForegroundColor Green
Write-Host "All services now have the simplest possible security for testing." -ForegroundColor Yellow
