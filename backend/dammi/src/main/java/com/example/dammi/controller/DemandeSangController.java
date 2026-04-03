package com.example.dammi.controller;


import com.example.dammi.dto.request.DemandeSangRequest;
import com.example.dammi.dto.response.DemandeSangResponse;
import com.example.dammi.entity.enums.StatutDemande;
import com.example.dammi.service.DemandeSangService;
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
@RequestMapping("/api/demandes")
@RequiredArgsConstructor
@Tag(name = "Demandes de Sang", description = "Gestion des demandes de sang")
@SecurityRequirement(name = "BearerAuth")
public class DemandeSangController {

    private final DemandeSangService service;

    @PostMapping
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    @Operation(summary = "Créer une demande de sang")
    public ResponseEntity<DemandeSangResponse> creer(@Valid @RequestBody DemandeSangRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.creerDemande(req));
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('AGENT', 'ADMIN')")
    @Operation(summary = "Liste toutes les demandes")
    public ResponseEntity<List<DemandeSangResponse>> getAll() {
        return ResponseEntity.ok(service.getAllDemandes());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    @Operation(summary = "Récupère une demande par ID")
    public ResponseEntity<DemandeSangResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getDemandeById(id));
    }

    @GetMapping("/user/{userId}")
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    @Operation(summary = "Demandes d'un utilisateur")
    public ResponseEntity<List<DemandeSangResponse>> getByUser(@PathVariable Long userId) {
        return ResponseEntity.ok(service.getDemandesByUser(userId));
    }

    @GetMapping("/urgentes")
    @PreAuthorize("hasAnyRole('AGENT', 'ADMIN')")
    @Operation(summary = "Demandes urgentes")
    public ResponseEntity<List<DemandeSangResponse>> getUrgentes() {
        return ResponseEntity.ok(service.getDemandesUrgentes());
    }

    @PutMapping("/{id}/statut")
    @PreAuthorize("hasAnyRole('AGENT', 'ADMIN')")
    @Operation(summary = "Met à jour le statut d'une demande")
    public ResponseEntity<DemandeSangResponse> updateStatut(@PathVariable Long id,
                                                            @RequestParam StatutDemande statut) {
        return ResponseEntity.ok(service.updateStatut(id, statut));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    @Operation(summary = "Modifier une demande")
    public ResponseEntity<DemandeSangResponse> modifier(@PathVariable Long id,
                                                        @Valid @RequestBody DemandeSangRequest req) {
        return ResponseEntity.ok(service.modifierDemande(id, req));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('USER', 'ADMIN')")
    @Operation(summary = "Supprimer une demande")
    public ResponseEntity<Void> supprimer(@PathVariable Long id) {
        service.supprimerDemande(id);
        return ResponseEntity.noContent().build();
    }
}
