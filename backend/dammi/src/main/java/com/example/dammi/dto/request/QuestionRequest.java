package com.example.dammi.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class QuestionRequest {
    @NotBlank
    @Size(max = 500)
    private String texte;

    @NotNull
    private Long questionnaireId;
}
