package com.abc.exam_service.dto;

import lombok.Data;
import java.util.List;

@Data
public class ExamRequest {
    private Long userId;
    private String examType;
    private String title;
    private String position;
    private List<Long> topics;
    private List<Long> questionTypes;
    private Integer questionCount;
    private Integer duration;
    private String language;
}
