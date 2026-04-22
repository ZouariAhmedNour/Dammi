package com.example.dammi.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ContribuerDemandeRequest {
    @NotNull
    private Long userId;
}
