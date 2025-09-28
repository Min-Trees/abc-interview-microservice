package com.abc.exam_service.dto;

import lombok.Data;

@Data
public class ExamQuestionResponse {
    private Long id;
    private Long examId;
    private Long questionId;
    private Integer orderNumber;
}
