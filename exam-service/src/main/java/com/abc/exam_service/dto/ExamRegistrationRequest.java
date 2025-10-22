package com.abc.exam_service.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ExamRegistrationRequest {
    @NotNull(message = "Exam ID is required")
    private Long examId;
    
    @NotNull(message = "User ID is required")
    private Long userId;
    
    private String registrationStatus;
}
