package com.aicarbonemission.backend.service;

import com.aicarbonemission.backend.dto.LoginRequest;
import com.aicarbonemission.backend.dto.RegisterRequest;
import com.aicarbonemission.backend.model.Role;
import com.aicarbonemission.backend.model.User;
import com.aicarbonemission.backend.repository.RoleRepository;
import com.aicarbonemission.backend.repository.UserRepository;
import com.aicarbonemission.backend.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtUtil jwtUtil;

    public void signup(RegisterRequest request) {

    if (userRepository.findByUsername(request.getUsername()).isPresent()) {
        throw new RuntimeException("Username already exists");
    }

    User user = new User();

    // 🔥 FIX → this was missing earlier
    user.setUsername(request.getUsername());

    user.setPassword(passwordEncoder.encode(request.getPassword()));

    Role role = roleRepository.findByName("USER")
            .orElseThrow(() -> new RuntimeException("Role not found"));

    user.setRole(role);

    userRepository.save(user);
}

    public String login(LoginRequest request) {

        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getUsername(),
                        request.getPassword()
                )
        );

        return jwtUtil.generateToken(request.getUsername());
    }
}