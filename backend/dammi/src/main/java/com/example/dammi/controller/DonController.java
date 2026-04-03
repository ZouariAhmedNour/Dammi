package com.example.dammi.controller;


import com.example.dammi.dto.request.DonRequest;
import com.example.dammi.dto.response.DonResponse;
import com.example.dammi.entity.enums.StatutDon;
import com.example.dammi.service.DonService;
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
@RequestMapping("/api/dons")
@RequiredArgsConstructor
@Tag(name = "Dons", description = "Gestion des dons de sang")
@SecurityRequirement(name = "BearerAuth")
public class DonController {

    private final DonService donService;

    @PostMapping
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    @Operation(summary = "Créer un don")
    public ResponseEntity<DonResponse> creer(@Valid @RequestBody DonRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(donService.creerDon(request));
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('AGENT', 'ADMIN')")
    @Operation(summary = "Liste tous les dons")
    public ResponseEntity<List<DonResponse>> getAll() {
        return ResponseEntity.ok(donService.getAllDons());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    @Operation(summary = "Récupère un don par ID")
    public ResponseEntity<DonResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(donService.getDonById(id));
    }

    @GetMapping("/user/{userId}")
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    @Operation(summary = "Dons d'un utilisateur")
    public ResponseEntity<List<DonResponse>> getByUser(@PathVariable Long userId) {
        return ResponseEntity.ok(donService.getDonsByUser(userId));
    }

    @PutMapping("/{id}/statut")
    @PreAuthorize("hasAnyRole('AGENT', 'ADMIN')")
    @Operation(summary = "Met à jour le statut d'un don")
    public ResponseEntity<DonResponse> updateStatut(@PathVariable Long id,
                                                    @RequestParam StatutDon statut) {
        return ResponseEntity.ok(donService.updateStatut(id, statut));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Supprime un don")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        donService.deleteDon(id);
        return ResponseEntity.noContent().build();
    }
}
