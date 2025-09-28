package com.abc.news_service.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@Table(name = "news")
public class News {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private Long userId;
    private String title;
    @Column(columnDefinition = "text")
    private String content;
    private Long fieldId;
    private Long examId; // Link to exam if recruitment news
    private String newsType; // NEWS, RECRUITMENT
    private String status; // PENDING, APPROVED, REJECTED, PUBLISHED, EXPIRED
    private LocalDateTime createdAt;
    private LocalDateTime publishedAt;
    private LocalDateTime expiredAt;
    private Long approvedBy;
    private Integer usefulVote;
    private Integer interestVote; // For recruitment news
    private String companyName;
    private String location;
    private String salary;
    private String experience;
    private String position;
    private String workingHours;
    private String deadline;
    private String applicationMethod;
}
