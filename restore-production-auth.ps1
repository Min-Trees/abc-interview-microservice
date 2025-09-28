# Script to restore proper authentication for production
# This will configure all services with proper role-based authentication

Write-Host "Restoring production authentication for all services..." -ForegroundColor Blue

# Function to restore proper security config
function Restore-SecurityConfig {
    param(
        [string]$FilePath,
        [string]$ServiceName,
        [string]$PublicEndpoints
    )
    
    if (Test-Path $FilePath) {
        Write-Host "Restoring authentication for $ServiceName..." -ForegroundColor Yellow
        
        $newConfig = @"
    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(Customizer.withDefaults())
                .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()
                        .requestMatchers("/actuator/**").permitAll()
                        $PublicEndpoints
                        .anyRequest().authenticated()
                )
                .oauth2ResourceServer(oauth2 -> oauth2
                        .jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthenticationConverter()))
                );

        return http.build();
    }
"@

        # Read the file
        $content = Get-Content $FilePath -Raw
        
        # Find and replace the security filter chain
        $pattern = '(?s)@Bean\s+SecurityFilterChain\s+securityFilterChain\(HttpSecurity\s+http\)\s+throws\s+Exception\s*\{.*?\}'
        $content = $content -replace $pattern, $newConfig
        
        # Write back to file
        Set-Content $FilePath -Value $content -NoNewline
        
        Write-Host "✅ Restored authentication for $ServiceName" -ForegroundColor Green
    } else {
        Write-Host "❌ File not found: $FilePath" -ForegroundColor Red
    }
}

# Restore authentication for all services with proper role-based access
Restore-SecurityConfig -FilePath "user-service/src/main/java/com/abc/user_service/config/SecurityConfig.java" -ServiceName "User Service" -PublicEndpoints ".requestMatchers(HttpMethod.POST, `/`/users/register`/`, `/`/users/login`/`).permitAll()`n                        .requestMatchers(HttpMethod.GET, `/`/users/verify`/`).permitAll()"

Restore-SecurityConfig -FilePath "career-service/src/main/java/com/abc/career_service/config/SecurityConfig.java" -ServiceName "Career Service" -PublicEndpoints ".requestMatchers(`/`/career/**`/`).hasAnyRole(`/`USER`/`, `/`ADMIN`/`, `/`RECRUITER`/`)"

Restore-SecurityConfig -FilePath "question-service/src/main/java/com/abc/question_service/config/SecurityConfig.java" -ServiceName "Question Service" -PublicEndpoints ".requestMatchers(HttpMethod.GET, `/`/questions/**`/`, `/`/topics/**`/`, `/`/fields/**`/`, `/`/levels/**`/`, `/`/question-types/**`/`, `/`/answers/**`/`).hasAnyRole(`/`USER`/`, `/`ADMIN`/`, `/`RECRUITER`/`)`n                        .requestMatchers(HttpMethod.POST, `/`/questions/**`/`, `/`/topics/**`/`, `/`/fields/**`/`, `/`/levels/**`/`, `/`/question-types/**`/`, `/`/answers/**`/`).hasAnyRole(`/`USER`/`, `/`ADMIN`/`, `/`RECRUITER`/`)`n                        .requestMatchers(HttpMethod.PUT, `/`/questions/**`/`, `/`/answers/**`/`).hasAnyRole(`/`USER`/`, `/`ADMIN`/`, `/`RECRUITER`/`)`n                        .requestMatchers(HttpMethod.DELETE, `/`/questions/**`/`, `/`/answers/**`/`).hasAnyRole(`/`ADMIN`/`, `/`RECRUITER`/`)`n                        .requestMatchers(`/`/questions/*/approve`/`, `/`/questions/*/reject`/`, `/`/answers/*/sample`/`).hasRole(`/`ADMIN`/`)"

Restore-SecurityConfig -FilePath "exam-service/src/main/java/com/abc/exam_service/config/SecurityConfig.java" -ServiceName "Exam Service" -PublicEndpoints ".requestMatchers(HttpMethod.GET, `/`/exams/**`/`).hasAnyRole(`/`USER`/`, `/`ADMIN`/`, `/`RECRUITER`/`)`n                        .requestMatchers(HttpMethod.POST, `/`/exams/**`/`).hasAnyRole(`/`USER`/`, `/`ADMIN`/`, `/`RECRUITER`/`)`n                        .requestMatchers(HttpMethod.PUT, `/`/exams/**`/`).hasAnyRole(`/`ADMIN`/`, `/`RECRUITER`/`)`n                        .requestMatchers(HttpMethod.DELETE, `/`/exams/**`/`).hasAnyRole(`/`ADMIN`/`, `/`RECRUITER`/`)`n                        .requestMatchers(`/`/exams/*/publish`/`).hasAnyRole(`/`ADMIN`/`, `/`RECRUITER`/`)"

Restore-SecurityConfig -FilePath "news-service/src/main/java/com/abc/news_service/config/SecurityConfig.java" -ServiceName "News Service" -PublicEndpoints ".requestMatchers(HttpMethod.GET, `/`/news/**`/`, `/`/recruitments/**`/`).permitAll()`n                        .requestMatchers(HttpMethod.POST, `/`/news/**`/`, `/`/recruitments/**`/`).hasAnyRole(`/`USER`/`, `/`ADMIN`/`, `/`RECRUITER`/`)`n                        .requestMatchers(HttpMethod.PUT, `/`/news/**`/`).hasAnyRole(`/`USER`/`, `/`ADMIN`/`, `/`RECRUITER`/`)`n                        .requestMatchers(HttpMethod.DELETE, `/`/news/**`/`).hasAnyRole(`/`ADMIN`/`, `/`RECRUITER`/`)`n                        .requestMatchers(`/`/news/*/approve`/`, `/`/news/*/reject`/`, `/`/news/*/publish`/`).hasRole(`/`ADMIN`/`)"

Write-Host "`nProduction authentication restored for all services!" -ForegroundColor Green
Write-Host "Services now have proper role-based access control:" -ForegroundColor Yellow
Write-Host "- USER: Can read and create content" -ForegroundColor Cyan
Write-Host "- ADMIN: Full access to all operations" -ForegroundColor Cyan
Write-Host "- RECRUITER: Can manage exams and news" -ForegroundColor Cyan
