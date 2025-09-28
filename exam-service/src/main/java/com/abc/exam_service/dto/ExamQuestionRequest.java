package com.abc.exam_service.dto;

import lombok.Data;

@Data
public class ExamQuestionRequest {
    private Long examId;
    private Long questionId;
    private Integer orderNumber;
}
