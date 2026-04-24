package com.example.dammi.service.impl;

import com.example.dammi.dto.response.CarteDonneurResponse;
import com.example.dammi.entity.CarteDonneur;
import com.example.dammi.entity.User;
import com.example.dammi.entity.enums.StatutDon;
import com.example.dammi.exception.BadRequestException;
import com.example.dammi.exception.ResourceNotFoundException;
import com.example.dammi.repository.CarteDonneurRepository;
import com.example.dammi.repository.DonRepository;
import com.example.dammi.repository.UserRepository;
import com.example.dammi.service.CarteDonneurService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

@Service
@RequiredArgsConstructor
public class CarteDonneurServiceImpl implements CarteDonneurService {

    private final CarteDonneurRepository carteDonneurRepository;
    private final UserRepository userRepository;
    private final DonRepository donRepository;

    @Override
    @Transactional
    public CarteDonneur generateCard(Long userId) {

        // 🔒 Vérifier si au moins un don VALIDÉ existe
        boolean hasValidDonation =
                donRepository.existsByUserIdAndStatus(userId, StatutDon.VALIDE);

        if (!hasValidDonation) {
            throw new BadRequestException(
                    "Vous devez faire au moins un don validé pour obtenir votre carte donneur"
            );
        }

        if (carteDonneurRepository.existsByUserId(userId)) {
            throw new BadRequestException("Une carte existe déjà pour cet utilisateur");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        int totalDons = (int) donRepository
                .countByUserIdAndStatus(userId, StatutDon.VALIDE);

        CarteDonneur carte = CarteDonneur.builder()
                .user(user)
                .groupeSanguin(user.getTypeSanguin().getAboGroup()) // ✔️ CORRIGÉ
                .nbDon(totalDons) // ✔️ CORRIGÉ
                .dateEditionCarte(LocalDate.now())
                .lieuCollecte("DAMMI")
                .build();

        return carteDonneurRepository.save(carte);
    }

    @Override
    public CarteDonneur getCardByUser(Long userId) {
        return carteDonneurRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("CarteDonneur", "userId", userId));
    }

    // 🔥 NOUVEAU : pour le frontend
    public boolean canAccessCard(Long userId) {
        return donRepository.existsByUserIdAndStatus(userId, StatutDon.VALIDE);
    }

    private CarteDonneurResponse toResponse(CarteDonneur c) {
        return CarteDonneurResponse.builder()
                .id(c.getId())
                .groupeSanguin(c.getGroupeSanguin())
                .nbDon(c.getNbDon())
                .dateEditionCarte(c.getDateEditionCarte())
                .lieuCollecte(c.getLieuCollecte())
                .build();
    }
}
