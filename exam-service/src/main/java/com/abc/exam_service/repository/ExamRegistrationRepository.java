package com.abc.exam_service.repository;

import com.abc.exam_service.entity.ExamRegistration;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ExamRegistrationRepository extends JpaRepository<ExamRegistration, Long> {
    boolean existsByExamIdAndUserId(Long examId, Long userId);
    Page<ExamRegistration> findByExamId(Long examId, Pageable pageable);
    Page<ExamRegistration> findByUserId(Long userId, Pageable pageable);
}
