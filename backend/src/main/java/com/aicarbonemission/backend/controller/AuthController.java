package com.aicarbonemission.backend.controller;

import com.aicarbonemission.backend.dto.LoginRequest;
import com.aicarbonemission.backend.dto.RegisterRequest;
import com.aicarbonemission.backend.dto.AuthResponse;
import com.aicarbonemission.backend.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

   @PostMapping("/signup")
public ResponseEntity<String> signup(@RequestBody RegisterRequest registerRequest) {
    authService.signup(registerRequest);
    return ResponseEntity.ok("User registered successfully");
}

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest loginRequest) {
        String token = authService.login(loginRequest);
        return ResponseEntity.ok(new AuthResponse(token));
    }

    @GetMapping("/test")
    public String testApi() {
        return "Auth API working!";
    }
}
