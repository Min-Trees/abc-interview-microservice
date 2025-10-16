package com.abc.user_service.exception;

import lombok.Getter;

import java.util.Map;

@Getter
public class InvalidRequestException extends RuntimeException {
    private final Map<String, String> details;

    public InvalidRequestException(String message, Map<String, String> details) {
        super(message);
        this.details = details;
    }

    public InvalidRequestException(String message) {
        super(message);
        this.details = null;
    }
}



