package com.abc.exam_service.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ExamRegistrationResponse {
    private Long id;
    private Long examId;
    private Long userId;
    private String registrationStatus;
    private LocalDateTime registeredAt;
}
