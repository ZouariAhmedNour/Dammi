package com.example.dammi.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Min;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalTime;

@Entity
@Table(
        name = "creneau_collecte",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_point_type_date_time",
                        columnNames = {"point_collecte_id", "type_don_id", "date_collecte", "heure_debut"}
                )
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreneauCollecte {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "point_collecte_id", nullable = false)
    private PointCollecte pointCollecte;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "type_don_id", nullable = false)
    private TypeDon typeDon;

    @Column(name = "date_collecte", nullable = false)
    private LocalDate dateCollecte;

    @Column(name = "heure_debut", nullable = false)
    private LocalTime heureDebut;

    @Min(1)
    @Column(name = "places_totales", nullable = false)
    private int placesTotales;

    @Min(0)
    @Column(name = "places_restantes", nullable = false)
    private int placesRestantes;

    @Column(nullable = false)
    @Builder.Default
    private boolean actif = true;
}
