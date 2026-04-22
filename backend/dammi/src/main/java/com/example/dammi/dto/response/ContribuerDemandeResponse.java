package com.example.dammi.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ContribuerDemandeResponse {
    private DemandeSangResponse demande;
    private Long donId;
    private boolean completed;
}
