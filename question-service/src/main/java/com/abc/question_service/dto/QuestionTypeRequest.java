package com.abc.question_service.dto;

import lombok.Data;

@Data
public class QuestionTypeRequest {
    private String questionTypeName;
    private String description;
}
