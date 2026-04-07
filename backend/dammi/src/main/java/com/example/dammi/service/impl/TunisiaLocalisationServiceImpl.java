package com.example.dammi.service.impl;

import com.example.dammi.dto.external.TunisiaDelegationApiResponse;
import com.example.dammi.dto.external.TunisiaGovernorateApiResponse;
import com.example.dammi.dto.response.DelegationOptionResponse;
import com.example.dammi.dto.response.GouvernoratOptionResponse;
import com.example.dammi.service.TunisiaLocalisationService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TunisiaLocalisationServiceImpl implements TunisiaLocalisationService {

    private final RestTemplate restTemplate;

    @Value("${app.tunisia-api.base-url:https://tn-municipality-api.vercel.app}")
    private String baseUrl;

    @Override
    public List<GouvernoratOptionResponse> getGouvernorats() {
        TunisiaGovernorateApiResponse[] body =
                restTemplate.getForObject(baseUrl + "/api/municipalities", TunisiaGovernorateApiResponse[].class);

        if (body == null) return List.of();

        return Arrays.stream(body)
                .map(this::toGouvernoratOption)
                .sorted(Comparator.comparing(GouvernoratOptionResponse::getNom))
                .collect(Collectors.toList());
    }

    @Override
    public List<DelegationOptionResponse> getDelegations(String gouvernorat) {
        String url = UriComponentsBuilder
                .fromHttpUrl(baseUrl + "/api/municipalities")
                .queryParam("name", gouvernorat)
                .toUriString();

        TunisiaGovernorateApiResponse[] body =
                restTemplate.getForObject(url, TunisiaGovernorateApiResponse[].class);

        if (body == null || body.length == 0 || body[0].getDelegations() == null) {
            return List.of();
        }

        return body[0].getDelegations().stream()
                .map(this::toDelegationOption)
                .sorted(Comparator.comparing(DelegationOptionResponse::getNom))
                .collect(Collectors.toList());
    }

    private GouvernoratOptionResponse toGouvernoratOption(TunisiaGovernorateApiResponse item) {
        double avgLat = item.getDelegations() == null ? 34.0 :
                item.getDelegations().stream()
                        .map(TunisiaDelegationApiResponse::getLatitude)
                        .filter(Objects::nonNull)
                        .mapToDouble(Double::doubleValue)
                        .average()
                        .orElse(34.0);

        double avgLng = item.getDelegations() == null ? 9.0 :
                item.getDelegations().stream()
                        .map(TunisiaDelegationApiResponse::getLongitude)
                        .filter(Objects::nonNull)
                        .mapToDouble(Double::doubleValue)
                        .average()
                        .orElse(9.0);

        return GouvernoratOptionResponse.builder()
                .nom(item.getValue() != null ? item.getValue() : item.getName())
                .nomAr(item.getNameAr())
                .latitude(avgLat)
                .longitude(avgLng)
                .build();
    }

    private DelegationOptionResponse toDelegationOption(TunisiaDelegationApiResponse item) {
        return DelegationOptionResponse.builder()
                .nom(item.getValue() != null ? item.getValue() : item.getName())
                .nomAr(item.getNameAr())
                .codePostal(item.getPostalCode())
                .latitude(item.getLatitude())
                .longitude(item.getLongitude())
                .build();
    }
}
