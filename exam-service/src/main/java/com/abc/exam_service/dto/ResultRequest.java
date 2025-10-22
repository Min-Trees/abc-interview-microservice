package com.abc.exam_service.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ResultRequest {
    @NotNull(message = "Exam ID is required")
    private Long examId;
    
    @NotNull(message = "User ID is required")
    private Long userId;
    
    @NotNull(message = "Score is required")
    @DecimalMin(value = "0.0", message = "Score must be at least 0")
    @DecimalMax(value = "100.0", message = "Score must not exceed 100")
    private Double score;
    
    private Boolean passStatus;
    private String feedback;
}
