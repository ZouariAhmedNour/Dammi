package com.example.dammi.service;

import com.example.dammi.dto.request.DonRequest;
import com.example.dammi.dto.request.RendezVousRequest;
import com.example.dammi.dto.response.DonResponse;
import com.example.dammi.dto.response.RendezVousResponse;

import java.util.List;

public interface RendezVousService {
    RendezVousResponse prendreRendezVous(RendezVousRequest request);
    RendezVousResponse getRendezVousById(Long id);
    List<RendezVousResponse> getAllRendezVous();
    List<RendezVousResponse> getRendezVousByUser(Long userId);
    RendezVousResponse annulerRendezVous(Long id);
    DonResponse creerDonDepuisRdv(Long rdvId);

}
