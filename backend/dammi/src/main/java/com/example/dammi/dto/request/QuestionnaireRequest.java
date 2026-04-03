package com.example.dammi.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class QuestionnaireRequest {
    @NotBlank
    @Size(max = 200)
    private String titre;

    @Size(max = 1000)
    private String description;
}
