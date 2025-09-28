package com.abc.question_service.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class QuestionResponse {
    private Long id;
    private Long userId;
    private Long topicId;
    private Long fieldId;
    private Long levelId;
    private Long questionTypeId;
    private String questionContent;
    private String questionAnswer;
    private Double similarityScore;
    private String status;
    private String language;
    private LocalDateTime createdAt;
    private LocalDateTime approvedAt;
    private Long approvedBy;
    private Integer usefulVote;
    private Integer unusefulVote;
}
