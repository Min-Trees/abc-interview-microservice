package com.abc.career_service.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CareerPreferenceRequest {
    @NotNull(message = "User ID is required")
    private Long userId;
    
    @NotNull(message = "Field ID is required")
    private Long fieldId;
    
    @NotNull(message = "Topic ID is required")
    private Long topicId;
}