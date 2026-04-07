package com.example.dammi.controller;


import com.example.dammi.dto.request.PointCollecteRequest;
import com.example.dammi.entity.PointCollecte;
import com.example.dammi.service.PointCollecteService;
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
@RequestMapping("/api/points-collecte")
@RequiredArgsConstructor
@Tag(name = "Points de Collecte", description = "Gestion des points de collecte — lecture publique")
public class PointCollecteController {

    private final PointCollecteService service;

    @PostMapping
    @PreAuthorize("hasAnyRole('AGENT', 'ADMIN')")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Ajouter un point de collecte")
    public ResponseEntity<PointCollecte> ajouter(@Valid @RequestBody PointCollecteRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.ajouterPointCollecte(req));
    }

    @GetMapping
    @Operation(summary = "Liste tous les points de collecte — accès public")
    public ResponseEntity<List<PointCollecte>> getAll() {
        return ResponseEntity.ok(service.getAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Récupère un point de collecte — accès public")
    public ResponseEntity<PointCollecte> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @GetMapping("/gouvernorat/{gouvernorat}")
    @Operation(summary = "Points de collecte par gouvernorat")
    public ResponseEntity<List<PointCollecte>> getByGouvernorat(@PathVariable String gouvernorat) {
        return ResponseEntity.ok(service.getByGouvernorat(gouvernorat));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('AGENT', 'ADMIN')")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Modifier un point de collecte")
    public ResponseEntity<PointCollecte> modifier(@PathVariable Long id,
                                                  @Valid @RequestBody PointCollecteRequest req) {
        return ResponseEntity.ok(service.modifierPointCollecte(id, req));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Supprimer un point de collecte")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
