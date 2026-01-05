package com.sowa.service;

import com.sowa.dto.RegisterRequest;
import com.sowa.exception.ResourceNotFoundException;
import com.sowa.model.User;
import com.sowa.model.enums.Role;
import com.sowa.repository.UserRepository;
import com.sowa.validator.PasswordValidator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Autowired
    private PasswordValidator passwordValidator;
    
    public User registerUser(RegisterRequest request) {
        // Validate password
        passwordValidator.validate(request.getPassword());
        
        // Check if username/email exists
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new IllegalArgumentException("Username already exists");
        }
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already exists");
        }
        
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(Role.USER);
        user.setEnabled(true);
        
        return userRepository.save(user);
    }
    
    public User findByUsername(String username) {
        return userRepository.findByUsername(username)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }
}
