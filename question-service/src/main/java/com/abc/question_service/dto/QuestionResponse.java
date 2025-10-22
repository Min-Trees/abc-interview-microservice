package com.abc.question_service.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
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
    
    // Relationship names for better API response
    private String fieldName;
    private String topicName;
    private String levelName;
    private String questionTypeName;
}
