package com.example.dammi.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class QuestionOptionResponse {
    private Long id;
    private String label;
    private String value;
    private Integer ordre;
    private boolean bloquante;
    private boolean active;
}
