package com.example.dammi.service.impl;

import com.example.dammi.dto.request.LoginRequest;
import com.example.dammi.dto.request.RegisterRequest;
import com.example.dammi.dto.response.AuthResponse;
import com.example.dammi.entity.User;
import com.example.dammi.exception.BadRequestException;
import com.example.dammi.repository.UserRepository;
import com.example.dammi.security.JwtTokenProvider;
import com.example.dammi.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final AuthenticationManager authenticationManager;

    @Override
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email déjà utilisé : " + request.getEmail());
        }

        User user = User.builder()
                .prenom(request.getPrenom())
                .nom(request.getNom())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .phone(request.getPhone())
                .role(request.getRole())
                .eligibilityStatus("ELIGIBLE")
                .statutPertinent(true)
                .build();

        user = userRepository.save(user);
        String token = jwtTokenProvider.generateToken(user.getEmail());

        return AuthResponse.builder()
                .token(token)
                .id(user.getId())
                .email(user.getEmail())
                .prenom(user.getPrenom())
                .nom(user.getNom())
                .role(user.getRole())
                .build();
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword()));

        User user = (User) authentication.getPrincipal();
        String token = jwtTokenProvider.generateToken(authentication);

        return AuthResponse.builder()
                .token(token)
                .id(user.getId())
                .email(user.getEmail())
                .prenom(user.getPrenom())
                .nom(user.getNom())
                .role(user.getRole())
                .build();
    }
}
