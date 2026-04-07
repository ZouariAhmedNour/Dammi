package com.example.dammi.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DelegationOptionResponse {
    private String nom;
    private String nomAr;
    private String codePostal;
    private Double latitude;
    private Double longitude;
}
