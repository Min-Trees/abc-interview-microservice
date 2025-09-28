package com.auth.service.dto;

import lombok.Data;

@Data
public class UserDto {
    private Long id;
    private Long roleId;
    private String roleName;
    private String email;
    private String fullName;
    private String verifyToken;
}