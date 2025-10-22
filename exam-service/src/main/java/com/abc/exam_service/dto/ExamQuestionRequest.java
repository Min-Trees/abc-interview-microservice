package com.abc.exam_service.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ExamQuestionRequest {
    @NotNull(message = "Exam ID is required")
    private Long examId;
    
    @NotNull(message = "Question ID is required")
    private Long questionId;
    
    private Integer orderNumber;
}
