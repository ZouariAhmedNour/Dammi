package com.example.dammi.dto.request;

import com.example.dammi.entity.enums.QuestionnaireType;
import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class QuestionnaireRequest  {

    @NotBlank
    @Size(max = 200)
    private String titre;

    @Size(max = 1000)
    private String description;

    @NotNull
    private QuestionnaireType type;

    private boolean actif = true;
}
