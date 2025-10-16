package com.abc.question_service.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@Table(name = "answers")
public class Answer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private Long userId;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_id")
    private Question question;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_type_id")
    private QuestionType questionType;
    @Column(columnDefinition = "text")
    private String content;
    private Boolean isCorrect;
    private Double similarityScore;
    private Integer usefulVote;
    private Integer unusefulVote;
    private Boolean isSampleAnswer;
    private Integer orderNumber;
    private LocalDateTime createdAt;
}


