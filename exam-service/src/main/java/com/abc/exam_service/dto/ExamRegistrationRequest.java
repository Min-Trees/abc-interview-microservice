package com.abc.exam_service.dto;

import lombok.Data;

@Data
public class ExamRegistrationRequest {
    private Long examId;
    private Long userId;
    private String registrationStatus;
}
