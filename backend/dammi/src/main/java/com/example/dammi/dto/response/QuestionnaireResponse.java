package com.example.dammi.dto.response;

import com.example.dammi.entity.enums.QuestionnaireType;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class QuestionnaireResponse {
    private Long id;
    private String titre;
    private String description;
    private QuestionnaireType type;
    private boolean actif;
    private LocalDateTime createdAt;
    private List<QuestionnaireQuestionResponse> questions;
}
