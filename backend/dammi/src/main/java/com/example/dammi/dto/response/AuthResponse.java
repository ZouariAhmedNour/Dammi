package com.example.dammi.dto.response;

import com.example.dammi.entity.enums.Role;
import com.example.dammi.entity.enums.Sexe;
import lombok.*;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    private String token;

    @Builder.Default
    private String type = "Bearer";
    private Long id;
    private String email;
    private String prenom;
    private String nom;
    private String phone;
    private Sexe sexe;
    private LocalDate lastDonation;
    private Role role;
    private String eligibilityStatus;
    private Long typeSanguinId;
    private String typeSanguinAboGroup;
}