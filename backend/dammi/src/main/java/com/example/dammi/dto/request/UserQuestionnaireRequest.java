package com.example.dammi.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

import java.util.List;

@Data
public class UserQuestionnaireRequest {
    @NotNull
    private Long userId;

    @NotNull
    private Long questionnaireId;

    @NotNull
    private List<AnswerRequest> reponses;
}
