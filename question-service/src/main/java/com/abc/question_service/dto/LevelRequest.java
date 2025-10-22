package com.abc.question_service.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class LevelRequest {
    @NotBlank(message = "Level name is required")
    @Size(max = 100, message = "Name must not exceed 100 characters")
    private String name;
    
    @Size(max = 500, message = "Description must not exceed 500 characters")
    private String description;
    
    private Integer minScore;
    private Integer maxScore;
}
