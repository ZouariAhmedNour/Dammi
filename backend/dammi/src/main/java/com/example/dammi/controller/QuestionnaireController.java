package com.example.dammi.controller;


import com.example.dammi.dto.request.UserQuestionnaireRequest;
import com.example.dammi.dto.response.QuestionnaireResponse;
import com.example.dammi.dto.response.UserQuestionnaireResponse;
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
@RequestMapping("/api/questionnaires")
@RequiredArgsConstructor
@Tag(name = "Questionnaires", description = "Questionnaires côté utilisateur")
@SecurityRequirement(name = "BearerAuth")
public class QuestionnaireController {

    private final QuestionnaireService service;

    @GetMapping
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    @Operation(summary = "Lister les questionnaires")
    public ResponseEntity<List<QuestionnaireResponse>> getAll() {
        return ResponseEntity.ok(service.getAll());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    @Operation(summary = "Récupérer un questionnaire par ID")
    public ResponseEntity<QuestionnaireResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PostMapping("/soumettre")
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    @Operation(summary = "Soumettre un questionnaire")
    public ResponseEntity<UserQuestionnaireResponse> soumettre(@Valid @RequestBody UserQuestionnaireRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.soumettre(request));
    }

    @GetMapping("/user/{userId}")
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    @Operation(summary = "Lister les soumissions d'un utilisateur")
    public ResponseEntity<List<UserQuestionnaireResponse>> getByUser(@PathVariable Long userId) {
        return ResponseEntity.ok(service.getSubmissionsByUser(userId));
    }
}
