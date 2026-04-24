package com.example.dammi.service.impl;

import com.example.dammi.dto.request.DonRequest;
import com.example.dammi.dto.request.RendezVousRequest;
import com.example.dammi.dto.response.DonResponse;
import com.example.dammi.dto.response.RendezVousResponse;
import com.example.dammi.entity.RendezVous;
import com.example.dammi.entity.User;
import com.example.dammi.entity.enums.StatutRendezVous;
import com.example.dammi.exception.ResourceNotFoundException;
import com.example.dammi.repository.PointCollecteRepository;
import com.example.dammi.repository.RendezVousRepository;
import com.example.dammi.repository.UserRepository;
import com.example.dammi.service.DonService;
import com.example.dammi.service.RendezVousService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RendezVousServiceImpl implements RendezVousService {

    private final RendezVousRepository rendezVousRepository;
    private final UserRepository userRepository;
    private final PointCollecteRepository pointCollecteRepository;
    private final DonService donService;


    @Override
    @Transactional
    public RendezVousResponse prendreRendezVous(RendezVousRequest request) {
        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", request.getUserId()));

        RendezVous rdv = RendezVous.builder()
                .dateHeure(request.getDateHeure())
                .statut(StatutRendezVous.PLANIFIE)
                .user(user)
                .build();

        if (request.getPointCollecteId() != null) {
            rdv.setPointCollecte(pointCollecteRepository.findById(request.getPointCollecteId())
                    .orElseThrow(() -> new ResourceNotFoundException("PointCollecte", "id", request.getPointCollecteId())));
        }

        return toResponse(rendezVousRepository.save(rdv));
    }

    @Override
    public RendezVousResponse getRendezVousById(Long id) {
        return toResponse(find(id));
    }

    @Override
    public List<RendezVousResponse> getAllRendezVous() {
        return rendezVousRepository.findAll().stream().map(this::toResponse).toList();
    }

    @Override
    public List<RendezVousResponse> getRendezVousByUser(Long userId) {
        return rendezVousRepository.findByUserId(userId).stream().map(this::toResponse).toList();
    }

    @Override
    @Transactional
    public RendezVousResponse annulerRendezVous(Long id) {
        RendezVous rdv = find(id);

        if (rdv.getStatut() == StatutRendezVous.EFFECTUE) {
            throw new IllegalStateException("Impossible d'annuler un rendez-vous déjà effectué");
        }

        rdv.setStatut(StatutRendezVous.ANNULE);
        return toResponse(rendezVousRepository.save(rdv));
    }

    private RendezVous find(Long id) {
        return rendezVousRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("RendezVous", "id", id));
    }

    private RendezVousResponse toResponse(RendezVous rdv) {
        return RendezVousResponse.builder()
                .id(rdv.getId())
                .dateHeure(rdv.getDateHeure())
                .statut(rdv.getStatut())
                .userId(rdv.getUser().getId())
                .userNom(rdv.getUser().getPrenom() + " " + rdv.getUser().getNom())
                .pointCollecteNom(rdv.getPointCollecte() != null ? rdv.getPointCollecte().getNom() : null)
                .build();
    }

    @Override
    @Transactional
    public DonResponse creerDonDepuisRdv(Long rdvId) {
        RendezVous rdv = find(rdvId);

        if (rdv.getStatut() == StatutRendezVous.ANNULE) {
            throw new IllegalStateException("Impossible de créer un don depuis un rendez-vous annulé");
        }

        if (rdv.getStatut() == StatutRendezVous.EFFECTUE) {
            throw new IllegalStateException("Ce rendez-vous a déjà été transformé en don");
        }

        DonRequest request = new DonRequest();
        request.setUserId(rdv.getUser().getId());
        request.setDateDon(java.time.LocalDate.now());
        request.setPointCollecteId(rdv.getPointCollecte() != null ? rdv.getPointCollecte().getId() : null);

        // IMPORTANT : le don doit être validé ici
        request.setStatus(com.example.dammi.entity.enums.StatutDon.VALIDE);

        DonResponse response = donService.creerDon(request);

        rdv.setStatut(StatutRendezVous.EFFECTUE);
        rendezVousRepository.save(rdv);

        return response;
    }
}
