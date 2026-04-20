package com.example.dammi.service.impl;

import com.example.dammi.dto.request.LoginRequest;
import com.example.dammi.dto.request.RegisterRequest;
import com.example.dammi.dto.response.AuthResponse;
import com.example.dammi.entity.TypeSanguin;
import com.example.dammi.entity.User;
import com.example.dammi.entity.enums.Role;
import com.example.dammi.exception.BadRequestException;
import com.example.dammi.exception.ResourceNotFoundException;
import com.example.dammi.repository.TypeSanguinRepository;
import com.example.dammi.repository.UserRepository;
import com.example.dammi.security.JwtTokenProvider;
import com.example.dammi.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final TypeSanguinRepository typeSanguinRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final AuthenticationManager authenticationManager;

    /**
     * Vérifie si l'utilisateur peut donner du sang
     * moins de 2 mois -> NON_ELIGIBLE
     * sinon -> ELIGIBLE
     */
    private String computeEligibilityStatus(LocalDate lastDonation) {
        if (lastDonation == null) {
            return "ELIGIBLE";
        }

        LocalDate limitDate = LocalDate.now().minusMonths(2);

        return lastDonation.isAfter(limitDate)
                ? "NON_ELIGIBLE"
                : "ELIGIBLE";
    }

    @Override
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException(
                    "Email déjà utilisé : " + request.getEmail()
            );
        }

        TypeSanguin typeSanguin = typeSanguinRepository
                .findById(request.getTypeSanguinId())
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "TypeSanguin",
                                "id",
                                request.getTypeSanguinId()
                        )
                );

        String eligibilityStatus =
                computeEligibilityStatus(request.getLastDonation());

        User user = User.builder()
                .prenom(request.getPrenom())
                .nom(request.getNom())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .phone(request.getPhone())
                .sexe(request.getSexe())
                .lastDonation(request.getLastDonation())
                .role(Role.USER)
                .eligibilityStatus(eligibilityStatus)
                .statutPertinent(
                        "ELIGIBLE".equals(eligibilityStatus)
                )
                .typeSanguin(typeSanguin)
                .build();

        user = userRepository.save(user);

        String token = jwtTokenProvider.generateToken(user.getEmail());

        return AuthResponse.builder()
                .token(token)
                .id(user.getId())
                .email(user.getEmail())
                .prenom(user.getPrenom())
                .nom(user.getNom())
                .phone(user.getPhone())
                .sexe(user.getSexe())
                .lastDonation(user.getLastDonation())
                .eligibilityStatus(user.getEligibilityStatus())
                .role(user.getRole())
                .typeSanguinId(
                        user.getTypeSanguin() != null
                                ? user.getTypeSanguin().getId()
                                : null
                )
                .typeSanguinAboGroup(
                        user.getTypeSanguin() != null
                                ? user.getTypeSanguin().getAboGroup()
                                : null
                )
                .build();
    }

    @Override
    @Transactional
    public AuthResponse login(LoginRequest request) {
        Authentication authentication =
                authenticationManager.authenticate(
                        new UsernamePasswordAuthenticationToken(
                                request.getEmail(),
                                request.getPassword()
                        )
                );

        User user = (User) authentication.getPrincipal();

        // recalcul automatique à chaque login
        String eligibilityStatus =
                computeEligibilityStatus(user.getLastDonation());

        user.setEligibilityStatus(eligibilityStatus);
        user.setStatutPertinent(
                "ELIGIBLE".equals(eligibilityStatus)
        );

        userRepository.save(user);

        String token =
                jwtTokenProvider.generateToken(authentication);

        return AuthResponse.builder()
                .token(token)
                .id(user.getId())
                .email(user.getEmail())
                .prenom(user.getPrenom())
                .nom(user.getNom())
                .phone(user.getPhone())
                .sexe(user.getSexe())
                .lastDonation(user.getLastDonation())
                .role(user.getRole())
                .eligibilityStatus(user.getEligibilityStatus())
                .typeSanguinId(
                        user.getTypeSanguin() != null
                                ? user.getTypeSanguin().getId()
                                : null
                )
                .typeSanguinAboGroup(
                        user.getTypeSanguin() != null
                                ? user.getTypeSanguin().getAboGroup()
                                : null
                )
                .build();
    }
}