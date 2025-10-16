package com.abc.question_service.dto;

import lombok.Data;

@Data
public class LevelRequest {
    private String name;
    private String description;
    private Integer minScore;
    private Integer maxScore;
}
