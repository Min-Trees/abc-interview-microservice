package com.abc.exam_service.repository;

import com.abc.exam_service.entity.Result;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ResultRepository extends JpaRepository<Result, Long> {
    Page<Result> findByExamId(Long examId, Pageable pageable);
    Page<Result> findByUserId(Long userId, Pageable pageable);
}
