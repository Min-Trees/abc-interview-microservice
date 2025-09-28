package com.abc.question_service.service;

import com.abc.question_service.dto.*;
import com.abc.question_service.entity.*;
import com.abc.question_service.mapper.Mappers;
import com.abc.question_service.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

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

    public FieldResponse createField(FieldRequest req) { return mappers.toResponse(fieldRepository.save(mappers.toEntity(req))); }
    public TopicResponse createTopic(TopicRequest req) { return mappers.toResponse(topicRepository.save(mappers.toEntity(req))); }
    public LevelResponse createLevel(LevelRequest req) { return mappers.toResponse(levelRepository.save(mappers.toEntity(req))); }
    public QuestionTypeResponse createQuestionType(QuestionTypeRequest req) { return mappers.toResponse(questionTypeRepository.save(mappers.toEntity(req))); }

    public QuestionResponse createQuestion(QuestionRequest req) {
        Question q = mappers.toEntity(req);
        q.setStatus("PENDING");
        q.setUsefulVote(0);
        q.setUnusefulVote(0);
        q.setCreatedAt(LocalDateTime.now());
        return mappers.toResponse(questionRepository.save(q));
    }

    public QuestionResponse approveQuestion(Long id, Long adminId) {
        Question q = questionRepository.findById(id).orElseThrow();
        q.setStatus("APPROVED");
        q.setApprovedBy(adminId);
        q.setApprovedAt(LocalDateTime.now());
        return mappers.toResponse(questionRepository.save(q));
    }

    public QuestionResponse rejectQuestion(Long id, Long adminId) {
        Question q = questionRepository.findById(id).orElseThrow();
        q.setStatus("REJECTED");
        q.setApprovedBy(adminId);
        q.setApprovedAt(LocalDateTime.now());
        return mappers.toResponse(questionRepository.save(q));
    }

    public Page<QuestionResponse> listQuestionsByTopic(Long topicId, Pageable pageable) {
        return questionRepository.findByTopicId(topicId, pageable).map(mappers::toResponse);
    }

    public AnswerResponse createAnswer(AnswerRequest req) {
        Answer a = mappers.toEntity(req);
        a.setUsefulVote(0);
        a.setUnusefulVote(0);
        a.setCreatedAt(LocalDateTime.now());
        return mappers.toResponse(answerRepository.save(a));
    }

    public AnswerResponse markSampleAnswer(Long id, boolean isSample) {
        Answer a = answerRepository.findById(id).orElseThrow();
        a.setIsSampleAnswer(isSample);
        return mappers.toResponse(answerRepository.save(a));
    }

    public Page<AnswerResponse> listAnswersByQuestion(Long questionId, Pageable pageable) {
        return answerRepository.findByQuestionId(questionId, pageable).map(mappers::toResponse);
    }

    // Additional CRUD methods
    public QuestionResponse getQuestionById(Long id) {
        return mappers.toResponse(questionRepository.findById(id).orElseThrow());
    }

    public QuestionResponse updateQuestion(Long id, QuestionRequest req) {
        Question q = questionRepository.findById(id).orElseThrow();
        q.setQuestionContent(req.getQuestionContent());
        q.setQuestionAnswer(req.getQuestionAnswer());
        q.setLanguage(req.getLanguage());
        return mappers.toResponse(questionRepository.save(q));
    }

    public void deleteQuestion(Long id) {
        questionRepository.deleteById(id);
    }

    public AnswerResponse getAnswerById(Long id) {
        return mappers.toResponse(answerRepository.findById(id).orElseThrow());
    }

    public AnswerResponse updateAnswer(Long id, AnswerRequest req) {
        Answer a = answerRepository.findById(id).orElseThrow();
        a.setAnswerContent(req.getAnswerContent());
        a.setIsCorrect(req.getIsCorrect());
        return mappers.toResponse(answerRepository.save(a));
    }

    public void deleteAnswer(Long id) {
        answerRepository.deleteById(id);
    }
}


