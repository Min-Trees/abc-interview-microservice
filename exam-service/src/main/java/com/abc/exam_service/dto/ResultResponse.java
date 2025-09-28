package com.abc.exam_service.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ResultResponse {
    private Long id;
    private Long examId;
    private Long userId;
    private Double score;
    private Boolean passStatus;
    private String feedback;
    private LocalDateTime completedAt;
}
