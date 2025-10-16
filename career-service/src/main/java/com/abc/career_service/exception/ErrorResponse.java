package com.abc.career_service.exception;

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
    private String type;
    private String title;
    private int status;
    private String detail;
    private String instance;
    private String errorCode;
    private String traceId;
    private Instant timestamp;
    private Map<String, String> details;
    
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



