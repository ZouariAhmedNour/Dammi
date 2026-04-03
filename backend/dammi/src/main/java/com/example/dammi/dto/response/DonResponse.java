package com.example.dammi.dto.response;

import com.example.dammi.entity.enums.StatutDon;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;

@Data
@Builder
public class DonResponse {
    private Long id;
    private LocalDate dateDon;
    private StatutDon status;
    private LocalDate createdAt;
    private Long userId;
    private String userNom;
    private String typeDonLabel;
    private String pointCollecteNom;
    private String typeSanguinAboGroup;
}
