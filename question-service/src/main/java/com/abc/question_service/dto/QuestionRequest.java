package com.abc.question_service.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class QuestionRequest {
    @NotNull(message = "User ID is required")
    private Long userId;
    
    @NotNull(message = "Topic ID is required")
    private Long topicId;
    
    @NotNull(message = "Field ID is required")
    private Long fieldId;
    
    @NotNull(message = "Level ID is required")
    private Long levelId;
    
    @NotNull(message = "Question type ID is required")
    private Long questionTypeId;
    
    @NotBlank(message = "Question content is required")
    @Size(max = 5000, message = "Content must not exceed 5000 characters")
    private String content;
    
    @NotBlank(message = "Answer is required")
    @Size(max = 5000, message = "Answer must not exceed 5000 characters")
    private String answer;
    
    @NotBlank(message = "Language is required")
    private String language;
}
