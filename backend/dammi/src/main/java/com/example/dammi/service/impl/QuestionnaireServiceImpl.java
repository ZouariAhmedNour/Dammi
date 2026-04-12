package com.example.dammi.service.impl;

import com.example.dammi.dto.request.*;
import com.example.dammi.dto.response.*;
import com.example.dammi.entity.*;
import com.example.dammi.entity.enums.QuestionTypeReponse;
import com.example.dammi.entity.enums.QuestionnaireResultat;
import com.example.dammi.exception.ResourceNotFoundException;
import com.example.dammi.repository.*;
import com.example.dammi.service.QuestionnaireService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class QuestionnaireServiceImpl implements QuestionnaireService {

    private final QuestionnaireRepository questionnaireRepository;
    private final QuestionnaireQuestionRepository questionnaireQuestionRepository;
    private final QuestionRepository questionRepository;
    private final QuestionOptionRepository questionOptionRepository;
    private final UserRepository userRepository;
    private final UserQuestionnaireRepository userQuestionnaireRepository;
    private final AnswerRepository answerRepository;

    @Override
    @Transactional
    public QuestionnaireResponse create(QuestionnaireRequest request) {
        Questionnaire questionnaire = Questionnaire.builder()
                .titre(request.getTitre())
                .description(request.getDescription())
                .type(request.getType())
                .actif(request.isActif())
                .build();

        return toResponse(questionnaireRepository.save(questionnaire));
    }

    @Override
    @Transactional
    public QuestionnaireResponse update(Long id, QuestionnaireRequest request) {
        Questionnaire questionnaire = questionnaireRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Questionnaire", "id", id));

        questionnaire.setTitre(request.getTitre());
        questionnaire.setDescription(request.getDescription());
        questionnaire.setType(request.getType());
        questionnaire.setActif(request.isActif());

        return toResponse(questionnaireRepository.save(questionnaire));
    }

    @Override
    @Transactional(readOnly = true)
    public QuestionnaireResponse getById(Long id) {
        Questionnaire questionnaire = questionnaireRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Questionnaire", "id", id));
        return toResponse(questionnaire);
    }

    @Override
    @Transactional(readOnly = true)
    public List<QuestionnaireResponse> getAll() {
        return questionnaireRepository.findAllByOrderByCreatedAtDesc()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    @Transactional
    public void delete(Long id) {
        Questionnaire questionnaire = questionnaireRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Questionnaire", "id", id));
        questionnaireRepository.delete(questionnaire);
    }

    @Override
    @Transactional
    public List<QuestionnaireQuestionResponse> assignQuestions(Long questionnaireId, QuestionnaireAssignQuestionsRequest request) {
        Questionnaire questionnaire = questionnaireRepository.findById(questionnaireId)
                .orElseThrow(() -> new ResourceNotFoundException("Questionnaire", "id", questionnaireId));

        questionnaireQuestionRepository.deleteByQuestionnaireId(questionnaireId);

        List<QuestionnaireQuestion> items = new ArrayList<>();

        for (QuestionnaireQuestionAssignItemRequest item : request.getQuestions()) {
            Question question = questionRepository.findById(item.getQuestionId())
                    .orElseThrow(() -> new ResourceNotFoundException("Question", "id", item.getQuestionId()));

            items.add(QuestionnaireQuestion.builder()
                    .questionnaire(questionnaire)
                    .question(question)
                    .ordre(item.getOrdre())
                    .obligatoire(item.isObligatoire())
                    .build());
        }

        questionnaireQuestionRepository.saveAll(items);
        return getAssignedQuestions(questionnaireId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<QuestionnaireQuestionResponse> getAssignedQuestions(Long questionnaireId) {
        return questionnaireQuestionRepository.findByQuestionnaireIdOrderByOrdreAsc(questionnaireId)
                .stream()
                .map(this::toQuestionnaireQuestionResponse)
                .toList();
    }

    @Override
    @Transactional
    public UserQuestionnaireResponse soumettre(UserQuestionnaireRequest request) {
        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", request.getUserId()));

        Questionnaire questionnaire = questionnaireRepository.findById(request.getQuestionnaireId())
                .orElseThrow(() -> new ResourceNotFoundException("Questionnaire", "id", request.getQuestionnaireId()));

        List<QuestionnaireQuestion> assignedQuestions =
                questionnaireQuestionRepository.findByQuestionnaireIdOrderByOrdreAsc(questionnaire.getId());

        Map<Long, QuestionnaireQuestion> assignedMap = assignedQuestions.stream()
                .collect(Collectors.toMap(q -> q.getQuestion().getId(), q -> q));

        Set<Long> answeredQuestionIds = new HashSet<>();

        UserQuestionnaire userQuestionnaire = UserQuestionnaire.builder()
                .user(user)
                .questionnaire(questionnaire)
                .dateSoumission(LocalDateTime.now())
                .resultat(QuestionnaireResultat.EN_ATTENTE)
                .build();

        userQuestionnaire = userQuestionnaireRepository.save(userQuestionnaire);

        List<Answer> answers = new ArrayList<>();
        boolean bloquant = false;

        for (AnswerRequest answerRequest : request.getReponses()) {
            Question question = questionRepository.findById(answerRequest.getQuestionId())
                    .orElseThrow(() -> new ResourceNotFoundException("Question", "id", answerRequest.getQuestionId()));

            if (!assignedMap.containsKey(question.getId())) {
                throw new IllegalArgumentException("La question " + question.getId() + " n'appartient pas à ce questionnaire");
            }

            answeredQuestionIds.add(question.getId());

            Answer answer = Answer.builder()
                    .question(question)
                    .userQuestionnaire(userQuestionnaire)
                    .valeur(answerRequest.getValeur())
                    .build();

            answers.add(answer);

            if (isBlockingAnswer(question, answerRequest.getValeur())) {
                bloquant = true;
            }
        }

        for (QuestionnaireQuestion questionnaireQuestion : assignedQuestions) {
            if (questionnaireQuestion.isObligatoire() && !answeredQuestionIds.contains(questionnaireQuestion.getQuestion().getId())) {
                throw new IllegalArgumentException(
                        "La question obligatoire " + questionnaireQuestion.getQuestion().getTexte() + " n'a pas été renseignée"
                );
            }
        }

        answerRepository.saveAll(answers);

        if (bloquant) {
            userQuestionnaire.setResultat(QuestionnaireResultat.NON_ELIGIBLE);
            user.setEligibilityStatus("NON_ELIGIBLE");
            user.setStatutPertinent(false);
        } else {
            userQuestionnaire.setResultat(QuestionnaireResultat.ELIGIBLE);
            user.setEligibilityStatus("ELIGIBLE");
            user.setStatutPertinent(true);
        }

        userRepository.save(user);
        userQuestionnaireRepository.save(userQuestionnaire);

        return toUserQuestionnaireResponse(userQuestionnaire);
    }

    @Override
    @Transactional(readOnly = true)
    public List<UserQuestionnaireResponse> getSubmissionsByUser(Long userId) {
        return userQuestionnaireRepository.findByUserId(userId)
                .stream()
                .map(this::toUserQuestionnaireResponse)
                .toList();
    }

    private boolean isBlockingAnswer(Question question, String answerValue) {
        if (question.getTypeReponse() != QuestionTypeReponse.YES_NO
                && question.getTypeReponse() != QuestionTypeReponse.SINGLE_CHOICE
                && question.getTypeReponse() != QuestionTypeReponse.MULTIPLE_CHOICE) {
            return false;
        }

        List<QuestionOption> options = questionOptionRepository.findByQuestionIdOrderByOrdreAsc(question.getId());
        Set<String> userValues = parseAnswerValues(answerValue);

        for (QuestionOption option : options) {
            if (option.isBloquante() && userValues.contains(option.getValue())) {
                return true;
            }
        }

        return false;
    }

    private Set<String> parseAnswerValues(String value) {
        if (value == null || value.isBlank()) {
            return Set.of();
        }

        return Arrays.stream(value.split(","))
                .map(String::trim)
                .filter(v -> !v.isBlank())
                .collect(Collectors.toSet());
    }

    private QuestionnaireResponse toResponse(Questionnaire questionnaire) {
        return QuestionnaireResponse.builder()
                .id(questionnaire.getId())
                .titre(questionnaire.getTitre())
                .description(questionnaire.getDescription())
                .type(questionnaire.getType())
                .actif(questionnaire.isActif())
                .createdAt(questionnaire.getCreatedAt())
                .questions(getAssignedQuestions(questionnaire.getId()))
                .build();
    }

    private QuestionnaireQuestionResponse toQuestionnaireQuestionResponse(QuestionnaireQuestion item) {
        Question question = item.getQuestion();

        QuestionResponse questionResponse = QuestionResponse.builder()
                .id(question.getId())
                .texte(question.getTexte())
                .typeReponse(question.getTypeReponse())
                .aide(question.getAide())
                .actif(question.isActif())
                .options(
                        questionOptionRepository.findByQuestionIdOrderByOrdreAsc(question.getId())
                                .stream()
                                .map(option -> QuestionOptionResponse.builder()
                                        .id(option.getId())
                                        .label(option.getLabel())
                                        .value(option.getValue())
                                        .ordre(option.getOrdre())
                                        .bloquante(option.isBloquante())
                                        .active(option.isActive())
                                        .build())
                                .toList()
                )
                .build();

        return QuestionnaireQuestionResponse.builder()
                .id(item.getId())
                .questionId(question.getId())
                .ordre(item.getOrdre())
                .obligatoire(item.isObligatoire())
                .question(questionResponse)
                .build();
    }

    private UserQuestionnaireResponse toUserQuestionnaireResponse(UserQuestionnaire entity) {
        return UserQuestionnaireResponse.builder()
                .id(entity.getId())
                .userId(entity.getUser().getId())
                .questionnaireId(entity.getQuestionnaire().getId())
                .questionnaireTitre(entity.getQuestionnaire().getTitre())
                .dateSoumission(entity.getDateSoumission())
                .resultat(entity.getResultat())
                .build();
    }
}
