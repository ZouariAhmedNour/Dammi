package com.example.dammi.dto.request;

import com.example.dammi.entity.enums.StatutDon;
import jakarta.validation.constraints.*;
import lombok.Data;

import java.time.LocalDate;

@Data
public class DonRequest {
    @NotNull
    private LocalDate dateDon;

    private StatutDon status = StatutDon.EN_COURS;

    @NotNull
    private Long userId;

    private Long typeDonId;
    private Long pointCollecteId;
    private Long typeSanguinId;
}
