package com.example.dammi.controller;

import com.example.dammi.dto.request.TypeSanguinRequest;
import com.example.dammi.entity.TypeSanguin;
import com.example.dammi.service.TypeSanguinService;
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
@RequestMapping("/api/types-sanguin")
@RequiredArgsConstructor
@Tag(name = "Types Sanguins", description = "Gestion des types sanguins")
public class TypeSanguinController {

    private final TypeSanguinService service;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Ajouter un type sanguin")
    public ResponseEntity<TypeSanguin> ajouter(@Valid @RequestBody TypeSanguinRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.ajouterType(req));
    }

    @GetMapping
    @Operation(summary = "Liste tous les types sanguins — accès public")
    public ResponseEntity<List<TypeSanguin>> getAll() {
        return ResponseEntity.ok(service.getAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Récupère un type sanguin — accès public")
    public ResponseEntity<TypeSanguin> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Modifier un type sanguin")
    public ResponseEntity<TypeSanguin> modifier(@PathVariable Long id, @Valid @RequestBody TypeSanguinRequest req) {
        return ResponseEntity.ok(service.modifierType(id, req));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Supprimer un type sanguin")
    public ResponseEntity<Void> supprimer(@PathVariable Long id) {
        service.supprimerType(id);
        return ResponseEntity.noContent().build();
    }
}
