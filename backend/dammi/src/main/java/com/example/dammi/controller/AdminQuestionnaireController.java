package com.example.dammi.controller;

import com.example.dammi.dto.request.QuestionnaireAssignQuestionsRequest;
import com.example.dammi.dto.request.QuestionnaireRequest;
import com.example.dammi.dto.response.QuestionnaireQuestionResponse;
import com.example.dammi.dto.response.QuestionnaireResponse;
import com.example.dammi.service.QuestionnaireService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/questionnaires")
@RequiredArgsConstructor
@Tag(name = "Admin Questionnaires", description = "Gestion des questionnaires")
@SecurityRequirement(name = "BearerAuth")
@PreAuthorize("hasRole('ADMIN')")
public class AdminQuestionnaireController {

    private final QuestionnaireService service;

    @PostMapping
    @Operation(summary = "Créer un questionnaire")
    public ResponseEntity<QuestionnaireResponse> create(@Valid @RequestBody QuestionnaireRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @GetMapping
    @Operation(summary = "Lister tous les questionnaires")
    public ResponseEntity<List<QuestionnaireResponse>> getAll() {
        return ResponseEntity.ok(service.getAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Récupérer un questionnaire")
    public ResponseEntity<QuestionnaireResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Modifier un questionnaire")
    public ResponseEntity<QuestionnaireResponse> update(@PathVariable Long id, @Valid @RequestBody QuestionnaireRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Supprimer un questionnaire")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/questions")
    @Operation(summary = "Lister les questions affectées au questionnaire")
    public ResponseEntity<List<QuestionnaireQuestionResponse>> getAssignedQuestions(@PathVariable Long id) {
        return ResponseEntity.ok(service.getAssignedQuestions(id));
    }

    @PostMapping("/{id}/questions")
    @Operation(summary = "Affecter des questions à un questionnaire")
    public ResponseEntity<List<QuestionnaireQuestionResponse>> assignQuestions(
            @PathVariable Long id,
            @Valid @RequestBody QuestionnaireAssignQuestionsRequest request
    ) {
        return ResponseEntity.ok(service.assignQuestions(id, request));
    }
}
