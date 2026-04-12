package com.example.dammi.service;

import com.example.dammi.dto.request.QuestionnaireAssignQuestionsRequest;
import com.example.dammi.dto.request.QuestionnaireRequest;
import com.example.dammi.dto.request.UserQuestionnaireRequest;
import com.example.dammi.dto.response.QuestionnaireQuestionResponse;
import com.example.dammi.dto.response.QuestionnaireResponse;
import com.example.dammi.dto.response.UserQuestionnaireResponse;


import java.util.List;

public interface QuestionnaireService {
    QuestionnaireResponse create(QuestionnaireRequest request);
    QuestionnaireResponse update(Long id, QuestionnaireRequest request);
    QuestionnaireResponse getById(Long id);
    List<QuestionnaireResponse> getAll();
    void delete(Long id);

    List<QuestionnaireQuestionResponse> assignQuestions(Long questionnaireId, QuestionnaireAssignQuestionsRequest request);
    List<QuestionnaireQuestionResponse> getAssignedQuestions(Long questionnaireId);

    UserQuestionnaireResponse soumettre(UserQuestionnaireRequest request);
    List<UserQuestionnaireResponse> getSubmissionsByUser(Long userId);
}