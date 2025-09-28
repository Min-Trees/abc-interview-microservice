package com.abc.exam_service.repository;

import com.abc.exam_service.entity.Exam;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ExamRepository extends JpaRepository<Exam, Long> {
    Page<Exam> findByUserId(Long userId, Pageable pageable);
    Page<Exam> findByExamType(String examType, Pageable pageable);
}
