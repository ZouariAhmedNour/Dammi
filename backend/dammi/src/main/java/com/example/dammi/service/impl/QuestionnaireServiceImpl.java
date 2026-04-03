package com.example.dammi.service.impl;

import com.example.dammi.dto.request.AnswerRequest;
import com.example.dammi.dto.request.QuestionnaireRequest;
import com.example.dammi.dto.request.UserQuestionnaireRequest;
import com.example.dammi.entity.*;
import com.example.dammi.exception.ResourceNotFoundException;
import com.example.dammi.repository.*;
import com.example.dammi.service.QuestionnaireService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class QuestionnaireServiceImpl implements QuestionnaireService {

    private final QuestionnaireRepository questionnaireRepository;
    private final UserRepository userRepository;
    private final UserQuestionnaireRepository userQuestionnaireRepository;
    private final QuestionRepository questionRepository;
    private final AnswerRepository answerRepository;

    @Override @Transactional
    public Questionnaire creerQuestionnaire(QuestionnaireRequest req) {
        return questionnaireRepository.save(Questionnaire.builder()
                .titre(req.getTitre())
                .description(req.getDescription())
                .build());
    }

    @Override
    public Questionnaire getById(Long id) {
        return questionnaireRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Questionnaire", "id", id));
    }

    @Override
    public List<Questionnaire> getAll() { return questionnaireRepository.findAll(); }

    @Override @Transactional
    public UserQuestionnaire soumettre(UserQuestionnaireRequest req) {
        User user = userRepository.findById(req.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", req.getUserId()));
        Questionnaire questionnaire = getById(req.getQuestionnaireId());

        UserQuestionnaire uq = UserQuestionnaire.builder()
                .user(user)
                .questionnaire(questionnaire)
                .dateSoumission(LocalDateTime.now())
                .resultat("EN_ATTENTE")
                .build();
        uq = userQuestionnaireRepository.save(uq);

        List<Answer> answers = new ArrayList<>();
        for (AnswerRequest ar : req.getReponses()) {
            Question question = questionRepository.findById(ar.getQuestionId())
                    .orElseThrow(() -> new ResourceNotFoundException("Question", "id", ar.getQuestionId()));
            answers.add(Answer.builder()
                    .valeur(ar.getValeur())
                    .question(question)
                    .userQuestionnaire(uq)
                    .build());
        }
        answerRepository.saveAll(answers);

        // Logique de calcul du résultat (simplifié)
        uq.setResultat("ELIGIBLE");
        return userQuestionnaireRepository.save(uq);
    }

    @Override
    public List<UserQuestionnaire> getSubmissionsByUser(Long userId) {
        return userQuestionnaireRepository.findByUserId(userId);
    }
}
