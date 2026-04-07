package com.example.dammi.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GouvernoratOptionResponse {
    private String nom;
    private String nomAr;
    private Double latitude;
    private Double longitude;
}
