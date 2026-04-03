package com.example.dammi.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

import java.time.LocalDate;

@Data
public class CarteDonneurRequest {
    @NotBlank
    private String groupeSanguin;

    @Min(0)
    private int nbDon;

    private LocalDate dateEditionCarte;
    private String lieuCollecte;

    @NotNulls
    private Long userId;
}
