package com.abc.news_service.controller;

import com.abc.news_service.dto.*;
import com.abc.news_service.service.NewsService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/news")
@RequiredArgsConstructor
public class NewsController {
    private final NewsService newsService;

    @PostMapping
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN') or hasRole('RECRUITER')")
    public NewsResponse createNews(@RequestBody NewsRequest req) {
        return newsService.createNews(req);
    }

    @GetMapping("/{id}")
    public NewsResponse getNewsById(@PathVariable Long id) {
        return newsService.getNewsById(id);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN') or hasRole('RECRUITER')")
    public NewsResponse updateNews(@PathVariable Long id, @RequestBody NewsRequest req) {
        return newsService.updateNews(id, req);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('RECRUITER')")
    public void deleteNews(@PathVariable Long id) {
        newsService.deleteNews(id);
    }

    @PostMapping("/{newsId}/approve")
    @PreAuthorize("hasRole('ADMIN')")
    public NewsResponse approveNews(@PathVariable Long newsId, @RequestParam Long adminId) {
        return newsService.approveNews(newsId, adminId);
    }

    @PostMapping("/{newsId}/reject")
    @PreAuthorize("hasRole('ADMIN')")
    public NewsResponse rejectNews(@PathVariable Long newsId, @RequestParam Long adminId) {
        return newsService.rejectNews(newsId, adminId);
    }

    @PostMapping("/{newsId}/publish")
    @PreAuthorize("hasRole('ADMIN')")
    public NewsResponse publishNews(@PathVariable Long newsId) {
        return newsService.publishNews(newsId);
    }

    @PostMapping("/{newsId}/vote")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public NewsResponse voteNews(@PathVariable Long newsId, @RequestParam String voteType) {
        return newsService.voteNews(newsId, voteType);
    }

    @GetMapping("/type/{newsType}")
    public Page<NewsResponse> listNewsByType(@PathVariable String newsType, Pageable pageable) {
        return newsService.listNewsByType(newsType, pageable);
    }

    @GetMapping("/user/{userId}")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN') or hasRole('RECRUITER')")
    public Page<NewsResponse> listNewsByUser(@PathVariable Long userId, Pageable pageable) {
        return newsService.listNewsByUser(userId, pageable);
    }

    @GetMapping("/status/{status}")
    @PreAuthorize("hasRole('ADMIN')")
    public Page<NewsResponse> listNewsByStatus(@PathVariable String status, Pageable pageable) {
        return newsService.listNewsByStatus(status, pageable);
    }

    @GetMapping("/field/{fieldId}")
    public Page<NewsResponse> listNewsByField(@PathVariable Long fieldId, Pageable pageable) {
        return newsService.listNewsByField(fieldId, pageable);
    }

    @GetMapping("/published/{newsType}")
    public Page<NewsResponse> listPublishedNews(@PathVariable String newsType, Pageable pageable) {
        return newsService.listPublishedNews(newsType, pageable);
    }

    @GetMapping("/moderation/pending")
    @PreAuthorize("hasRole('ADMIN')")
    public Page<NewsResponse> listPendingModeration(Pageable pageable) {
        return newsService.listPendingModeration(pageable);
    }
}

@RestController
@RequestMapping("/recruitments")
@RequiredArgsConstructor
class RecruitmentController {
    private final NewsService newsService;

    @PostMapping
    @PreAuthorize("hasRole('RECRUITER') or hasRole('ADMIN')")
    public NewsResponse createRecruitment(@RequestBody NewsRequest req) {
        req.setNewsType("RECRUITMENT");
        return newsService.createNews(req);
    }

    @GetMapping
    public Page<NewsResponse> listRecruitments(Pageable pageable) {
        return newsService.listPublishedNews("RECRUITMENT", pageable);
    }

    @GetMapping("/company/{companyName}")
    public Page<NewsResponse> listRecruitmentsByCompany(@PathVariable String companyName, Pageable pageable) {
        // This would need a custom query in repository
        return newsService.listPublishedNews("RECRUITMENT", pageable);
    }
}
