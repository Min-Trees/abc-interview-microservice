package com.abc.user_service.repository;

import com.abc.user_service.entity.User;
import com.abc.user_service.entity.UserStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    Optional<User> findByVerifyToken(String verifyToken);
    Page<User> findByRoleId(Long roleId, Pageable pageable);
    Page<User> findByStatus(UserStatus status, Pageable pageable);
    boolean existsByEmail(String email);
}