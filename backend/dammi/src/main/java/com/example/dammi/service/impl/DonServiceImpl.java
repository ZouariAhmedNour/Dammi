package com.example.dammi.service.impl;

import com.example.dammi.dto.request.DonRequest;
import com.example.dammi.dto.response.DonResponse;
import com.example.dammi.entity.Don;
import com.example.dammi.entity.User;
import com.example.dammi.entity.enums.StatutDon;
import com.example.dammi.exception.ResourceNotFoundException;
import com.example.dammi.repository.*;
import com.example.dammi.service.DonService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DonServiceImpl implements DonService {

    private final DonRepository donRepository;
    private final UserRepository userRepository;
    private final TypeDonRepository typeDonRepository;
    private final PointCollecteRepository pointCollecteRepository;
    private final TypeSanguinRepository typeSanguinRepository;

    @Override
    @Transactional
    public DonResponse creerDon(DonRequest request) {
        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", request.getUserId()));

        Don don = Don.builder()
                .dateDon(request.getDateDon())
                .status(request.getStatus() != null ? request.getStatus() : StatutDon.EN_COURS)
                .user(user)
                .build();

        if (request.getTypeDonId() != null) {
            don.setTypeDon(typeDonRepository.findById(request.getTypeDonId())
                    .orElseThrow(() -> new ResourceNotFoundException("TypeDon", "id", request.getTypeDonId())));
        }
        if (request.getPointCollecteId() != null) {
            don.setPointCollecte(pointCollecteRepository.findById(request.getPointCollecteId())
                    .orElseThrow(() -> new ResourceNotFoundException("PointCollecte", "id", request.getPointCollecteId())));
        }
        if (request.getTypeSanguinId() != null) {
            don.setTypeSanguin(typeSanguinRepository.findById(request.getTypeSanguinId())
                    .orElseThrow(() -> new ResourceNotFoundException("TypeSanguin", "id", request.getTypeSanguinId())));
        }

        Don saved = donRepository.save(don);

        user.setEligibilityStatus("NON_ELIGIBLE");
        user.setLastDonation(java.time.LocalDate.now());
        user.setStatutPertinent(false);
        userRepository.save(user);

        return toResponse(saved);
    }

    @Override
    public DonResponse getDonById(Long id) {
        return toResponse(findDon(id));
    }

    @Override
    public List<DonResponse> getAllDons() {
        return donRepository.findAll().stream().map(this::toResponse).toList();
    }

    @Override
    public List<DonResponse> getDonsByUser(Long userId) {
        return donRepository.findByUserId(userId).stream().map(this::toResponse).toList();
    }

    @Override
    @Transactional
    public DonResponse updateStatut(Long id, StatutDon statut) {
        Don don = findDon(id);
        don.setStatus(statut);
        return toResponse(donRepository.save(don));
    }

    @Override
    @Transactional
    public void deleteDon(Long id) {
        findDon(id);
        donRepository.deleteById(id);
    }

    private Don findDon(Long id) {
        return donRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Don", "id", id));
    }

    private DonResponse toResponse(Don don) {
        return DonResponse.builder()
                .id(don.getId())
                .dateDon(don.getDateDon())
                .status(don.getStatus())
                .createdAt(don.getCreatedAt())
                .userId(don.getUser().getId())
                .userNom(don.getUser().getPrenom() + " " + don.getUser().getNom())
                .typeDonLabel(don.getTypeDon() != null ? don.getTypeDon().getLabel() : null)
                .pointCollecteNom(don.getPointCollecte() != null ? don.getPointCollecte().getNom() : null)
                .typeSanguinAboGroup(don.getTypeSanguin() != null ? don.getTypeSanguin().getAboGroup() : null)
                .build();
    }

}
