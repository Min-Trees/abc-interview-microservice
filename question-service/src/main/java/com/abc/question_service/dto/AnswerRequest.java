package com.abc.question_service.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AnswerRequest {
    @NotNull(message = "User ID is required")
    private Long userId;
    
    @NotNull(message = "Question ID is required")
    private Long questionId;
    
    @NotNull(message = "Question type ID is required")
    private Long questionTypeId;
    
    @NotBlank(message = "Answer content is required")
    @Size(max = 5000, message = "Content must not exceed 5000 characters")
    private String content;
    
    private Boolean isCorrect;
    private Boolean isSampleAnswer;
    private Integer orderNumber;
}
