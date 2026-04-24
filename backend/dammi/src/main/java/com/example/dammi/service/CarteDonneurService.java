package com.example.dammi.service;

import com.example.dammi.entity.CarteDonneur;

public interface CarteDonneurService {
    CarteDonneur generateCard(Long userId);
    CarteDonneur getCardByUser(Long userId);
    boolean canAccessCard(Long userId);

}
