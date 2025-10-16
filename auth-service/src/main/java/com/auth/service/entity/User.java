package com.auth.service.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "role_id", nullable = false)
    private Role role;

    @Column(name = "email", unique = true, nullable = false)
    private String email;

    @Column(name = "password", nullable = false)
    private String password;

    @Column(name = "full_name", length = 100)
    private String fullName;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    @Column(name = "address")
    private String address;

    @Column(name = "status", length = 50)
    private String status = "PENDING";

    @Column(name = "is_studying")
    private Boolean isStudying;

    @Column(name = "elo_score")
    private Integer eloScore = 0;

    @Column(name = "elo_rank", length = 50)
    private String eloRank = "NEWBIE";

    @Column(name = "verify_token")
    private String verifyToken;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
}



