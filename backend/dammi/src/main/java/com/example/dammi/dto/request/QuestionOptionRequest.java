package com.example.dammi.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class QuestionOptionRequest {
    @NotBlank
    private String label;

    @NotBlank
    private String value;

    private Integer ordre;
    private boolean bloquante;
    private boolean active = true;
}
