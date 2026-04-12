package com.example.dammi.dto.response;

import com.example.dammi.entity.enums.QuestionnaireResultat;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class UserQuestionnaireResponse {
    private Long id;
    private Long userId;
    private Long questionnaireId;
    private String questionnaireTitre;
    private LocalDateTime dateSoumission;
    private QuestionnaireResultat resultat;
    private String motifResultat;
}
