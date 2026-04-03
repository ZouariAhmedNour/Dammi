package com.example.dammi.dto.request;

import com.example.dammi.entity.enums.Role;
import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class RegisterRequest {
        @NotBlank
        @Size(min = 2, max = 50)
        private String prenom;

        @NotBlank @Size(min = 2, max = 50)
        private String nom;

        @NotBlank @Email
        private String email;

        @NotBlank @Size(min = 8, message = "Le mot de passe doit contenir au moins 8 caractères")
        private String password;

        @Pattern(regexp = "^[+]?[0-9]{8,15}$", message = "Numéro de téléphone invalide")
        private String phone;

        private Role role = Role.USER;
}
