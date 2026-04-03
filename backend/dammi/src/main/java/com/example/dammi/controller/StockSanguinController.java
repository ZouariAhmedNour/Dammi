package com.example.dammi.controller;


import com.example.dammi.dto.request.StockSanguinRequest;
import com.example.dammi.dto.response.StockSanguinResponse;
import com.example.dammi.service.StockSanguinService;
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
@RequestMapping("/api/stocks")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('AGENT', 'ADMIN')")
@Tag(name = "Stock Sanguin", description = "Gestion des stocks — AGENT & ADMIN")
@SecurityRequirement(name = "BearerAuth")
public class StockSanguinController {


    private final StockSanguinService service;

    @PostMapping
    @Operation(summary = "Créer un stock")
    public ResponseEntity<StockSanguinResponse> creer(@Valid @RequestBody StockSanguinRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.creerStock(req));
    }

    @GetMapping
    @Operation(summary = "Liste tous les stocks")
    public ResponseEntity<List<StockSanguinResponse>> getAll() {
        return ResponseEntity.ok(service.getAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Récupère un stock par ID")
    public ResponseEntity<StockSanguinResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @GetMapping("/alerte")
    @Operation(summary = "Stocks sous le seuil minimum")
    public ResponseEntity<List<StockSanguinResponse>> getAlerte() {
        return ResponseEntity.ok(service.getStocksSousLeSeuil());
    }

    @PutMapping("/{id}/quantite")
    @Operation(summary = "Mettre à jour la quantité d'un stock")
    public ResponseEntity<StockSanguinResponse> updateQuantite(@PathVariable Long id,
                                                               @RequestParam int quantite) {
        return ResponseEntity.ok(service.mettreAJourStock(id, quantite));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Supprimer un stock")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
