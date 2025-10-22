package com.abc.exam_service.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ExamQuestionResponse {
    private Long id;
    private Long examId;
    private Long questionId;
    private Integer orderNumber;
}
