package com.abc.news_service.service;

import com.abc.news_service.dto.*;
import com.abc.news_service.entity.News;
import com.abc.news_service.mapper.NewsMapper;
import com.abc.news_service.repository.NewsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class NewsService {
    private final NewsRepository newsRepository;
    private final NewsMapper newsMapper;

    public NewsResponse createNews(NewsRequest req) {
        News news = newsMapper.toEntity(req);
        news.setStatus("PENDING");
        news.setCreatedAt(LocalDateTime.now());
        news.setUsefulVote(0);
        news.setInterestVote(0);
        return newsMapper.toResponse(newsRepository.save(news));
    }

    public NewsResponse approveNews(Long newsId, Long adminId) {
        News news = newsRepository.findById(newsId).orElseThrow();
        news.setStatus("APPROVED");
        news.setApprovedBy(adminId);
        news.setPublishedAt(LocalDateTime.now());
        // Set expiration to 48 hours for news, no expiration for recruitment
        if ("NEWS".equals(news.getNewsType())) {
            news.setExpiredAt(LocalDateTime.now().plusHours(48));
        }
        return newsMapper.toResponse(newsRepository.save(news));
    }

    public NewsResponse rejectNews(Long newsId, Long adminId) {
        News news = newsRepository.findById(newsId).orElseThrow();
        news.setStatus("REJECTED");
        news.setApprovedBy(adminId);
        return newsMapper.toResponse(newsRepository.save(news));
    }

    public NewsResponse publishNews(Long newsId) {
        News news = newsRepository.findById(newsId).orElseThrow();
        if (!"APPROVED".equals(news.getStatus())) {
            throw new RuntimeException("Only approved news can be published");
        }
        news.setStatus("PUBLISHED");
        return newsMapper.toResponse(newsRepository.save(news));
    }

    public NewsResponse voteNews(Long newsId, String voteType) {
        News news = newsRepository.findById(newsId).orElseThrow();
        if ("USEFUL".equals(voteType)) {
            news.setUsefulVote((news.getUsefulVote() != null ? news.getUsefulVote() : 0) + 1);
        } else if ("INTEREST".equals(voteType)) {
            news.setInterestVote((news.getInterestVote() != null ? news.getInterestVote() : 0) + 1);
        }
        return newsMapper.toResponse(newsRepository.save(news));
    }

    public Page<NewsResponse> listNewsByType(String newsType, Pageable pageable) {
        return newsRepository.findByNewsType(newsType, pageable).map(newsMapper::toResponse);
    }

    public Page<NewsResponse> listNewsByUser(Long userId, Pageable pageable) {
        return newsRepository.findByUserId(userId, pageable).map(newsMapper::toResponse);
    }

    public Page<NewsResponse> listNewsByStatus(String status, Pageable pageable) {
        return newsRepository.findByStatus(status, pageable).map(newsMapper::toResponse);
    }

    public Page<NewsResponse> listNewsByField(Long fieldId, Pageable pageable) {
        return newsRepository.findByFieldId(fieldId, pageable).map(newsMapper::toResponse);
    }

    public Page<NewsResponse> listPublishedNews(String newsType, Pageable pageable) {
        return newsRepository.findByNewsTypeAndStatus(newsType, "PUBLISHED", pageable).map(newsMapper::toResponse);
    }

    public Page<NewsResponse> listPendingModeration(Pageable pageable) {
        return newsRepository.findByStatus("PENDING", pageable).map(newsMapper::toResponse);
    }

    public NewsResponse getNewsById(Long id) {
        return newsMapper.toResponse(newsRepository.findById(id).orElseThrow());
    }

    public NewsResponse updateNews(Long id, NewsRequest req) {
        News news = newsRepository.findById(id).orElseThrow();
        if (!"PENDING".equals(news.getStatus())) {
            throw new RuntimeException("Only pending news can be updated");
        }
        news.setTitle(req.getTitle());
        news.setContent(req.getContent());
        news.setFieldId(req.getFieldId());
        news.setExamId(req.getExamId());
        news.setCompanyName(req.getCompanyName());
        news.setLocation(req.getLocation());
        news.setSalary(req.getSalary());
        news.setExperience(req.getExperience());
        news.setPosition(req.getPosition());
        news.setWorkingHours(req.getWorkingHours());
        news.setDeadline(req.getDeadline());
        news.setApplicationMethod(req.getApplicationMethod());
        return newsMapper.toResponse(newsRepository.save(news));
    }

    public void deleteNews(Long id) {
        newsRepository.deleteById(id);
    }
}
