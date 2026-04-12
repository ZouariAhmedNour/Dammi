package com.example.dammi.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class QuestionnaireQuestionAssignItemRequest  {
    @NotNull
    private Long questionId;

    @NotNull
    private Integer ordre;

    private boolean obligatoire = true;
}
