package com.example.dammi.service;

import com.example.dammi.dto.request.QuestionnaireRequest;
import com.example.dammi.dto.request.UserQuestionnaireRequest;
import com.example.dammi.entity.Questionnaire;
import com.example.dammi.entity.UserQuestionnaire;

import java.util.List;

public interface QuestionnaireService {
    Questionnaire creerQuestionnaire(QuestionnaireRequest request);
    Questionnaire getById(Long id);
    List<Questionnaire> getAll();
    UserQuestionnaire soumettre(UserQuestionnaireRequest request);
    List<UserQuestionnaire> getSubmissionsByUser(Long userId);
}