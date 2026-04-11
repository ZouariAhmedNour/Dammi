package com.example.dammi.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class CreneauCollecteResponse {
    private Long id;
    private Long pointCollecteId;
    private String pointCollecteNom;
    private Long typeDonId;
    private String typeDonLabel;
    private String dateCollecte;
    private String heureDebut;
    private int placesTotales;
    private int placesRestantes;
    private boolean actif;
}
