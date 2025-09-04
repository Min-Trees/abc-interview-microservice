package com.auth.service.dto;

import lombok.Data;

@Data
public class TokenResponse {
    private String accessToken;
    private String tokenType;
    private String refreshToken;
    private long expiresIn;

    public TokenResponse(String accessToken, String tokenType, String refreshToken, long expiresIn) {
        this.accessToken = accessToken;
        this.tokenType = tokenType;
        this.refreshToken = refreshToken;
        this.expiresIn = expiresIn;
    }
}