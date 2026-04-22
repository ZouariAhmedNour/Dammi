package com.example.dammi.controller;

import com.example.dammi.dto.request.DonRequest;
import com.example.dammi.dto.request.RendezVousRequest;
import com.example.dammi.dto.response.DonResponse;
import com.example.dammi.dto.response.RendezVousResponse;
import com.example.dammi.service.RendezVousService;
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
@RequestMapping("/api/rendez-vous")
@RequiredArgsConstructor
@Tag(name = "Rendez-vous", description = "Gestion des rendez-vous de don")
@SecurityRequirement(name = "BearerAuth")
public class RendezVousController {

    private final RendezVousService service;

    @PostMapping
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    @Operation(summary = "Prendre un rendez-vous")
    public ResponseEntity<RendezVousResponse> prendre(@Valid @RequestBody RendezVousRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.prendreRendezVous(req));
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('AGENT', 'ADMIN')")
    @Operation(summary = "Liste tous les rendez-vous")
    public ResponseEntity<List<RendezVousResponse>> getAll() {
        return ResponseEntity.ok(service.getAllRendezVous());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    @Operation(summary = "Récupère un rendez-vous par ID")
    public ResponseEntity<RendezVousResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getRendezVousById(id));
    }

    @GetMapping("/user/{userId}")
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    @Operation(summary = "Rendez-vous d'un utilisateur")
    public ResponseEntity<List<RendezVousResponse>> getByUser(@PathVariable Long userId) {
        return ResponseEntity.ok(service.getRendezVousByUser(userId));
    }

    @PutMapping("/{id}/annuler")
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    @Operation(summary = "Annuler un rendez-vous")
    public ResponseEntity<RendezVousResponse> annuler(@PathVariable Long id) {
        return ResponseEntity.ok(service.annulerRendezVous(id));
    }

    @PostMapping("/{id}/don")
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    public ResponseEntity<DonResponse> creerDonDepuisRdv(@PathVariable Long id) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(service.creerDonDepuisRdv(id));
    }

}
