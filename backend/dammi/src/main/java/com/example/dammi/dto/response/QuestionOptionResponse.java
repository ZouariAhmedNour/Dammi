package com.example.dammi.dto.response;

import com.example.dammi.entity.enums.NiveauBlocage;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class QuestionOptionResponse {
    private Long id;
    private String label;
    private String value;
    private Integer ordre;
    private NiveauBlocage niveauBlocage;
    private boolean active;
}
