package com.abc.exam_service.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class UserAnswerResponse {
    private Long id;
    private Long examId;
    private Long questionId;
    private Long userId;
    private String answerContent;
    private Boolean isCorrect;
    private Double similarityScore;
    private LocalDateTime createdAt;
}
