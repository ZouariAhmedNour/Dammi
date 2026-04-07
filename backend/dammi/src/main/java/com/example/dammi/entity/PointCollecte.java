package com.example.dammi.entity;


import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;

@Entity
@Table(name = "point_collecte")
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PointCollecte {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Le nom du point de collecte est obligatoire")
    @Size(max = 100)
    @Column(nullable = false, length = 100)
    private String nom;


    @NotBlank(message = "Le gouvernorat est obligatoire")
    @Column(nullable = false, length = 100)
    private String gouvernorat;

    @NotBlank(message = "La délégation est obligatoire")
    @Column(nullable = false, length = 150)
    private String delegation;

    @NotBlank(message = "Le code postal est obligatoire")
    @Pattern(regexp = "^\\d{4}$", message = "Code postal invalide")
    @Column(name = "code_postal", nullable = false, length = 10)
    private String codePostal;

    @NotBlank(message = "L'adresse postale est obligatoire")
    @Column(name = "adresse_postale", nullable = false, length = 255)
    private String adressePostale;

    @Min(value = 1, message = "La capacité doit être au moins 1")
    @Column(nullable = false)
    private int capacite;

    @Pattern(regexp = "^[+]?[0-9]{8,15}$", message = "Téléphone invalide")
    @Column(length = 20)
    private String telephone;

    @DecimalMin(value = "-90.0") @DecimalMax(value = "90.0")
    private double latitude;

    @DecimalMin(value = "-180.0") @DecimalMax(value = "180.0")
    private double longitude;

    @Column(length = 500)
    private String description;


}
