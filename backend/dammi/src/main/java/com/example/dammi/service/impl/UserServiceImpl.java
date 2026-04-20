package com.example.dammi.service.impl;

import com.example.dammi.dto.response.UserResponse;
import com.example.dammi.entity.User;
import com.example.dammi.exception.ResourceNotFoundException;
import com.example.dammi.repository.UserRepository;
import com.example.dammi.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;

    @Override
    public List<UserResponse> getAllUsers() {
        return userRepository.findAll().stream().map(this::toResponse).toList();
    }

    @Override
    public UserResponse getUserById(Long id) {
        return toResponse(findUser(id));
    }

    @Override
    public UserResponse getUserByEmail(String email) {
        return toResponse(userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User", "email", email)));
    }

    @Override
    @Transactional
    public void deleteUser(Long id) {
        findUser(id);
        userRepository.deleteById(id);
    }

    private User findUser(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", id));
    }

    private UserResponse toResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .prenom(user.getPrenom())
                .nom(user.getNom())
                .email(user.getEmail())
                .phone(user.getPhone())
                .role(user.getRole())
                .sexe(user.getSexe())
                .lastDonation(user.getLastDonation())
                .eligibilityStatus(user.getEligibilityStatus())
                .statutPertinent(user.getStatutPertinent())
                .createdAt(user.getCreatedAt())
                .avatar(user.getAvatar())
                .typeSanguinId(user.getTypeSanguin() != null ? user.getTypeSanguin().getId() : null)
                .typeSanguinAboGroup(user.getTypeSanguin() != null ? user.getTypeSanguin().getAboGroup() : null)
                .build();
    }

    @Override
    @Transactional
    public Boolean updateStatutPertinent(Long id, Boolean statutPertinent) {
        User user = findUser(id);
        user.setStatutPertinent(statutPertinent);
        userRepository.save(user);
        return user.getStatutPertinent();
    }

}
