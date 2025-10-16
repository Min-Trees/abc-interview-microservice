package com.auth.service.exception;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ErrorResponse {
    private String type;           // URI reference that identifies the problem type
    private String title;          // Short, human-readable summary
    private int status;            // HTTP status code
    private String detail;         // Human-readable explanation
    private String instance;       // URI reference that identifies the specific occurrence
    private String errorCode;      // Application-specific error code
    private String traceId;        // Unique identifier for tracing
    private Instant timestamp;     // ISO 8601 timestamp
    private Map<String, String> details; // Additional details (validation errors, etc.)
    
    public static ErrorResponse create(int status, String title, String detail, String instance, String errorCode) {
        return ErrorResponse.builder()
                .type("https://errors.abc.com/" + errorCode)
                .title(title)
                .status(status)
                .detail(detail)
                .instance(instance)
                .errorCode(errorCode)
                .traceId(UUID.randomUUID().toString())
                .timestamp(Instant.now())
                .build();
    }
}
