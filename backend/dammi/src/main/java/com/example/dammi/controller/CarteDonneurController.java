package com.example.dammi.controller;


import com.example.dammi.entity.CarteDonneur;
import com.example.dammi.service.CarteDonneurService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/cartes-donneur")
@RequiredArgsConstructor
@Tag(name = "Carte Donneur", description = "Gestion des cartes de donneur")
@SecurityRequirement(name = "BearerAuth")
public class CarteDonneurController {

    private final CarteDonneurService service;

    @PostMapping("/generer/{userId}")
    @PreAuthorize("hasAnyRole('AGENT', 'ADMIN','USER')")
    @Operation(summary = "Générer une carte donneur pour un utilisateur")
    public ResponseEntity<CarteDonneur> generer(@PathVariable Long userId) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.generateCard(userId));
    }

    @GetMapping("/user/{userId}")
    @PreAuthorize("hasAnyRole('USER', 'AGENT', 'ADMIN')")
    @Operation(summary = "Récupère la carte d'un donneur")
    public ResponseEntity<CarteDonneur> getByUser(@PathVariable Long userId) {
        return ResponseEntity.ok(service.getCardByUser(userId));
    }
}
