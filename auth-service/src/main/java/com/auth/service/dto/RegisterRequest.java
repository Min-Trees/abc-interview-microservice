package com.auth.service.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDate;

@Data
public class RegisterRequest {
    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 6, max = 50, message = "Password must be between 6 and 50 characters")
    private String password;

    // Support both roleName and roleId
    @JsonProperty("roleName")
    private String roleName;
    
    @JsonProperty("roleId")
    private Long roleId;

    private String fullName;
    private LocalDate dateOfBirth;
    private String address;
    private Boolean isStudying;
    
    // Helper method to get role identifier
    public String getRoleIdentifier() {
        if (roleName != null && !roleName.isBlank()) {
            return roleName;
        }
        if (roleId != null) {
            return roleId.toString();
        }
        return null;
    }
}
