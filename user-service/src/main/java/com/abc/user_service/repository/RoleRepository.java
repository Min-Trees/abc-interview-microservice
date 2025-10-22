package com.abc.user_service.repository;

import com.abc.user_service.entity.Role;
import com.abc.user_service.entity.RoleName;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RoleRepository extends JpaRepository<Role, Long> {
    Optional<Role> findByRoleName(RoleName roleName);
}