package com.example.dammi.entity;


import com.example.dammi.entity.enums.StatutDemande;
import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "demande_sang")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class DemandeSang {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Min(value = 1, message = "La quantité doit être au moins 1")
    @Column(nullable = false)
    private int quantite;

    @Column(nullable = false)
    private int quantiteLivree = 0;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private StatutDemande statut;

    @Column(name = "date_creation", nullable = false, updatable = false)
    private LocalDateTime dateCreation;

    @Column(nullable = false)
    private boolean urgence;

    @NotBlank(message = "Le nom de contact est obligatoire")
    @Size(max = 100)
    @Column(name = "contact_nom", nullable = false, length = 100)
    private String contactNom;

    @Size(max = 500)
    @Column(length = 500)
    private String raisonDemande;

    @Size(max = 1000)
    @Column(length = 1000)
    private String notesComplementaires;

    @Column(name = "contact_telephone", nullable = false, length = 20)
    @NotBlank(message = "Le numéro de téléphone est obligatoire")
    @Pattern(regexp = "^[+]?[0-9]{8,15}$", message = "Numéro de téléphone invalide")
    private String contactTelephone;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "point_collecte_id", nullable = false)
    private PointCollecte pointCollecte;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "type_sanguin_id")
    private TypeSanguin typeSanguin;

    @PrePersist
    protected void onCreate() {
        dateCreation = LocalDateTime.now();

    }

}
