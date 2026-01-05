package com.sowa.controller;

import com.sowa.dto.AuthResponse;
import com.sowa.dto.LoginRequest;
import com.sowa.dto.RegisterRequest;
import com.sowa.model.User;
import com.sowa.security.JwtTokenProvider;
import com.sowa.service.CustomUserDetailsService;
import com.sowa.service.UserService;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/auth")
@Validated
public class AuthController {
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private AuthenticationManager authenticationManager;
    
    @Autowired
    private JwtTokenProvider jwtTokenProvider;
    
    @Autowired
    private CustomUserDetailsService userDetailsService;
    
    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest request) {
        try {
            User user = userService.registerUser(request);
            return ResponseEntity.status(HttpStatus.CREATED)
                .body(Map.of("message", "User registered successfully", "userId", user.getId()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest()
                .body(Map.of("error", e.getMessage()));
        }
    }
    
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request, 
                                     HttpServletResponse response) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                    request.getUsername(),
                    request.getPassword()
                )
            );
            
            SecurityContextHolder.getContext().setAuthentication(authentication);
            
            // Generate JWT token
            UserDetails userDetails = userDetailsService.loadUserByUsername(request.getUsername());
            String token = jwtTokenProvider.generateToken(userDetails);
            
            // Store in HTTP-only cookie
            Cookie cookie = new Cookie("jwt", token);
            cookie.setHttpOnly(true);
            cookie.setSecure(false); // Set to true in production with HTTPS
            cookie.setPath("/");
            cookie.setMaxAge(24 * 60 * 60); // 24 hours
            response.addCookie(cookie);
            
            User user = userService.findByUsername(request.getUsername());
            
            return ResponseEntity.ok(new AuthResponse(
                token,
                "Bearer",
                user.getId(),
                user.getUsername(),
                user.getRole().name()
            ));
            
        } catch (BadCredentialsException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(Map.of("error", "Invalid username or password"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(Map.of("error", "Authentication failed: " + e.getMessage()));
        }
    }
    
    @PostMapping("/logout")
    public ResponseEntity<?> logout(HttpServletResponse response) {
        Cookie cookie = new Cookie("jwt", null);
        cookie.setHttpOnly(true);
        cookie.setSecure(false);
        cookie.setPath("/");
        cookie.setMaxAge(0);
        response.addCookie(cookie);
        
        SecurityContextHolder.clearContext();
        
        return ResponseEntity.ok(Map.of("message", "Logged out successfully"));
    }
}
