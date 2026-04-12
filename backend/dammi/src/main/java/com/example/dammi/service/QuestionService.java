package com.example.dammi.service;

import com.example.dammi.dto.request.QuestionRequest;
import com.example.dammi.dto.response.QuestionResponse;

import java.util.List;

public interface QuestionService {
    QuestionResponse create(QuestionRequest request);
    QuestionResponse update(Long id, QuestionRequest request);
    QuestionResponse getById(Long id);
    List<QuestionResponse> getAll();
    void delete(Long id);
}
