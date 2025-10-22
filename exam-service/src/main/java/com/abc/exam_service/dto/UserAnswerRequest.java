package com.abc.exam_service.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UserAnswerRequest {
    @NotNull(message = "Exam ID is required")
    private Long examId;
    
    @NotNull(message = "Question ID is required")
    private Long questionId;
    
    @NotNull(message = "User ID is required")
    private Long userId;
    
    @NotBlank(message = "Answer content is required")
    @Size(max = 5000, message = "Answer must not exceed 5000 characters")
    private String answerContent;
    
    private Boolean isCorrect;
}
