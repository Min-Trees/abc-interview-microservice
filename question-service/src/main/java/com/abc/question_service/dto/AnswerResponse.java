package com.abc.question_service.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class AnswerResponse {
    private Long id;
    private Long userId;
    private Long questionId;
    private Long questionTypeId;
    private String answerContent;
    private Boolean isCorrect;
    private Double similarityScore;
    private Integer usefulVote;
    private Integer unusefulVote;
    private Boolean isSampleAnswer;
    private Integer orderNumber;
    private LocalDateTime createdAt;
}
