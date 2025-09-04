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
    public Mono<UserDto> register(@RequestBody RegisterRequest request) {
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

    @GetMapping("/users/{id}")
    public Mono<UserDto> getUserById(@PathVariable Long id) {
        return authService.getUserById(id);
    }
}