package com.abc.question_service.dto;

import lombok.Data;

@Data
public class TopicResponse {
    private Long id;
    private Long fieldId;
    private String name;
    private String description;
}
