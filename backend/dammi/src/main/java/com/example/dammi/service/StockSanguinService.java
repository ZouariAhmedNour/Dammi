package com.example.dammi.service;

import com.example.dammi.dto.request.StockSanguinRequest;
import com.example.dammi.dto.response.StockSanguinResponse;

import java.util.List;

public interface StockSanguinService {
    StockSanguinResponse creerStock(StockSanguinRequest request);
    StockSanguinResponse getById(Long id);
    List<StockSanguinResponse> getAll();
    List<StockSanguinResponse> getStocksSousLeSeuil();
    StockSanguinResponse mettreAJourStock(Long id, int nouvelleQuantite);
    void delete(Long id);
}
