package com.abc.exam_service.mapper;

import com.abc.exam_service.dto.*;
import com.abc.exam_service.entity.*;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

@Mapper(componentModel = "spring")
public abstract class Mappers {
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Mapping(target = "topics", expression = "java(convertListToString(req.getTopics()))")
    @Mapping(target = "questionTypes", expression = "java(convertListToString(req.getQuestionTypes()))")
    public abstract Exam toEntity(ExamRequest req);
    
    @Mapping(target = "topics", expression = "java(convertStringToList(entity.getTopics()))")
    @Mapping(target = "questionTypes", expression = "java(convertStringToList(entity.getQuestionTypes()))")
    public abstract ExamResponse toResponse(Exam entity);

    public abstract ExamQuestion toEntity(ExamQuestionRequest req);
    public abstract ExamQuestionResponse toResponse(ExamQuestion entity);

    public abstract Result toEntity(ResultRequest req);
    public abstract ResultResponse toResponse(Result entity);

    public abstract UserAnswer toEntity(UserAnswerRequest req);
    public abstract UserAnswerResponse toResponse(UserAnswer entity);

    public abstract ExamRegistration toEntity(ExamRegistrationRequest req);
    public abstract ExamRegistrationResponse toResponse(ExamRegistration entity);


    protected String convertListToString(java.util.List<Long> list) {
        if (list == null) return null;
        try {
            return objectMapper.writeValueAsString(list);
        } catch (JsonProcessingException e) {
            return "[]";
        }
    }
    
    protected java.util.List<Long> convertStringToList(String json) {
        if (json == null || json.isEmpty()) return java.util.List.of();
        try {
            return objectMapper.readValue(json, objectMapper.getTypeFactory().constructCollectionType(java.util.List.class, Long.class));
        } catch (JsonProcessingException e) {
            return java.util.List.of();
        }
    }
}
