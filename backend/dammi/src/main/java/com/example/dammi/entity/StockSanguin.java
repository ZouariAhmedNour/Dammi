package com.example.dammi.entity;


import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;

@Entity
@Table(name = "stock_sanguin")
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StockSanguin {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Min(value = 0, message = "La quantité disponible ne peut pas être négative")
    @Column(name = "quantite_disponible", nullable = false)
    private int quantiteDisponible;

    @Min(value = 0, message = "Le seuil minimum ne peut pas être négatif")
    @Column(name = "seuil_minimum", nullable = false)
    private int seuilMinimum;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "type_sanguin_id", nullable = false)
    private TypeSanguin typeSanguin;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "point_collecte_id")
    private PointCollecte pointCollecte;
}
