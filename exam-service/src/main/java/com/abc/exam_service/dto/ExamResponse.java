package com.abc.exam_service.dto;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class ExamResponse {
    private Long id;
    private Long userId;
    private String examType;
    private String title;
    private String position;
    private List<Long> topics;
    private List<Long> questionTypes;
    private Integer questionCount;
    private Integer duration;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String status;
    private String language;
    private LocalDateTime createdAt;
    private Long createdBy;
}
