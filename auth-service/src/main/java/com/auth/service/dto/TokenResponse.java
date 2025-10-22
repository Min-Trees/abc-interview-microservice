package com.auth.service.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class TokenResponse {
    private String accessToken;
    private String tokenType;
    private String refreshToken;
    private long expiresIn;
    private String verifyToken; // Thêm verify token

    public TokenResponse(String accessToken, String tokenType, String refreshToken, long expiresIn) {
        this.accessToken = accessToken;
        this.tokenType = tokenType;
        this.refreshToken = refreshToken;
        this.expiresIn = expiresIn;
    }

    // Constructor với verify token
    public TokenResponse(String accessToken, String tokenType, String refreshToken, long expiresIn, String verifyToken) {
        this.accessToken = accessToken;
        this.tokenType = tokenType;
        this.refreshToken = refreshToken;
        this.expiresIn = expiresIn;
        this.verifyToken = verifyToken;
    }
}