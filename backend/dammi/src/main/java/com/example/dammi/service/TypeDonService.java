package com.example.dammi.service;

import com.example.dammi.dto.request.TypeDonRequest;
import com.example.dammi.entity.TypeDon;

import java.util.List;

public interface TypeDonService {
    TypeDon ajouterType(TypeDonRequest request);
    TypeDon getById(Long id);
    List<TypeDon> getAll();
    TypeDon modifierType(Long id, TypeDonRequest request);
    void supprimerType(Long id);
}
