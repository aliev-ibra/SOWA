package com.sowa.validator;

import org.springframework.stereotype.Component;

import java.util.Set;

@Component
public class PasswordValidator {
    
    private static final int MIN_LENGTH = 8;
    private static final Set<String> COMMON_PASSWORDS = Set.of(
        "password", "12345678", "qwerty", "abc123", "password123"
    );
    
    public void validate(String password) {
        if (password == null || password.length() < MIN_LENGTH) {
            throw new IllegalArgumentException(
                "Password must be at least " + MIN_LENGTH + " characters long");
        }
        
        if (COMMON_PASSWORDS.contains(password.toLowerCase())) {
            throw new IllegalArgumentException("Password is too common");
        }
        
        boolean hasUpper = password.chars().anyMatch(Character::isUpperCase);
        boolean hasLower = password.chars().anyMatch(Character::isLowerCase);
        boolean hasDigit = password.chars().anyMatch(Character::isDigit);
        boolean hasSpecial = password.chars().anyMatch(ch -> "!@#$%^&*()".indexOf(ch) >= 0);
        
        if (!(hasUpper && hasLower && hasDigit && hasSpecial)) {
            throw new IllegalArgumentException(
                "Password must contain uppercase, lowercase, digit, and special character");
        }
    }
}
