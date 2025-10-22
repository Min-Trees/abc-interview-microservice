package com.abc.news_service.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class NewsRequest {
    @NotNull(message = "User ID is required")
    private Long userId;
    
    @NotBlank(message = "Title is required")
    @Size(max = 200, message = "Title must not exceed 200 characters")
    private String title;
    
    @NotBlank(message = "Content is required")
    @Size(max = 10000, message = "Content must not exceed 10000 characters")
    private String content;
    
    private Long fieldId;
    private Long examId;
    
    @NotBlank(message = "News type is required")
    private String newsType;
    
    // Recruitment-specific fields (optional)
    private String companyName;
    private String location;
    private String salary;
    private String experience;
    private String position;
    private String workingHours;
    private String deadline;
    private String applicationMethod;
}
