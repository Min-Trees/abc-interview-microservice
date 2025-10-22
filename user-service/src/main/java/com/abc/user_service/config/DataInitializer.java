package com.abc.user_service.config;

import com.abc.user_service.entity.Role;
import com.abc.user_service.entity.RoleName;
import com.abc.user_service.entity.User;
import com.abc.user_service.entity.UserStatus;
import com.abc.user_service.repository.RoleRepository;
import com.abc.user_service.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
@RequiredArgsConstructor
public class DataInitializer {

    private final RoleRepository roleRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Bean
    CommandLineRunner initDatabase() {
        return args -> {
            // First, seed roles
            if (roleRepository.count() == 0) {
                for (RoleName rn : RoleName.values()) {
                    Role r = new Role();
                    r.setRoleName(rn);
                    r.setDescription(rn.name() + " role");
                    roleRepository.save(r);
                }
                System.out.println("Roles seeded successfully");
            }
            
            // Then, seed admin user
            if (!userRepository.findByEmail("admin@example.com").isPresent()) {
                Role adminRole = roleRepository.findByRoleName(RoleName.ADMIN)
                        .orElseThrow(() -> new RuntimeException("ADMIN role not found"));
                
                User admin = new User();
                admin.setEmail("admin@example.com");
                admin.setPassword(passwordEncoder.encode("admin123"));
                admin.setFullName("System Administrator");
                admin.setRole(adminRole);
                admin.setStatus(UserStatus.ACTIVE);
                admin.setEloScore(0);
                admin.setEloRank(com.abc.user_service.entity.EloRank.LEGEND);
                
                userRepository.save(admin);
                System.out.println("Admin user created: admin@example.com / admin123");
            }
        };
    }
}
