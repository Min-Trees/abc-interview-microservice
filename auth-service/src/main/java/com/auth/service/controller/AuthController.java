package com.auth.service.controller;

import com.auth.service.dto.*;
import com.auth.service.service.AuthService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public Mono<TokenResponse> register(@RequestBody RegisterRequest request) {
        return authService.register(request);
    }

    @PostMapping("/login")
    public Mono<TokenResponse> login(@RequestBody LoginRequest request) {
        return authService.login(request);
    }

    @PostMapping("/refresh")
    public Mono<TokenResponse> refresh(@RequestBody RefreshRequest request) {
        return authService.refresh(request);
    }

    @GetMapping("/verify")
    public Mono<TokenResponse> verify(@RequestParam String token) {
        return authService.verify(token);
    }

    @GetMapping("/user-info")
    public Mono<UserDto> getUserInfo(@RequestHeader("Authorization") String authorization) {
        String token = authorization.replace("Bearer ", "");
        return authService.getUserInfoByToken(token);
    }

    // Removed: User management should be handled by User Service
}