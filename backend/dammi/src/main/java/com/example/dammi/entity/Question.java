package com.example.dammi.entity;


import com.example.dammi.entity.enums.QuestionTypeReponse;
import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "question")
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Question {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Le texte de la question est obligatoire")
    @Size(max = 500)
    @Column(nullable = false, length = 500)
    private String texte;

    @Enumerated(EnumType.STRING)
    @Column(name = "type_reponse", nullable = false, length = 30)
    private QuestionTypeReponse typeReponse;

    @Column(length = 255)
    private String aide;

    @Column(nullable = false)
    @Builder.Default
    private boolean actif = true;

    @OneToMany(mappedBy = "question", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @Builder.Default
    private List<QuestionOption> options = new ArrayList<>();
}
