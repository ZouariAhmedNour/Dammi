package com.example.dammi.service.impl;

import com.example.dammi.dto.request.QuestionOptionRequest;
import com.example.dammi.dto.request.QuestionRequest;
import com.example.dammi.dto.response.QuestionOptionResponse;
import com.example.dammi.dto.response.QuestionResponse;
import com.example.dammi.entity.Question;
import com.example.dammi.entity.QuestionOption;
import com.example.dammi.entity.enums.QuestionTypeReponse;
import com.example.dammi.exception.ResourceNotFoundException;
import com.example.dammi.repository.QuestionRepository;
import com.example.dammi.service.QuestionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class QuestionServiceImpl implements QuestionService {

    private final QuestionRepository questionRepository;

    @Override
    @Transactional
    public QuestionResponse create(QuestionRequest request) {
        Question question = new Question();
        apply(question, request);
        return toResponse(questionRepository.save(question));
    }

    @Override
    @Transactional
    public QuestionResponse update(Long id, QuestionRequest request) {
        Question question = questionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Question", "id", id));
        apply(question, request);
        return toResponse(questionRepository.save(question));
    }

    @Override
    @Transactional(readOnly = true)
    public QuestionResponse getById(Long id) {
        Question question = questionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Question", "id", id));
        return toResponse(question);
    }

    @Override
    @Transactional(readOnly = true)
    public List<QuestionResponse> getAll() {
        return questionRepository.findAllByOrderByIdDesc()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    @Transactional
    public void delete(Long id) {
        Question question = questionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Question", "id", id));
        questionRepository.delete(question);
    }

    private void apply(Question question, QuestionRequest request) {
        question.setTexte(request.getTexte());
        question.setTypeReponse(request.getTypeReponse());
        question.setAide(request.getAide());
        question.setActif(request.isActif());

        if (question.getOptions() == null) {
            question.setOptions(new ArrayList<>());
        } else {
            question.getOptions().clear();
        }

        boolean requiresOptions = request.getTypeReponse() == QuestionTypeReponse.YES_NO
                || request.getTypeReponse() == QuestionTypeReponse.SINGLE_CHOICE
                || request.getTypeReponse() == QuestionTypeReponse.MULTIPLE_CHOICE;

        if (requiresOptions) {
            if (request.getOptions() == null || request.getOptions().isEmpty()) {
                throw new IllegalArgumentException("Cette question nécessite au moins une option");
            }

            for (QuestionOptionRequest optionRequest : request.getOptions()) {
                QuestionOption option = QuestionOption.builder()
                        .label(optionRequest.getLabel())
                        .value(optionRequest.getValue())
                        .ordre(optionRequest.getOrdre() == null ? 0 : optionRequest.getOrdre())
                        .bloquante(optionRequest.isBloquante())
                        .active(optionRequest.isActive())
                        .question(question)
                        .build();
                question.getOptions().add(option);
            }
        }
    }

    private QuestionResponse toResponse(Question question) {
        return QuestionResponse.builder()
                .id(question.getId())
                .texte(question.getTexte())
                .typeReponse(question.getTypeReponse())
                .aide(question.getAide())
                .actif(question.isActif())
                .options(
                        question.getOptions() == null
                                ? List.of()
                                : question.getOptions().stream()
                                .sorted(Comparator.comparing(QuestionOption::getOrdre))
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
    }
}
