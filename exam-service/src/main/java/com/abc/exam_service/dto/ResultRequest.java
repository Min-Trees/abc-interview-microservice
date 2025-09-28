package com.abc.exam_service.dto;

import lombok.Data;

@Data
public class ResultRequest {
    private Long examId;
    private Long userId;
    private Double score;
    private Boolean passStatus;
    private String feedback;
}
