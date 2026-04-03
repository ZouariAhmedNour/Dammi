package com.example.dammi.dto.response;

import com.example.dammi.entity.enums.StatutRendezVous;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class RendezVousResponse {
    private Long id;
    private LocalDateTime dateHeure;
    private StatutRendezVous statut;
    private Long userId;
    private String userNom;
    private String pointCollecteNom;
}
