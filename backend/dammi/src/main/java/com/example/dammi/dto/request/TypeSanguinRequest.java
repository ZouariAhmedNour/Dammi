package com.example.dammi.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class TypeSanguinRequest {
    @NotBlank
    private String label;

    @NotBlank
    @Pattern(regexp = "^(A|B|AB|O)[+-]$")
    private String aboGroup;
}
