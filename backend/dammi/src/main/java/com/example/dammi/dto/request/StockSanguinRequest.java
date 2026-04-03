package com.example.dammi.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class StockSanguinRequest {
    @Min(0)
    private int quantiteDisponible;

    @Min(0)
    private int seuilMinimum;

    @NotNull
    private Long typeSanguinId;

    private Long pointCollecteId;
}
