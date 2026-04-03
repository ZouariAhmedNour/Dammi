package com.example.dammi.service;

import com.example.dammi.dto.request.DonRequest;
import com.example.dammi.dto.response.DonResponse;
import com.example.dammi.entity.enums.StatutDon;

import java.util.List;

public interface DonService {
    DonResponse creerDon(DonRequest request);
    DonResponse getDonById(Long id);
    List<DonResponse> getAllDons();
    List<DonResponse> getDonsByUser(Long userId);
    DonResponse updateStatut(Long id, StatutDon statut);
    void deleteDon(Long id);
}
