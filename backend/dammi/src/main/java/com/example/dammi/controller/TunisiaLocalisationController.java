package com.example.dammi.controller;

import com.example.dammi.dto.response.DelegationOptionResponse;
import com.example.dammi.dto.response.GouvernoratOptionResponse;
import com.example.dammi.service.TunisiaLocalisationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/localisation")
@RequiredArgsConstructor
public class TunisiaLocalisationController {

    private final TunisiaLocalisationService service;

    @GetMapping("/gouvernorats")
    public List<GouvernoratOptionResponse> getGouvernorats() {
        return service.getGouvernorats();
    }

    @GetMapping("/delegations")
    public List<DelegationOptionResponse> getDelegations(@RequestParam String gouvernorat) {
        return service.getDelegations(gouvernorat);
    }
}
