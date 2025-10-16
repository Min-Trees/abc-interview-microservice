package com.abc.question_service.dto;

import lombok.Data;

@Data
public class AnswerRequest {
    private Long userId;
    private Long questionId;
    private Long questionTypeId;
    private String content;
    private Boolean isCorrect;
    private Boolean isSampleAnswer;
    private Integer orderNumber;
}
