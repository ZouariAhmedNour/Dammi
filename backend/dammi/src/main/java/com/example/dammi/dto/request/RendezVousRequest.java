package com.example.dammi.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class RendezVousRequest {
    @NotNull
    @Future
    private LocalDateTime dateHeure;

    @NotNull
    private Long userId;

    private Long pointCollecteId;
}
