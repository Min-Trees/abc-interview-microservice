package com.abc.exam_service.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@Table(name = "user_answers")
public class UserAnswer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "exam_id")
    private Exam exam;
    private Long questionId;
    private Long userId;
    @Column(columnDefinition = "text")
    private String answerContent;
    private Boolean isCorrect;
    private Double similarityScore;
    private LocalDateTime createdAt;
}
