package com.example.dammi.service.impl;

import com.example.dammi.dto.request.DemandeSangRequest;
import com.example.dammi.dto.response.ContribuerDemandeResponse;
import com.example.dammi.dto.response.DemandeSangResponse;
import com.example.dammi.entity.DemandeSang;
import com.example.dammi.entity.Don;
import com.example.dammi.entity.User;
import com.example.dammi.entity.enums.StatutDemande;
import com.example.dammi.exception.ResourceNotFoundException;
import com.example.dammi.repository.*;
import com.example.dammi.service.DemandeSangService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Locale;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class DemandeSangServiceImpl implements DemandeSangService {


    private final DemandeSangRepository demandeSangRepository;
    private final UserRepository userRepository;
    private final TypeSanguinRepository typeSanguinRepository;
    private final PointCollecteRepository pointCollecteRepository;
    private final DonRepository donRepository;

    @Override
    @Transactional
    public DemandeSangResponse creerDemande(DemandeSangRequest req) {
        User user = userRepository.findById(req.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", req.getUserId()));
        var pointCollecte = pointCollecteRepository.findById(req.getPointCollecteId())
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "PointCollecte",
                                "id",
                                req.getPointCollecteId()
                        ));

        DemandeSang demande = DemandeSang.builder()
                .quantite(req.getQuantite())
                .quantiteLivree(0)
                .statut(StatutDemande.EN_ATTENTE)
                .urgence(req.isUrgence())
                .contactNom(req.getContactNom())
                .contactTelephone(req.getContactTelephone())
                .raisonDemande(req.getRaisonDemande())
                .notesComplementaires(req.getNotesComplementaires())
                .user(user)
                .pointCollecte(pointCollecte)
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

        var pointCollecte = pointCollecteRepository.findById(req.getPointCollecteId())
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "PointCollecte",
                                "id",
                                req.getPointCollecteId()
                        ));

        demande.setQuantite(req.getQuantite());
        demande.setUrgence(req.isUrgence());
        demande.setContactNom(req.getContactNom());
        demande.setRaisonDemande(req.getRaisonDemande());
        demande.setNotesComplementaires(req.getNotesComplementaires());
        demande.setPointCollecte(pointCollecte);
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
                .contactTelephone(d.getContactTelephone())
                .pointCollecteId(d.getPointCollecte() != null ? d.getPointCollecte().getId() : null)
                .pointCollecteNom(d.getPointCollecte() != null ? d.getPointCollecte().getNom() : null)
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

    @Override
    public List<DemandeSangResponse> getDemandesCompatiblesPourUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        String donorGroup = getUserBloodGroup(user);
        if (donorGroup == null || donorGroup.isBlank()) {
            return List.of();
        }

        return demandeSangRepository.findByStatut(StatutDemande.EN_ATTENTE)
                .stream()
                .filter(d -> isCompatible(donorGroup, getRequestBloodGroup(d)))
                .map(this::toResponse)
                .toList();
    }

    @Override
    public List<DemandeSangResponse> getDemandesUrgentesCompatiblesPourUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        String donorGroup = getUserBloodGroup(user);
        if (donorGroup == null || donorGroup.isBlank()) {
            return List.of();
        }

        return demandeSangRepository.findByUrgenceTrueAndStatut(StatutDemande.EN_ATTENTE)
                .stream()
                .filter(d -> isCompatible(donorGroup, getRequestBloodGroup(d)))
                .map(this::toResponse)
                .toList();
    }

    @Override
    @Transactional
    public ContribuerDemandeResponse contribuerAUneDemande(Long demandeId, Long userId) {
        DemandeSang demande = findDemande(demandeId);

        if (demande.getQuantiteLivree() >= demande.getQuantite()) {
            throw new IllegalStateException("Cette demande est déjà satisfaite");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        Don don = Don.builder()
                .dateDon(java.time.LocalDate.now())
                .status(com.example.dammi.entity.enums.StatutDon.EN_COURS)
                .user(user)
                .pointCollecte(demande.getPointCollecte())
                .typeSanguin(demande.getTypeSanguin())
                .build();

        Don savedDon = donRepository.save(don);

        demande.setQuantiteLivree(demande.getQuantiteLivree() + 1);

        boolean completed = demande.getQuantiteLivree() >= demande.getQuantite();
        if (completed) {
            demande.setStatut(StatutDemande.SATISFAITE);
        }

        demandeSangRepository.save(demande);

        return ContribuerDemandeResponse.builder()
                .demande(toResponse(demande))
                .donId(savedDon.getId())
                .completed(completed)
                .build();
    }

    private String getRequestBloodGroup(DemandeSang demande) {
        return demande.getTypeSanguin() != null && demande.getTypeSanguin().getAboGroup() != null
                ? normalize(demande.getTypeSanguin().getAboGroup())
                : null;
    }

    private String getUserBloodGroup(User user) {
        // adapte si ton User backend expose le groupe autrement
        try {
            if (user.getTypeSanguin() != null && user.getTypeSanguin().getAboGroup() != null) {
                return normalize(user.getTypeSanguin().getAboGroup());
            }
        } catch (Exception ignored) {
        }
        return null;
    }

    private String normalize(String value) {
        return value == null ? null : value.trim().toUpperCase(Locale.ROOT);
    }

    private boolean isCompatible(String donorGroup, String recipientGroup) {
        if (donorGroup == null || recipientGroup == null) return false;

        Set<String> allowedRecipients = switch (donorGroup) {
            case "O-" -> Set.of("O-", "O+", "A-", "A+", "B-", "B+", "AB-", "AB+");
            case "O+" -> Set.of("O+", "A+", "B+", "AB+");
            case "A-" -> Set.of("A-", "A+", "AB-", "AB+");
            case "A+" -> Set.of("A+", "AB+");
            case "B-" -> Set.of("B-", "B+", "AB-", "AB+");
            case "B+" -> Set.of("B+", "AB+");
            case "AB-" -> Set.of("AB-", "AB+");
            case "AB+" -> Set.of("AB+");
            default -> Set.of();
        };

        return allowedRecipients.contains(recipientGroup);
    }





}
