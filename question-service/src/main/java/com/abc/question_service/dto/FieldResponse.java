package com.abc.question_service.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class FieldResponse {
    private Long id;
    private String name;
    private String description;
}
