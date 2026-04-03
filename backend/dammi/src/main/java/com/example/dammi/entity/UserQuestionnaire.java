package com.example.dammi.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "user_questionnaire")
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserQuestionnaire {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "date_soumission")
    private LocalDateTime dateSoumission;

    @Column(length = 50)
    private String resultat;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "questionnaire_id", nullable = false)
    private Questionnaire questionnaire;

    @OneToMany(mappedBy = "userQuestionnaire", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Answer> answers;

}
