package com.example.dammi.service.impl;

import com.example.dammi.dto.request.DemandeSangRequest;
import com.example.dammi.dto.response.DemandeSangResponse;
import com.example.dammi.entity.DemandeSang;
import com.example.dammi.entity.User;
import com.example.dammi.entity.enums.StatutDemande;
import com.example.dammi.exception.ResourceNotFoundException;
import com.example.dammi.repository.DemandeSangRepository;
import com.example.dammi.repository.TypeSanguinRepository;
import com.example.dammi.repository.UserRepository;
import com.example.dammi.service.DemandeSangService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DemandeSangServiceImpl implements DemandeSangService {


    private final DemandeSangRepository demandeSangRepository;
    private final UserRepository userRepository;
    private final TypeSanguinRepository typeSanguinRepository;

    @Override
    @Transactional
    public DemandeSangResponse creerDemande(DemandeSangRequest req) {
        User user = userRepository.findById(req.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", req.getUserId()));

        DemandeSang demande = DemandeSang.builder()
                .quantite(req.getQuantite())
                .quantiteLivree(0)
                .statut(StatutDemande.EN_ATTENTE)
                .urgence(req.isUrgence())
                .contactNom(req.getContactNom())
                .raisonDemande(req.getRaisonDemande())
                .notesComplementaires(req.getNotesComplementaires())
                .user(user)
                .build();

        if (req.getTypeSanguinId() != null) {
            demande.setTypeSanguin(typeSanguinRepository.findById(req.getTypeSanguinId())
                    .orElseThrow(() -> new ResourceNotFoundException("TypeSanguin", "id", req.getTypeSanguinId())));
        }

        return toResponse(demandeSangRepository.save(demande));
    }

    @Override
    public DemandeSangResponse getDemandeById(Long id) {
        return toResponse(findDemande(id));
    }

    @Override
    public List<DemandeSangResponse> getAllDemandes() {
        return demandeSangRepository.findAll().stream().map(this::toResponse).toList();
    }

    @Override
    public List<DemandeSangResponse> getDemandesByUser(Long userId) {
        return demandeSangRepository.findByUserId(userId).stream().map(this::toResponse).toList();
    }

    @Override
    public List<DemandeSangResponse> getDemandesUrgentes() {
        return demandeSangRepository.findByUrgenceTrue().stream().map(this::toResponse).toList();
    }

    @Override
    @Transactional
    public DemandeSangResponse updateStatut(Long id, StatutDemande statut) {
        DemandeSang demande = findDemande(id);
        demande.setStatut(statut);
        return toResponse(demandeSangRepository.save(demande));
    }

    @Override
    @Transactional
    public DemandeSangResponse modifierDemande(Long id, DemandeSangRequest req) {
        DemandeSang demande = findDemande(id);
        demande.setQuantite(req.getQuantite());
        demande.setUrgence(req.isUrgence());
        demande.setContactNom(req.getContactNom());
        demande.setRaisonDemande(req.getRaisonDemande());
        demande.setNotesComplementaires(req.getNotesComplementaires());
        return toResponse(demandeSangRepository.save(demande));
    }

    @Override
    @Transactional
    public void supprimerDemande(Long id) {
        findDemande(id);
        demandeSangRepository.deleteById(id);
    }

    private DemandeSang findDemande(Long id) {
        return demandeSangRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("DemandeSang", "id", id));
    }

    private DemandeSangResponse toResponse(DemandeSang d) {
        return DemandeSangResponse.builder()
                .id(d.getId())
                .quantite(d.getQuantite())
                .quantiteLivree(d.getQuantiteLivree())
                .statut(d.getStatut())
                .dateCreation(d.getDateCreation())
                .urgence(d.isUrgence())
                .contactNom(d.getContactNom())
                .raisonDemande(d.getRaisonDemande())
                .notesComplementaires(d.getNotesComplementaires())
                .userId(d.getUser().getId())
                .userNom(d.getUser().getPrenom() + " " + d.getUser().getNom())
                .typeSanguinAboGroup(d.getTypeSanguin() != null ? d.getTypeSanguin().getAboGroup() : null)
                .build();
    }


    @Override
    public List<DemandeSangResponse> getDemandesUrgentesPubliques() {
        return demandeSangRepository
                .findByUrgenceTrueAndStatut(StatutDemande.EN_ATTENTE)
                .stream()
                .map(this::toResponse)
                .toList();
    }

}
