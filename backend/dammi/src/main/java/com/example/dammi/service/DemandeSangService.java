package com.example.dammi.service;

import com.example.dammi.dto.request.DemandeSangRequest;
import com.example.dammi.dto.response.ContribuerDemandeResponse;
import com.example.dammi.dto.response.DemandeSangResponse;
import com.example.dammi.entity.enums.StatutDemande;

import java.util.List;

public interface DemandeSangService {
    DemandeSangResponse creerDemande(DemandeSangRequest request);
    DemandeSangResponse getDemandeById(Long id);
    List<DemandeSangResponse> getAllDemandes();
    List<DemandeSangResponse> getDemandesByUser(Long userId);
    List<DemandeSangResponse> getDemandesUrgentes();
    DemandeSangResponse updateStatut(Long id, StatutDemande statut);
    DemandeSangResponse modifierDemande(Long id, DemandeSangRequest request);
    void supprimerDemande(Long id);
    List<DemandeSangResponse> getDemandesUrgentesPubliques();
    ContribuerDemandeResponse contribuerAUneDemande(Long demandeId, Long userId);
    List<DemandeSangResponse> getDemandesCompatiblesPourUser(Long userId);
    List<DemandeSangResponse> getDemandesUrgentesCompatiblesPourUser(Long userId);
}
