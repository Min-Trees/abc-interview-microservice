package com.abc.career_service.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class CareerPreferenceResponse {
    private Long id;
    private Long userId;
    private Long fieldId;
    private Long topicId;
    private LocalDateTime createdAt;
}