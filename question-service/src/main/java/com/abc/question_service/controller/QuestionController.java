package com.abc.question_service.controller;

import com.abc.question_service.dto.*;
import com.abc.question_service.service.QuestionService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping
@RequiredArgsConstructor
public class QuestionController {
    private final QuestionService svc;

    // Taxonomy CRUD (ADMIN)
    @PostMapping("/fields")
    @PreAuthorize("hasRole('ADMIN')")
    public FieldResponse createField(@RequestBody FieldRequest req) { return svc.createField(req); }
    @PostMapping("/topics")
    @PreAuthorize("hasRole('ADMIN')")
    public TopicResponse createTopic(@RequestBody TopicRequest req) { return svc.createTopic(req); }
    @PostMapping("/levels")
    @PreAuthorize("hasRole('ADMIN')")
    public LevelResponse createLevel(@RequestBody LevelRequest req) { return svc.createLevel(req); }
    @PostMapping("/question-types")
    @PreAuthorize("hasRole('ADMIN')")
    public QuestionTypeResponse createQuestionType(@RequestBody QuestionTypeRequest req) { return svc.createQuestionType(req); }

    // Question lifecycle
    @PostMapping("/questions")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public QuestionResponse createQuestion(@RequestBody QuestionRequest req) { return svc.createQuestion(req); }

    @PostMapping("/questions/{id}/approve")
    @PreAuthorize("hasRole('ADMIN')")
    public QuestionResponse approve(@PathVariable Long id, @RequestParam Long adminId) { return svc.approveQuestion(id, adminId); }

    @PostMapping("/questions/{id}/reject")
    @PreAuthorize("hasRole('ADMIN')")
    public QuestionResponse reject(@PathVariable Long id, @RequestParam Long adminId) { return svc.rejectQuestion(id, adminId); }

    @GetMapping("/topics/{topicId}/questions")
    public Page<QuestionResponse> listByTopic(@PathVariable Long topicId, Pageable pageable) { 
        return svc.listQuestionsByTopic(topicId, pageable); 
    }

    // Answers
    @PostMapping("/answers")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public AnswerResponse createAnswer(@RequestBody AnswerRequest req) { return svc.createAnswer(req); }

    @PostMapping("/answers/{id}/sample")
    @PreAuthorize("hasRole('ADMIN')")
    public AnswerResponse markSample(@PathVariable Long id, @RequestParam boolean isSample) { return svc.markSampleAnswer(id, isSample); }

    @GetMapping("/questions/{questionId}/answers")
    public Page<AnswerResponse> listAnswers(@PathVariable Long questionId, Pageable pageable) { return svc.listAnswersByQuestion(questionId, pageable); }

    // Additional CRUD endpoints
    @GetMapping("/questions/{id}")
    public QuestionResponse getQuestionById(@PathVariable Long id) { return svc.getQuestionById(id); }

    @PutMapping("/questions/{id}")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public QuestionResponse updateQuestion(@PathVariable Long id, @RequestBody QuestionRequest req) { return svc.updateQuestion(id, req); }

    @DeleteMapping("/questions/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public void deleteQuestion(@PathVariable Long id) { svc.deleteQuestion(id); }

    @GetMapping("/answers/{id}")
    public AnswerResponse getAnswerById(@PathVariable Long id) { return svc.getAnswerById(id); }

    @PutMapping("/answers/{id}")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public AnswerResponse updateAnswer(@PathVariable Long id, @RequestBody AnswerRequest req) { return svc.updateAnswer(id, req); }

    @DeleteMapping("/answers/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public void deleteAnswer(@PathVariable Long id) { svc.deleteAnswer(id); }
}


