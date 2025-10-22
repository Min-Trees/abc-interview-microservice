package com.abc.exam_service.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ExamRegistrationResponse {
    private Long id;
    private Long examId;
    private Long userId;
    private String registrationStatus;
    private LocalDateTime registeredAt;
}
