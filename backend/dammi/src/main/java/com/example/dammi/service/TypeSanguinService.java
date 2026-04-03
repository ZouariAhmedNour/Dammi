package com.example.dammi.service;

import com.example.dammi.dto.request.TypeSanguinRequest;
import com.example.dammi.entity.TypeSanguin;

import java.util.List;

public interface TypeSanguinService {
    TypeSanguin ajouterType(TypeSanguinRequest request);
    TypeSanguin getById(Long id);
    List<TypeSanguin> getAll();
    TypeSanguin modifierType(Long id, TypeSanguinRequest request);
    void supprimerType(Long id);
}
