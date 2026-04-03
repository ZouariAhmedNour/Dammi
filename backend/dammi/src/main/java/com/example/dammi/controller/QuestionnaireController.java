package com.example.dammi.controller;


import com.example.dammi.dto.request.QuestionnaireRequest;
import com.example.dammi.dto.request.UserQuestionnaireRequest;
import com.example.dammi.entity.Questionnaire;
import com.example.dammi.entity.UserQuestionnaire;
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
@Tag(name = "Questionnaires", description = "Questionnaires d'éligibilité")
@SecurityRequirement(name = "BearerAuth")
public class QuestionnaireController {

    private final QuestionnaireService service;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Créer un questionnaire")
    public ResponseEntity<Questionnaire> creer(@Valid @RequestBody QuestionnaireRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.creerQuestionnaire(req));
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    @Operation(summary = "Liste tous les questionnaires")
    public ResponseEntity<List<Questionnaire>> getAll() {
        return ResponseEntity.ok(service.getAll());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    @Operation(summary = "Récupère un questionnaire par ID")
    public ResponseEntity<Questionnaire> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PostMapping("/soumettre")
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    @Operation(summary = "Soumettre un questionnaire rempli")
    public ResponseEntity<UserQuestionnaire> soumettre(@Valid @RequestBody UserQuestionnaireRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.soumettre(req));
    }

    @GetMapping("/user/{userId}")
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    @Operation(summary = "Soumissions d'un utilisateur")
    public ResponseEntity<List<UserQuestionnaire>> getByUser(@PathVariable Long userId) {
        return ResponseEntity.ok(service.getSubmissionsByUser(userId));
    }
}
