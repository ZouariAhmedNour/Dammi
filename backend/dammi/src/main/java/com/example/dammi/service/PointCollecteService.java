package com.example.dammi.service;

import com.example.dammi.dto.request.PointCollecteRequest;
import com.example.dammi.entity.PointCollecte;

import java.util.List;

public interface PointCollecteService {
    PointCollecte ajouterPointCollecte(PointCollecteRequest request);
    PointCollecte getById(Long id);
    List<PointCollecte> getAll();
    List<PointCollecte> getByGouvernorat(String gouvernorat);
    PointCollecte modifierPointCollecte(Long id, PointCollecteRequest request);
    void delete(Long id);
}
