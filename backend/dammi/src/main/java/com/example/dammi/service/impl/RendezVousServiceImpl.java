package com.example.dammi.service.impl;

import com.example.dammi.dto.request.RendezVousRequest;
import com.example.dammi.dto.response.RendezVousResponse;
import com.example.dammi.entity.RendezVous;
import com.example.dammi.entity.User;
import com.example.dammi.entity.enums.StatutRendezVous;
import com.example.dammi.exception.ResourceNotFoundException;
import com.example.dammi.repository.PointCollecteRepository;
import com.example.dammi.repository.RendezVousRepository;
import com.example.dammi.repository.UserRepository;
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
}
