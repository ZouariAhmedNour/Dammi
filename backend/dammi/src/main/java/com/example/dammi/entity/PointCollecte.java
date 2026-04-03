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


    @NotBlank(message = "L'adresse est obligatoire")
    @Column(nullable = false, length = 255)
    private String adresse;

    @NotBlank(message = "La ville est obligatoire")
    @Column(nullable = false, length = 100)
    private String ville;

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
