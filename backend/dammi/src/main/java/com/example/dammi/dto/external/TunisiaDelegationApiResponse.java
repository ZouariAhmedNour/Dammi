package com.example.dammi.dto.external;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class TunisiaDelegationApiResponse {

    @JsonProperty("Name")
    private String name;

    @JsonProperty("NameAr")
    private String nameAr;

    @JsonProperty("Value")
    private String value;

    @JsonProperty("PostalCode")
    private String postalCode;

    @JsonProperty("Latitude")
    private Double latitude;

    @JsonProperty("Longitude")
    private Double longitude;
}
