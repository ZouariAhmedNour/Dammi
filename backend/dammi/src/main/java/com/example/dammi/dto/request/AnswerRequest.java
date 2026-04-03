package com.example.dammi.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class AnswerRequest {
    @NotNull
    private Long questionId;

    @NotBlank
    private String valeur;
}
