# Script to disable authentication for all services
# This will make all APIs accessible without authentication for testing

Write-Host "Disabling authentication for all services..." -ForegroundColor Blue

# Function to disable authentication
function Disable-Authentication {
    param(
        [string]$FilePath,
        [string]$ServiceName
    )
    
    if (Test-Path $FilePath) {
        Write-Host "Disabling authentication for $ServiceName..." -ForegroundColor Yellow
        
        # Read the file
        $content = Get-Content $FilePath -Raw
        
        # Replace the entire security filter chain to disable authentication
        $newConfig = @'
    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(Customizer.withDefaults())
                .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .anyRequest().permitAll()
                );

        return http.build();
    }
'@

        # Find and replace the security filter chain
        $pattern = '(?s)@Bean\s+SecurityFilterChain\s+securityFilterChain\(HttpSecurity\s+http\)\s+throws\s+Exception\s*\{.*?\}'
        $content = $content -replace $pattern, $newConfig
        
        # Write back to file
        Set-Content $FilePath -Value $content -NoNewline
        
        Write-Host "✅ Disabled authentication for $ServiceName" -ForegroundColor Green
    } else {
        Write-Host "❌ File not found: $FilePath" -ForegroundColor Red
    }
}

# Disable authentication for all services
Disable-Authentication -FilePath "user-service/src/main/java/com/abc/user_service/config/SecurityConfig.java" -ServiceName "User Service"
Disable-Authentication -FilePath "career-service/src/main/java/com/abc/career_service/config/SecurityConfig.java" -ServiceName "Career Service"
Disable-Authentication -FilePath "question-service/src/main/java/com/abc/question_service/config/SecurityConfig.java" -ServiceName "Question Service"
Disable-Authentication -FilePath "exam-service/src/main/java/com/abc/exam_service/config/SecurityConfig.java" -ServiceName "Exam Service"
Disable-Authentication -FilePath "news-service/src/main/java/com/abc/news_service/config/SecurityConfig.java" -ServiceName "News Service"

Write-Host "`nAuthentication disabled for all services!" -ForegroundColor Green
Write-Host "All APIs are now accessible without authentication for testing purposes." -ForegroundColor Yellow
