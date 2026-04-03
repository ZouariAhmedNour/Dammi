package com.example.dammi.entity;


import com.example.dammi.entity.enums.StatutDon;
import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "don")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Don {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "La date du don est obligatoire")
    @Column(name = "date_don", nullable = false)
    private LocalDate dateDon;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private StatutDon status;

    @Column(name = "created_at", updatable = false)
    private LocalDate createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "type_don_id")
    private TypeDon typeDon;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "point_collecte_id")
    private PointCollecte pointCollecte;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "type_sanguin_id")
    private TypeSanguin typeSanguin;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDate.now();
    }




}
