package com.example.dammi.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class StockSanguinResponse {
    private Long id;
    private int quantiteDisponible;
    private int seuilMinimum;
    private boolean sousLeSeuil;
    private String typeSanguinAboGroup;
    private String pointCollecteNom;
}
