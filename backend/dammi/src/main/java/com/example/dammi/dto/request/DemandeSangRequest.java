package com.example.dammi.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class DemandeSangRequest {
    @Min(1)
    private int quantite;

    @NotNull
    private boolean urgence;

    @NotBlank @Size(max = 100)
    private String contactNom;

    @Size(max = 500)
    private String raisonDemande;

    @Size(max = 1000)
    private String notesComplementaires;

    @NotBlank
    @Pattern(regexp = "^[+]?[0-9]{8,15}$", message = "Numéro de téléphone invalide")
    private String contactTelephone;

    @NotNull
    private Long pointCollecteId;

    @NotNull
    private Long userId;

    private Long typeSanguinId;
}
