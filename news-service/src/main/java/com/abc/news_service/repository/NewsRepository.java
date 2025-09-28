package com.abc.news_service.repository;

import com.abc.news_service.entity.News;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface NewsRepository extends JpaRepository<News, Long> {
    Page<News> findByNewsType(String newsType, Pageable pageable);
    Page<News> findByUserId(Long userId, Pageable pageable);
    Page<News> findByStatus(String status, Pageable pageable);
    Page<News> findByFieldId(Long fieldId, Pageable pageable);
    Page<News> findByNewsTypeAndStatus(String newsType, String status, Pageable pageable);
}
