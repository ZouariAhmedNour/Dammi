package com.example.dammi.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class TypeDonRequest {
    @NotBlank @Size(max = 100)
    private String label;
}
