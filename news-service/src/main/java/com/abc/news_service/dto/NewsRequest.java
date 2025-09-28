package com.abc.news_service.dto;

import lombok.Data;

@Data
public class NewsRequest {
    private Long userId;
    private String title;
    private String content;
    private Long fieldId;
    private Long examId;
    private String newsType;
    private String companyName;
    private String location;
    private String salary;
    private String experience;
    private String position;
    private String workingHours;
    private String deadline;
    private String applicationMethod;
}
