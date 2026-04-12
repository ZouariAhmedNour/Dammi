package com.example.dammi.dto.request;

import com.example.dammi.entity.enums.QuestionTypeReponse;
import jakarta.validation.constraints.*;
import lombok.Data;

import java.util.List;

@Data
public class QuestionRequest   {
    @NotBlank
    @Size(max = 500)
    private String texte;

    @NotNull
    private QuestionTypeReponse typeReponse;

    @Size(max = 255)
    private String aide;

    private boolean actif = true;

    private List<QuestionOptionRequest> options;
}
