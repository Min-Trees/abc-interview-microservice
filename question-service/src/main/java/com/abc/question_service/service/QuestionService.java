package com.abc.question_service.service;

import com.abc.question_service.dto.*;
import com.abc.question_service.entity.*;
import com.abc.question_service.mapper.Mappers;
import com.abc.question_service.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class QuestionService {
    private final FieldRepository fieldRepository;
    private final TopicRepository topicRepository;
    private final LevelRepository levelRepository;
    private final QuestionTypeRepository questionTypeRepository;
    private final QuestionRepository questionRepository;
    private final AnswerRepository answerRepository;
    private final Mappers mappers;

    // Field CRUD
    public FieldResponse createField(FieldRequest req) { 
        return mappers.toResponse(fieldRepository.save(mappers.toEntity(req))); 
    }
    
    public Page<FieldResponse> getAllFields(Pageable pageable) { 
        return fieldRepository.findAll(pageable).map(mappers::toResponse); 
    }
    
    public FieldResponse getFieldById(Long id) {
        Field field = fieldRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Field not found with id: " + id));
        return mappers.toResponse(field);
    }
    
    @Transactional
    public FieldResponse updateField(Long id, FieldRequest req) {
        Field field = fieldRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Field not found with id: " + id));
        field.setName(req.getName());
        field.setDescription(req.getDescription());
        return mappers.toResponse(fieldRepository.save(field));
    }
    
    public void deleteField(Long id) {
        if (!fieldRepository.existsById(id)) {
            throw new RuntimeException("Field not found with id: " + id);
        }
        fieldRepository.deleteById(id);
    }
    
    // Topic CRUD
    public TopicResponse createTopic(TopicRequest req) { 
        return mappers.toResponse(topicRepository.save(mappers.toEntity(req))); 
    }
    
    public Page<TopicResponse> getAllTopics(Pageable pageable) { 
        return topicRepository.findAll(pageable).map(mappers::toResponse); 
    }
    
    public TopicResponse getTopicById(Long id) {
        Topic topic = topicRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Topic not found with id: " + id));
        return mappers.toResponse(topic);
    }
    
    public TopicResponse updateTopic(Long id, TopicRequest req) {
        Topic topic = topicRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Topic not found with id: " + id));
        topic.setName(req.getName());
        topic.setDescription(req.getDescription());
        topic.setField(fieldRepository.findById(req.getFieldId())
                .orElseThrow(() -> new RuntimeException("Field not found with id: " + req.getFieldId())));
        return mappers.toResponse(topicRepository.save(topic));
    }
    
    public void deleteTopic(Long id) {
        if (!topicRepository.existsById(id)) {
            throw new RuntimeException("Topic not found with id: " + id);
        }
        topicRepository.deleteById(id);
    }
    
    // Level CRUD
    public LevelResponse createLevel(LevelRequest req) { 
        return mappers.toResponse(levelRepository.save(mappers.toEntity(req))); 
    }
    
    public Page<LevelResponse> getAllLevels(Pageable pageable) { 
        return levelRepository.findAll(pageable).map(mappers::toResponse); 
    }
    
    public LevelResponse getLevelById(Long id) {
        Level level = levelRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Level not found with id: " + id));
        return mappers.toResponse(level);
    }
    
    public LevelResponse updateLevel(Long id, LevelRequest req) {
        Level level = levelRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Level not found with id: " + id));
        level.setName(req.getName());
        level.setDescription(req.getDescription());
        level.setMinScore(req.getMinScore());
        level.setMaxScore(req.getMaxScore());
        return mappers.toResponse(levelRepository.save(level));
    }
    
    public void deleteLevel(Long id) {
        if (!levelRepository.existsById(id)) {
            throw new RuntimeException("Level not found with id: " + id);
        }
        levelRepository.deleteById(id);
    }
    
    // QuestionType CRUD
    public QuestionTypeResponse createQuestionType(QuestionTypeRequest req) { 
        return mappers.toResponse(questionTypeRepository.save(mappers.toEntity(req))); 
    }
    
    public Page<QuestionTypeResponse> getAllQuestionTypes(Pageable pageable) { 
        return questionTypeRepository.findAll(pageable).map(mappers::toResponse); 
    }
    
    public QuestionTypeResponse getQuestionTypeById(Long id) {
        QuestionType questionType = questionTypeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("QuestionType not found with id: " + id));
        return mappers.toResponse(questionType);
    }
    
    public QuestionTypeResponse updateQuestionType(Long id, QuestionTypeRequest req) {
        QuestionType questionType = questionTypeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("QuestionType not found with id: " + id));
        questionType.setName(req.getName());
        questionType.setDescription(req.getDescription());
        return mappers.toResponse(questionTypeRepository.save(questionType));
    }
    
    public void deleteQuestionType(Long id) {
        if (!questionTypeRepository.existsById(id)) {
            throw new RuntimeException("QuestionType not found with id: " + id);
        }
        questionTypeRepository.deleteById(id);
    }

    // Question CRUD
    public QuestionResponse createQuestion(QuestionRequest req) {
        Question q = mappers.toEntity(req);
        q.setStatus("PENDING");
        q.setUsefulVote(0);
        q.setUnusefulVote(0);
        q.setCreatedAt(LocalDateTime.now());
        return mappers.toResponse(questionRepository.save(q));
    }

    @Transactional(readOnly = true)
    public Page<QuestionResponse> getAllQuestions(Pageable pageable) {
        return questionRepository.findAll(pageable).map(this::loadQuestionRelationships);
    }
    
    private QuestionResponse loadQuestionRelationships(Question question) {
        // Force load relationships
        if (question.getField() != null) {
            question.getField().getName();
        }
        if (question.getTopic() != null) {
            question.getTopic().getName();
        }
        if (question.getLevel() != null) {
            question.getLevel().getName();
        }
        if (question.getQuestionType() != null) {
            question.getQuestionType().getName();
        }
        return mappers.toResponse(question);
    }
    
    public QuestionResponse getQuestionById(Long id) {
        Question question = questionRepository.findByIdWithRelationships(id);
        if (question == null) {
            throw new RuntimeException("Question not found with id: " + id);
        }
        return mappers.toResponse(question);
    }
    
    public QuestionResponse updateQuestion(Long id, QuestionRequest req) {
        Question question = questionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Question not found with id: " + id));
        question.setUserId(req.getUserId());
        question.setQuestionContent(req.getContent());
        question.setQuestionAnswer(req.getAnswer());
        question.setLanguage(req.getLanguage());
        question.setTopic(topicRepository.findById(req.getTopicId())
                .orElseThrow(() -> new RuntimeException("Topic not found with id: " + req.getTopicId())));
        question.setField(fieldRepository.findById(req.getFieldId())
                .orElseThrow(() -> new RuntimeException("Field not found with id: " + req.getFieldId())));
        question.setLevel(levelRepository.findById(req.getLevelId())
                .orElseThrow(() -> new RuntimeException("Level not found with id: " + req.getLevelId())));
        question.setQuestionType(questionTypeRepository.findById(req.getQuestionTypeId())
                .orElseThrow(() -> new RuntimeException("QuestionType not found with id: " + req.getQuestionTypeId())));
        return mappers.toResponse(questionRepository.save(question));
    }
    
    public void deleteQuestion(Long id) {
        if (!questionRepository.existsById(id)) {
            throw new RuntimeException("Question not found with id: " + id);
        }
        questionRepository.deleteById(id);
    }

    public QuestionResponse approveQuestion(Long id, Long adminId) {
        Question q = questionRepository.findByIdWithRelationships(id);
        if (q == null) {
            throw new RuntimeException("Question not found with id: " + id);
        }
        q.setStatus("APPROVED");
        q.setApprovedBy(adminId);
        q.setApprovedAt(LocalDateTime.now());
        return mappers.toResponse(questionRepository.save(q));
    }

    public QuestionResponse rejectQuestion(Long id, Long adminId) {
        Question q = questionRepository.findByIdWithRelationships(id);
        if (q == null) {
            throw new RuntimeException("Question not found with id: " + id);
        }
        q.setStatus("REJECTED");
        q.setApprovedBy(adminId);
        q.setApprovedAt(LocalDateTime.now());
        return mappers.toResponse(questionRepository.save(q));
    }
    
    @Transactional(readOnly = true)
    public Page<QuestionResponse> listQuestionsByTopic(Long topicId, Pageable pageable) {
        return questionRepository.findByTopicId(topicId, pageable).map(this::loadQuestionRelationships);
    }

    // Answer CRUD
    public AnswerResponse createAnswer(AnswerRequest req) {
        Answer a = mappers.toEntity(req);
        a.setUsefulVote(0);
        a.setUnusefulVote(0);
        a.setCreatedAt(LocalDateTime.now());
        return mappers.toResponse(answerRepository.save(a));
    }

    public Page<AnswerResponse> getAllAnswers(Pageable pageable) {
        return answerRepository.findAll(pageable).map(mappers::toResponse);
    }
    
    public AnswerResponse getAnswerById(Long id) {
        Answer answer = answerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Answer not found with id: " + id));
        return mappers.toResponse(answer);
    }
    
    public AnswerResponse updateAnswer(Long id, AnswerRequest req) {
        Answer answer = answerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Answer not found with id: " + id));
        answer.setContent(req.getContent());
        answer.setIsCorrect(req.getIsCorrect());
        answer.setQuestion(questionRepository.findById(req.getQuestionId())
                .orElseThrow(() -> new RuntimeException("Question not found with id: " + req.getQuestionId())));
        answer.setQuestionType(questionTypeRepository.findById(req.getQuestionTypeId())
                .orElseThrow(() -> new RuntimeException("QuestionType not found with id: " + req.getQuestionTypeId())));
        return mappers.toResponse(answerRepository.save(answer));
    }
    
    public void deleteAnswer(Long id) {
        if (!answerRepository.existsById(id)) {
            throw new RuntimeException("Answer not found with id: " + id);
        }
        answerRepository.deleteById(id);
    }

    public AnswerResponse markSampleAnswer(Long id, boolean isSample) {
        Answer a = answerRepository.findById(id).orElseThrow();
        a.setIsSampleAnswer(isSample);
        return mappers.toResponse(answerRepository.save(a));
    }

    public Page<AnswerResponse> listAnswersByQuestion(Long questionId, Pageable pageable) {
        return answerRepository.findByQuestionId(questionId, pageable).map(mappers::toResponse);
    }
}