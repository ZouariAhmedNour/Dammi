package com.example.dammi.controller;


import com.example.dammi.dto.request.TypeDonRequest;
import com.example.dammi.entity.TypeDon;
import com.example.dammi.service.TypeDonService;
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
@RequestMapping("/api/types-don")
@RequiredArgsConstructor
@Tag(name = "Types de Don", description = "Gestion des types de don")
public class TypeDonController {

    private final TypeDonService service;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Ajouter un type de don")
    public ResponseEntity<TypeDon> ajouter(@Valid @RequestBody TypeDonRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.ajouterType(req));
    }

    @GetMapping
    @Operation(summary = "Liste tous les types de don — accès public")
    public ResponseEntity<List<TypeDon>> getAll() {
        return ResponseEntity.ok(service.getAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Récupère un type de don — accès public")
    public ResponseEntity<TypeDon> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Modifier un type de don")
    public ResponseEntity<TypeDon> modifier(@PathVariable Long id, @Valid @RequestBody TypeDonRequest req) {
        return ResponseEntity.ok(service.modifierType(id, req));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Supprimer un type de don")
    public ResponseEntity<Void> supprimer(@PathVariable Long id) {
        service.supprimerType(id);
        return ResponseEntity.noContent().build();
    }
}
