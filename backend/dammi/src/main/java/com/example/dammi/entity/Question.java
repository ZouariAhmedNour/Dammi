package com.example.dammi.entity;


import com.example.dammi.entity.enums.NiveauBlocage;
import com.example.dammi.entity.enums.QuestionApplicableSex;
import com.example.dammi.entity.enums.QuestionCode;
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

    @Enumerated(EnumType.STRING)
    @Column(length = 60)
    private QuestionCode code;

    @NotBlank(message = "Le texte de la question est obligatoire")
    @Size(max = 500)
    @Column(nullable = false, length = 500)
    private String texte;

    @Enumerated(EnumType.STRING)
    @Column(name = "type_reponse", nullable = false, length = 30)
    private QuestionTypeReponse typeReponse;

    @Column(length = 255)
    private String aide;

    @Enumerated(EnumType.STRING)
    @Column(name = "applicable_sex", nullable = false, length = 20)
    @Builder.Default
    private QuestionApplicableSex applicableSex = QuestionApplicableSex.ALL;

    @Column(name = "min_numeric_value")
    private Double minNumericValue;

    @Column(name = "max_numeric_value")
    private Double maxNumericValue;

    @Enumerated(EnumType.STRING)
    @Column(name = "out_of_range_blocking_level", nullable = false, length = 20)
    @Builder.Default
    private NiveauBlocage outOfRangeBlockingLevel = NiveauBlocage.NONE;

    @Column(nullable = false)
    @Builder.Default
    private boolean actif = true;

    @OneToMany(mappedBy = "question", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @Builder.Default
    private List<QuestionOption> options = new ArrayList<>();
}
