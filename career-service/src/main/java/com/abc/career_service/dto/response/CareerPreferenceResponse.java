package com.abc.career_service.dto.response;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class CareerPreferenceResponse {
    private Long id;
    private Long userId;
    private Long fieldId;
    private Long topicId;
    private LocalDateTime createdAt;
}