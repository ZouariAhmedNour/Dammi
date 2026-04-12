package com.example.dammi.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;

@Entity
@Table(name = "question_option")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuestionOption {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Size(max = 200)
    @Column(nullable = false, length = 200)
    private String label;

    @NotBlank
    @Size(max = 100)
    @Column(nullable = false, length = 100)
    private String value;

    @Column(nullable = false)
    @Builder.Default
    private Integer ordre = 0;

    @Column(nullable = false)
    @Builder.Default
    private boolean bloquante = false;

    @Column(nullable = false)
    @Builder.Default
    private boolean active = true;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_id", nullable = false)
    private Question question;
}
