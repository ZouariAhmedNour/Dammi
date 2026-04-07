package com.example.dammi.service;

import com.example.dammi.dto.response.DelegationOptionResponse;
import com.example.dammi.dto.response.GouvernoratOptionResponse;

import java.util.List;

public interface TunisiaLocalisationService {
    List<GouvernoratOptionResponse> getGouvernorats();
    List<DelegationOptionResponse> getDelegations(String gouvernorat);
}
