package com.auth.service.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.bind.support.WebExchangeBindException;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(RoleNotFoundException.class)
    public Mono<ResponseEntity<ErrorResponse>> handleRoleNotFoundException(
            RoleNotFoundException ex, 
            ServerHttpRequest request) {
        ErrorResponse error = ErrorResponse.builder()
                .type("https://errors.abc.com/ROLE_NOT_FOUND")
                .title("Role Not Found")
                .status(HttpStatus.NOT_FOUND.value())
                .detail(ex.getMessage())
                .instance(request.getPath().value())
                .errorCode("ROLE_NOT_FOUND")
                .traceId(UUID.randomUUID().toString())
                .timestamp(Instant.now())
                .build();
        return Mono.just(new ResponseEntity<>(error, HttpStatus.NOT_FOUND));
    }

    @ExceptionHandler(ResourceNotFoundException.class)
    public Mono<ResponseEntity<ErrorResponse>> handleResourceNotFoundException(
            ResourceNotFoundException ex, 
            ServerHttpRequest request) {
        ErrorResponse error = ErrorResponse.builder()
                .type("https://errors.abc.com/RESOURCE_NOT_FOUND")
                .title("Resource Not Found")
                .status(HttpStatus.NOT_FOUND.value())
                .detail(ex.getMessage())
                .instance(request.getPath().value())
                .errorCode("RESOURCE_NOT_FOUND")
                .traceId(UUID.randomUUID().toString())
                .timestamp(Instant.now())
                .build();
        return Mono.just(new ResponseEntity<>(error, HttpStatus.NOT_FOUND));
    }

    @ExceptionHandler(DuplicateResourceException.class)
    public Mono<ResponseEntity<ErrorResponse>> handleDuplicateResourceException(
            DuplicateResourceException ex,
            ServerHttpRequest request) {
        ErrorResponse error = ErrorResponse.builder()
                .type("https://errors.abc.com/DUPLICATE_RESOURCE")
                .title("Duplicate Resource")
                .status(HttpStatus.CONFLICT.value())
                .detail(ex.getMessage())
                .instance(request.getPath().value())
                .errorCode("DUPLICATE_RESOURCE")
                .traceId(UUID.randomUUID().toString())
                .timestamp(Instant.now())
                .build();
        return Mono.just(new ResponseEntity<>(error, HttpStatus.CONFLICT));
    }

    @ExceptionHandler(InvalidCredentialsException.class)
    public Mono<ResponseEntity<ErrorResponse>> handleInvalidCredentialsException(
            InvalidCredentialsException ex,
            ServerHttpRequest request) {
        ErrorResponse error = ErrorResponse.builder()
                .type("https://errors.abc.com/INVALID_CREDENTIALS")
                .title("Authentication Failed")
                .status(HttpStatus.UNAUTHORIZED.value())
                .detail(ex.getMessage())
                .instance(request.getPath().value())
                .errorCode("INVALID_CREDENTIALS")
                .traceId(UUID.randomUUID().toString())
                .timestamp(Instant.now())
                .build();
        return Mono.just(new ResponseEntity<>(error, HttpStatus.UNAUTHORIZED));
    }

    @ExceptionHandler(TokenExpiredException.class)
    public Mono<ResponseEntity<ErrorResponse>> handleTokenExpiredException(
            TokenExpiredException ex,
            ServerHttpRequest request) {
        ErrorResponse error = ErrorResponse.builder()
                .type("https://errors.abc.com/TOKEN_EXPIRED")
                .title("Token Expired")
                .status(HttpStatus.UNAUTHORIZED.value())
                .detail(ex.getMessage())
                .instance(request.getPath().value())
                .errorCode("TOKEN_EXPIRED")
                .traceId(UUID.randomUUID().toString())
                .timestamp(Instant.now())
                .build();
        return Mono.just(new ResponseEntity<>(error, HttpStatus.UNAUTHORIZED));
    }

    @ExceptionHandler(BusinessException.class)
    public Mono<ResponseEntity<ErrorResponse>> handleBusinessException(
            BusinessException ex,
            ServerHttpRequest request) {
        ErrorResponse error = ErrorResponse.builder()
                .type("https://errors.abc.com/" + ex.getErrorCode())
                .title("Business Rule Violation")
                .status(HttpStatus.BAD_REQUEST.value())
                .detail(ex.getMessage())
                .instance(request.getPath().value())
                .errorCode(ex.getErrorCode())
                .traceId(UUID.randomUUID().toString())
                .timestamp(Instant.now())
                .build();
        return Mono.just(new ResponseEntity<>(error, HttpStatus.BAD_REQUEST));
    }

    @ExceptionHandler(WebExchangeBindException.class)
    public Mono<ResponseEntity<ErrorResponse>> handleValidationExceptions(
            WebExchangeBindException ex,
            ServerHttpRequest request) {
        Map<String, String> validationErrors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach((error) -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            validationErrors.put(fieldName, errorMessage);
        });

        ErrorResponse error = ErrorResponse.builder()
                .type("https://errors.abc.com/VALIDATION_FAILED")
                .title("Validation Failed")
                .status(HttpStatus.BAD_REQUEST.value())
                .detail("Input validation failed. Please check the provided fields.")
                .instance(request.getPath().value())
                .errorCode("VALIDATION_FAILED")
                .traceId(UUID.randomUUID().toString())
                .timestamp(Instant.now())
                .details(validationErrors)
                .build();
        return Mono.just(new ResponseEntity<>(error, HttpStatus.BAD_REQUEST));
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public Mono<ResponseEntity<ErrorResponse>> handleIllegalArgumentException(
            IllegalArgumentException ex,
            ServerHttpRequest request) {
        ErrorResponse error = ErrorResponse.builder()
                .type("https://errors.abc.com/INVALID_ARGUMENT")
                .title("Invalid Argument")
                .status(HttpStatus.BAD_REQUEST.value())
                .detail(ex.getMessage())
                .instance(request.getPath().value())
                .errorCode("INVALID_ARGUMENT")
                .traceId(UUID.randomUUID().toString())
                .timestamp(Instant.now())
                .build();
        return Mono.just(new ResponseEntity<>(error, HttpStatus.BAD_REQUEST));
    }

    @ExceptionHandler(RuntimeException.class)
    public Mono<ResponseEntity<ErrorResponse>> handleRuntimeException(
            RuntimeException ex,
            ServerHttpRequest request) {
        ErrorResponse error = ErrorResponse.builder()
                .type("https://errors.abc.com/RUNTIME_ERROR")
                .title("Runtime Error")
                .status(HttpStatus.BAD_REQUEST.value())
                .detail(ex.getMessage())
                .instance(request.getPath().value())
                .errorCode("RUNTIME_ERROR")
                .traceId(UUID.randomUUID().toString())
                .timestamp(Instant.now())
                .build();
        return Mono.just(new ResponseEntity<>(error, HttpStatus.BAD_REQUEST));
    }

    @ExceptionHandler(Exception.class)
    public Mono<ResponseEntity<ErrorResponse>> handleGlobalException(
            Exception ex,
            ServerHttpRequest request) {
        ErrorResponse error = ErrorResponse.builder()
                .type("https://errors.abc.com/INTERNAL_SERVER_ERROR")
                .title("Internal Server Error")
                .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                .detail("An unexpected error occurred. Please contact support if the problem persists.")
                .instance(request.getPath().value())
                .errorCode("INTERNAL_SERVER_ERROR")
                .traceId(UUID.randomUUID().toString())
                .timestamp(Instant.now())
                .build();
        return Mono.just(new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR));
    }
}
