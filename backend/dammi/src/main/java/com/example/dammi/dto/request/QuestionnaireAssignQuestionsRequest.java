package com.example.dammi.dto.request;

import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

import java.util.List;

@Data
public class QuestionnaireAssignQuestionsRequest {
    @NotEmpty
    private List<QuestionnaireQuestionAssignItemRequest> questions;
}
