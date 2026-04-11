package com.example.dammi.controller;

import com.example.dammi.dto.response.CreneauCollecteResponse;
import com.example.dammi.dto.response.JourDisponibleResponse;
import com.example.dammi.service.CreneauCollecteService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/api/creneaux")
@RequiredArgsConstructor
@Tag(name = "Créneaux de collecte", description = "Planning des rendez-vous par point et type de don")
public class CreneauCollecteController {

    private final CreneauCollecteService service;

    @GetMapping("/jours-disponibles")
    @Operation(summary = "Récupérer les jours disponibles d'un mois pour un point et un type de don")
    public ResponseEntity<List<JourDisponibleResponse>> getJoursDisponibles(
            @RequestParam Long pointCollecteId,
            @RequestParam Long typeDonId,
            @RequestParam int year,
            @RequestParam int month
    ) {
        return ResponseEntity.ok(service.getJoursDisponibles(pointCollecteId, typeDonId, year, month));
    }

    @GetMapping
    @Operation(summary = "Récupérer les créneaux disponibles d'un jour")
    public ResponseEntity<List<CreneauCollecteResponse>> getCreneauxDuJour(
            @RequestParam Long pointCollecteId,
            @RequestParam Long typeDonId,
            @RequestParam String date
    ) {
        return ResponseEntity.ok(service.getCreneauxDuJour(pointCollecteId, typeDonId, date));
    }

    @PostMapping("/generate")
    @PreAuthorize("hasRole('ADMIN')")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Générer un planning annuel aléatoire pour un point de collecte")
    public ResponseEntity<Void> generate(
            @RequestParam Long pointCollecteId,
            @RequestParam int year
    ) {
        service.genererPlanningAnnuel(pointCollecteId, year);
        return ResponseEntity.ok().build();
    }
}
