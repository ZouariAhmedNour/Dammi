package com.example.dammi.dto.response;

import com.example.dammi.entity.enums.Role;
import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    private String token;
    private String type = "Bearer";
    private Long id;
    private String email;
    private String prenom;
    private String nom;
    private Role role;
}
