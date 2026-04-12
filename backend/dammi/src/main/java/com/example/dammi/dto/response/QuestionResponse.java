package com.example.dammi.dto.response;

import com.example.dammi.entity.enums.NiveauBlocage;
import com.example.dammi.entity.enums.QuestionApplicableSex;
import com.example.dammi.entity.enums.QuestionCode;
import com.example.dammi.entity.enums.QuestionTypeReponse;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class QuestionResponse {
    private Long id;
    private QuestionCode code;
    private String texte;
    private QuestionTypeReponse typeReponse;
    private String aide;
    private QuestionApplicableSex applicableSex;
    private Double minNumericValue;
    private Double maxNumericValue;
    private NiveauBlocage outOfRangeBlockingLevel;
    private boolean actif;
    private List<QuestionOptionResponse> options;
}
