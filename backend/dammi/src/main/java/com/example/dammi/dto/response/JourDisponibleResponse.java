package com.example.dammi.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class JourDisponibleResponse {
    private String date;
    private int nombreCreneaux;
}
