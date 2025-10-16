package com.auth.service.exception;

import lombok.Getter;

@Getter
public class RoleNotFoundException extends RuntimeException {
    private final String roleName;

    public RoleNotFoundException(String roleName) {
        super(String.format("Role '%s' not found", roleName));
        this.roleName = roleName;
    }
}



