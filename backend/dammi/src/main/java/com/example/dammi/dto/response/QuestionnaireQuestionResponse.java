package com.example.dammi.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class QuestionnaireQuestionResponse {
    private Long id;
    private Long questionId;
    private Integer ordre;
    private boolean obligatoire;
    private QuestionResponse question;
}
