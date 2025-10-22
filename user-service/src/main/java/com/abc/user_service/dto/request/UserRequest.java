package com.abc.user_service.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDate;

@Data
public class UserRequest {
    // Either roleId or roleName must be provided
    private Long roleId;
    private String roleName;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    private String email;
    
    @NotBlank(message = "Password is required")
    @Size(min = 6, max = 100, message = "Password must be 6-100 characters")
    private String password;
    
    private String fullName;
    private LocalDate dateOfBirth;
    private String address;
    private Boolean isStudying;
}