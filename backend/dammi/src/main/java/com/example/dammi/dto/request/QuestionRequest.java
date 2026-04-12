package com.example.dammi.dto.request;

import com.example.dammi.entity.enums.NiveauBlocage;
import com.example.dammi.entity.enums.QuestionApplicableSex;
import com.example.dammi.entity.enums.QuestionCode;
import com.example.dammi.entity.enums.QuestionTypeReponse;
import jakarta.validation.constraints.*;
import lombok.Data;

import java.util.List;

@Data
public class QuestionRequest   {

      private QuestionCode code;

    @NotBlank
    @Size(max = 500)
    private String texte;

    @NotNull
    private QuestionTypeReponse typeReponse;

    @Size(max = 255)
    private String aide;

    private boolean actif = true;

    private QuestionApplicableSex applicableSex = QuestionApplicableSex.ALL;

    private Double minNumericValue;
    private Double maxNumericValue;

    private NiveauBlocage outOfRangeBlockingLevel = NiveauBlocage.NONE;

    private List<QuestionOptionRequest> options;
}
