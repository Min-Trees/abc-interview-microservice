package com.abc.question_service.controller;

import com.abc.question_service.dto.*;
import com.abc.question_service.service.QuestionService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/questions")
@RequiredArgsConstructor
public class QuestionController {
    private final QuestionService svc;

    // Taxonomy CRUD (ADMIN)
    @PostMapping("/fields")
    public FieldResponse createField(@RequestBody FieldRequest req) { return svc.createField(req); }
    
    @GetMapping("/fields")
    public Page<FieldResponse> getAllFields(Pageable pageable) { return svc.getAllFields(pageable); }
    
    @GetMapping("/fields/{id}")
    public FieldResponse getFieldById(@PathVariable Long id) { return svc.getFieldById(id); }
    
    @PutMapping("/fields/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public FieldResponse updateField(@PathVariable Long id, @RequestBody FieldRequest req) { return svc.updateField(id, req); }
    
    @DeleteMapping("/fields/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public void deleteField(@PathVariable Long id) { svc.deleteField(id); }
    
    @PostMapping("/topics")
    @PreAuthorize("hasRole('ADMIN')")
    public TopicResponse createTopic(@RequestBody TopicRequest req) { return svc.createTopic(req); }
    
    @GetMapping("/topics")
    public Page<TopicResponse> getAllTopics(Pageable pageable) { return svc.getAllTopics(pageable); }
    
    @GetMapping("/topics/{id}")
    public TopicResponse getTopicById(@PathVariable Long id) { return svc.getTopicById(id); }
    
    @PutMapping("/topics/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public TopicResponse updateTopic(@PathVariable Long id, @RequestBody TopicRequest req) { return svc.updateTopic(id, req); }
    
    @DeleteMapping("/topics/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public void deleteTopic(@PathVariable Long id) { svc.deleteTopic(id); }
    
    @PostMapping("/levels")
    @PreAuthorize("hasRole('ADMIN')")
    public LevelResponse createLevel(@RequestBody LevelRequest req) { return svc.createLevel(req); }
    
    @GetMapping("/levels")
    public Page<LevelResponse> getAllLevels(Pageable pageable) { return svc.getAllLevels(pageable); }
    
    @GetMapping("/levels/{id}")
    public LevelResponse getLevelById(@PathVariable Long id) { return svc.getLevelById(id); }
    
    @PutMapping("/levels/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public LevelResponse updateLevel(@PathVariable Long id, @RequestBody LevelRequest req) { return svc.updateLevel(id, req); }
    
    @DeleteMapping("/levels/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public void deleteLevel(@PathVariable Long id) { svc.deleteLevel(id); }
    
    @PostMapping("/question-types")
    @PreAuthorize("hasRole('ADMIN')")
    public QuestionTypeResponse createQuestionType(@RequestBody QuestionTypeRequest req) { return svc.createQuestionType(req); }
    
    @GetMapping("/question-types")
    public Page<QuestionTypeResponse> getAllQuestionTypes(Pageable pageable) { return svc.getAllQuestionTypes(pageable); }
    
    @GetMapping("/question-types/{id}")
    public QuestionTypeResponse getQuestionTypeById(@PathVariable Long id) { return svc.getQuestionTypeById(id); }
    
    @PutMapping("/question-types/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public QuestionTypeResponse updateQuestionType(@PathVariable Long id, @RequestBody QuestionTypeRequest req) { return svc.updateQuestionType(id, req); }
    
    @DeleteMapping("/question-types/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public void deleteQuestionType(@PathVariable Long id) { svc.deleteQuestionType(id); }

    // Question lifecycle
    @PostMapping("/questions")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public QuestionResponse createQuestion(@RequestBody QuestionRequest req) { return svc.createQuestion(req); }

    @GetMapping
    public Page<QuestionResponse> getAllQuestions(Pageable pageable) { 
        return svc.getAllQuestions(pageable); 
    }
    
    @GetMapping("/questions/{id}")
    public QuestionResponse getQuestionById(@PathVariable Long id) { return svc.getQuestionById(id); }
    
    @PutMapping("/questions/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public QuestionResponse updateQuestion(@PathVariable Long id, @RequestBody QuestionRequest req) { 
        return svc.updateQuestion(id, req); 
    }

    @DeleteMapping("/questions/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public void deleteQuestion(@PathVariable Long id) { 
        svc.deleteQuestion(id); 
    }

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

    @GetMapping("/answers")
    public Page<AnswerResponse> getAllAnswers(Pageable pageable) { return svc.getAllAnswers(pageable); }
    
    @GetMapping("/answers/{id}")
    public AnswerResponse getAnswerById(@PathVariable Long id) { return svc.getAnswerById(id); }
    
    @PutMapping("/answers/{id}")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public AnswerResponse updateAnswer(@PathVariable Long id, @RequestBody AnswerRequest req) { return svc.updateAnswer(id, req); }

    @DeleteMapping("/answers/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public void deleteAnswer(@PathVariable Long id) { svc.deleteAnswer(id); }

    @PostMapping("/answers/{id}/sample")
    @PreAuthorize("hasRole('ADMIN')")
    public AnswerResponse markSample(@PathVariable Long id, @RequestParam boolean isSample) { return svc.markSampleAnswer(id, isSample); }

    @GetMapping("/questions/{questionId}/answers")
    public Page<AnswerResponse> listAnswers(@PathVariable Long questionId, Pageable pageable) { return svc.listAnswersByQuestion(questionId, pageable); }
}