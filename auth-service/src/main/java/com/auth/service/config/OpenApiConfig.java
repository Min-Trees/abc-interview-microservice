package com.auth.service.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Auth Service API")
                        .description("Authentication and Authorization Service for Interview System\n\n" +
                                "### 🔐 Getting Started\n" +
                                "1. **Register**: Use POST /auth/register to create new account\n" +
                                "2. **Login**: Use POST /auth/login to get JWT token\n" +
                                "3. **Copy Token**: Copy the accessToken from response\n" +
                                "4. **Authorize**: Click **Authorize** button and paste: `Bearer your-token`\n\n" +
                                "### 📝 Test Credentials\n" +
                                "- **Admin**: admin@example.com / password123\n" +
                                "- **User**: user@example.com / password123\n" +
                                "- **Recruiter**: recruiter@example.com / password123")
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("Interview System Team")
                                .email("admin@interview-system.com"))
                        .license(new License()
                                .name("MIT License")
                                .url("https://opensource.org/licenses/MIT")))
                .servers(List.of(
                        new Server()
                                .url("http://localhost:8081")
                                .description("Local Development Server"),
                        new Server()
                                .url("http://localhost:8080")
                                .description("API Gateway (Recommended)")
                ))
                .components(new Components()
                        .addSecuritySchemes("bearer-jwt", new SecurityScheme()
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .in(SecurityScheme.In.HEADER)
                                .name("Authorization")
                                .description("JWT token for authentication. Format: Bearer {token}")))
                .addSecurityItem(new SecurityRequirement().addList("bearer-jwt"));
    }
}
