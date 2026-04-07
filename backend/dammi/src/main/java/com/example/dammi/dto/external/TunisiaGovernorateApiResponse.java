package com.example.dammi.dto.external;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import java.util.List;

@Data
public class TunisiaGovernorateApiResponse {
    @JsonProperty("Name")
    private String name;

    @JsonProperty("NameAr")
    private String nameAr;

    @JsonProperty("Value")
    private String value;

    @JsonProperty("Delegations")
    private List<TunisiaDelegationApiResponse> delegations;
}
