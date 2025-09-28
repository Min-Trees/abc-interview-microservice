package com.abc.question_service.mapper;

import com.abc.question_service.dto.*;
import com.abc.question_service.entity.*;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface Mappers {
    Field toEntity(FieldRequest req);
    @Mapping(target = "id", source = "id")
    FieldResponse toResponse(Field entity);

    @Mapping(target = "field.id", source = "fieldId")
    Topic toEntity(TopicRequest req);
    @Mapping(target = "fieldId", source = "field.id")
    TopicResponse toResponse(Topic entity);

    Level toEntity(LevelRequest req);
    LevelResponse toResponse(Level entity);

    QuestionType toEntity(QuestionTypeRequest req);
    QuestionTypeResponse toResponse(QuestionType entity);

    @Mapping(target = "topic.id", source = "topicId")
    @Mapping(target = "field.id", source = "fieldId")
    @Mapping(target = "level.id", source = "levelId")
    @Mapping(target = "questionType.id", source = "questionTypeId")
    Question toEntity(QuestionRequest req);
    @Mapping(target = "topicId", source = "topic.id")
    @Mapping(target = "fieldId", source = "field.id")
    @Mapping(target = "levelId", source = "level.id")
    @Mapping(target = "questionTypeId", source = "questionType.id")
    QuestionResponse toResponse(Question entity);

    @Mapping(target = "question.id", source = "questionId")
    @Mapping(target = "questionType.id", source = "questionTypeId")
    Answer toEntity(AnswerRequest req);
    @Mapping(target = "questionId", source = "question.id")
    @Mapping(target = "questionTypeId", source = "questionType.id")
    AnswerResponse toResponse(Answer entity);
}


