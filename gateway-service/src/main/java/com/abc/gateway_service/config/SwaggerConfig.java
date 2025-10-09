package com.abc.gateway_service.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Interview Microservice API Gateway")
                        .description("Tổng hợp tất cả APIs của hệ thống Interview Microservice")
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("ABC Company")
                                .email("support@abc.com")
                                .url("https://abc.com"))
                        .license(new License()
                                .name("MIT License")
                                .url("https://opensource.org/licenses/MIT")))
                .servers(List.of(
                        new Server()
                                .url("http://localhost:8080")
                                .description("Gateway Server"),
                        new Server()
                                .url("http://localhost:8081")
                                .description("Auth Service"),
                        new Server()
                                .url("http://localhost:8082")
                                .description("User Service"),
                        new Server()
                                .url("http://localhost:8084")
                                .description("Career Service"),
                        new Server()
                                .url("http://localhost:8085")
                                .description("Question Service"),
                        new Server()
                                .url("http://localhost:8086")
                                .description("Exam Service"),
                        new Server()
                                .url("http://localhost:8087")
                                .description("News Service")
                ));
    }
}











