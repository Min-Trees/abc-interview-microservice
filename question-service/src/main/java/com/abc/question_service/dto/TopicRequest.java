package com.abc.question_service.dto;

import lombok.Data;

@Data
public class TopicRequest {
    private Long fieldId;
    private String name;
    private String description;
}
