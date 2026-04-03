package com.example.dammi.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;

@Entity
@Table(name = "type_sanguin")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class TypeSanguin {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;


    @NotBlank(message = "Le libellé est obligatoire")
    @Column(nullable = false, length = 20)
    private String label;

    @NotBlank(message = "Le groupe ABO est obligatoire")
    @Pattern(regexp = "^(A|B|AB|O)[+-]$", message = "Groupe ABO invalide (ex: A+, B-, AB+, O-)")
    @Column(name = "abo_group", nullable = false, length = 5)
    private String aboGroup;


}
