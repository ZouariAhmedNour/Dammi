package com.example.dammi.service;

import com.example.dammi.dto.request.LoginRequest;
import com.example.dammi.dto.request.RegisterRequest;
import com.example.dammi.dto.response.AuthResponse;

public interface AuthService {
    AuthResponse login(LoginRequest request);
    AuthResponse register(RegisterRequest request);
}
