package com.example.dammi.dto.response;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;

@Data
@Builder
public class CarteDonneurResponse {
    private Long id;
    private String groupeSanguin;
    private int nbDon;
    private LocalDate dateEditionCarte;
    private String lieuCollecte;
}
