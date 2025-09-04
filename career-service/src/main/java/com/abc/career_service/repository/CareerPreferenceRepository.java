package com.abc.career_service.repository;

import com.abc.career_service.entity.CareerPreference;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CareerPreferenceRepository extends JpaRepository<CareerPreference,Long> {
    List<CareerPreference> findByUserId(Long userId);
    Page<CareerPreference> findByUserId(Long userId, Pageable pageable);
}
