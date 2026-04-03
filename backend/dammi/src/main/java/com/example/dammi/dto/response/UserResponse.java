package com.example.dammi.dto.response;

import com.example.dammi.entity.enums.Role;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
public class UserResponse {
    private Long id;
    private String prenom;
    private String nom;
    private String email;
    private String phone;
    private Role role;
    private LocalDate lastDonation;
    private String eligibilityStatus;
    private Boolean statutPertinent;
    private LocalDateTime createdAt;
    private String avatar;
}
