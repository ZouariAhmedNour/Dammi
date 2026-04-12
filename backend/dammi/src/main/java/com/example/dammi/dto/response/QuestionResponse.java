package com.example.dammi.dto.response;

import com.example.dammi.entity.enums.QuestionTypeReponse;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class QuestionResponse {
    private Long id;
    private String texte;
    private QuestionTypeReponse typeReponse;
    private String aide;
    private boolean actif;
    private List<QuestionOptionResponse> options;
}
