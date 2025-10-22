package com.abc.news_service.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class NewsResponse {
    private Long id;
    private Long userId;
    private String title;
    private String content;
    private Long fieldId;
    private Long examId;
    private String newsType;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime publishedAt;
    private LocalDateTime expiredAt;
    private Long approvedBy;
    private Integer usefulVote;
    private Integer interestVote;
    private String companyName;
    private String location;
    private String salary;
    private String experience;
    private String position;
    private String workingHours;
    private String deadline;
    private String applicationMethod;
}
