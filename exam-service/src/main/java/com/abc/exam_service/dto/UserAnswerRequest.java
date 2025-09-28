package com.abc.exam_service.dto;

import lombok.Data;

@Data
public class UserAnswerRequest {
    private Long examId;
    private Long questionId;
    private Long userId;
    private String answerContent;
    private Boolean isCorrect;
}
