package com.example.dammi.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(
        name = "questionnaire_question",
        uniqueConstraints = {
                @UniqueConstraint(columnNames = {"questionnaire_id", "question_id"})
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuestionnaireQuestion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "questionnaire_id", nullable = false)
    private Questionnaire questionnaire;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_id", nullable = false)
    private Question question;

    @Column(nullable = false)
    private Integer ordre;

    @Column(nullable = false)
    @Builder.Default
    private boolean obligatoire = true;
}
