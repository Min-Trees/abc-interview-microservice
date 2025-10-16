package com.abc.question_service.dto;

import lombok.Data;

@Data
public class QuestionRequest {
    private Long userId;
    private Long topicId;
    private Long fieldId;
    private Long levelId;
    private Long questionTypeId;
    private String content;  // Changed from questionContent to content
    private String answer;   // Changed from questionAnswer to answer
    private String language;
}
