package com.example.dammi.entity;


import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "carte_donneur")
@Getter
@Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class CarteDonneur {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Le groupe sanguin est obligatoire")
    @Column(nullable = false, length = 10)
    private String groupeSanguin;

    @Min(value = 0, message = "Le nombre de dons ne peut pas être négatif")
    @Column(nullable = false)
    private int nbDon;

    private LocalDate dateEditionCarte;

    @Column(length = 100)
    private String lieuCollecte;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    @JsonIgnore
    private User user;



}
