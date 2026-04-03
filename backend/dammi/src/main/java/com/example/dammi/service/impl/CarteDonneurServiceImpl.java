package com.example.dammi.service.impl;

import com.example.dammi.entity.CarteDonneur;
import com.example.dammi.entity.User;
import com.example.dammi.exception.BadRequestException;
import com.example.dammi.exception.ResourceNotFoundException;
import com.example.dammi.repository.CarteDonneurRepository;
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

    @Override @Transactional
    public CarteDonneur generateCard(Long userId) {
        if (carteDonneurRepository.existsByUserId(userId))
            throw new BadRequestException("Une carte existe déjà pour cet utilisateur");

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        CarteDonneur carte = CarteDonneur.builder()
                .user(user)
                .groupeSanguin(user.getEligibilityStatus())
                .nbDon(0)
                .dateEditionCarte(LocalDate.now())
                .build();

        return carteDonneurRepository.save(carte);
    }

    @Override
    public CarteDonneur getCardByUser(Long userId) {
        return carteDonneurRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("CarteDonneur", "userId", userId));
    }

}
