package com.example.dammi.dto.response;

import com.example.dammi.entity.enums.StatutDemande;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class DemandeSangResponse {
    private Long id;
    private int quantite;
    private int quantiteLivree;
    private StatutDemande statut;
    private LocalDateTime dateCreation;
    private boolean urgence;
    private String contactNom;
    private String raisonDemande;
    private String notesComplementaires;
    private Long userId;
    private String userNom;
    private String typeSanguinAboGroup;
}
