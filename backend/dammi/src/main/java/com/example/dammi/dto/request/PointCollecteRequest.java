package com.example.dammi.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class PointCollecteRequest {
    @NotBlank
    @Size(max = 100)
    private String nom;

    @NotBlank
    private String adresse;

    @NotBlank
    private String ville;

    @Min(1)
    private int capacite;

    @Pattern(regexp = "^[+]?[0-9]{8,15}$")
    private String telephone;

    @DecimalMin("-90.0") @DecimalMax("90.0")
    private double latitude;

    @DecimalMin("-180.0") @DecimalMax("180.0")
    private double longitude;

    @Size(max = 500)
    private String description;
}
