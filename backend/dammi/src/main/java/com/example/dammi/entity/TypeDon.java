package com.example.dammi.entity;


import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;

@Entity
@Table(name = "type_don")
@Getter
@Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class TypeDon {


    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Le libellé du type de don est obligatoire")
    @Size(max = 100, message = "Le libellé ne doit pas dépasser 100 caractères")
    @Column(nullable = false, unique = true, length = 100)
    private String label;
}
