package com.example.dammi.service;

import com.example.dammi.dto.response.CreneauCollecteResponse;
import com.example.dammi.dto.response.JourDisponibleResponse;

import java.util.List;

public interface CreneauCollecteService {
    List<JourDisponibleResponse> getJoursDisponibles(Long pointCollecteId, Long typeDonId, int year, int month);
    List<CreneauCollecteResponse> getCreneauxDuJour(Long pointCollecteId, Long typeDonId, String date);
    void genererPlanningAnnuel(Long pointCollecteId, int year);
}
