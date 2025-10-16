package com.abc.question_service.repository;

import com.abc.question_service.entity.Question;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface QuestionRepository extends JpaRepository<Question, Long> {
    Page<Question> findByTopicId(Long topicId, Pageable pageable);
    
    @Query("SELECT q FROM Question q " +
           "LEFT JOIN FETCH q.field " +
           "LEFT JOIN FETCH q.topic " +
           "LEFT JOIN FETCH q.level " +
           "LEFT JOIN FETCH q.questionType " +
           "WHERE q.id = :id")
    Question findByIdWithRelationships(@Param("id") Long id);
}
