package com.example.dammi.service;

import com.example.dammi.dto.response.UserResponse;

import java.util.List;

public interface UserService {
    List<UserResponse> getAllUsers();
    UserResponse getUserById(Long id);
    UserResponse getUserByEmail(String email);
    void deleteUser(Long id);
}
