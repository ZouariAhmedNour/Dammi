package com.example.dammi.service.impl;

import com.example.dammi.dto.request.StockSanguinRequest;
import com.example.dammi.dto.response.StockSanguinResponse;
import com.example.dammi.entity.StockSanguin;
import com.example.dammi.exception.ResourceNotFoundException;
import com.example.dammi.repository.PointCollecteRepository;
import com.example.dammi.repository.StockSanguinRepository;
import com.example.dammi.repository.TypeSanguinRepository;
import com.example.dammi.service.StockSanguinService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class StockSanguinServiceImpl implements StockSanguinService {

    private final StockSanguinRepository stockRepository;
    private final TypeSanguinRepository typeSanguinRepository;
    private final PointCollecteRepository pointCollecteRepository;

    @Override
    @Transactional
    public StockSanguinResponse creerStock(StockSanguinRequest request) {
        StockSanguin stock = StockSanguin.builder()
                .quantiteDisponible(request.getQuantiteDisponible())
                .seuilMinimum(request.getSeuilMinimum())
                .typeSanguin(typeSanguinRepository.findById(request.getTypeSanguinId())
                        .orElseThrow(() -> new ResourceNotFoundException("TypeSanguin", "id", request.getTypeSanguinId())))
                .build();

        if (request.getPointCollecteId() != null) {
            stock.setPointCollecte(pointCollecteRepository.findById(request.getPointCollecteId())
                    .orElseThrow(() -> new ResourceNotFoundException("PointCollecte", "id", request.getPointCollecteId())));
        }

        return toResponse(stockRepository.save(stock));
    }

    @Override
    public StockSanguinResponse getById(Long id) {
        return toResponse(find(id));
    }

    @Override
    public List<StockSanguinResponse> getAll() {
        return stockRepository.findAll().stream().map(this::toResponse).toList();
    }

    @Override
    public List<StockSanguinResponse> getStocksSousLeSeuil() {
        return stockRepository.findStocksEnDessousDuSeuil().stream().map(this::toResponse).toList();
    }

    @Override
    @Transactional
    public StockSanguinResponse mettreAJourStock(Long id, int nouvelleQuantite) {
        StockSanguin stock = find(id);
        stock.setQuantiteDisponible(nouvelleQuantite);
        return toResponse(stockRepository.save(stock));
    }

    @Override
    @Transactional
    public void delete(Long id) {
        find(id);
        stockRepository.deleteById(id);
    }

    private StockSanguin find(Long id) {
        return stockRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("StockSanguin", "id", id));
    }

    private StockSanguinResponse toResponse(StockSanguin s) {
        return StockSanguinResponse.builder()
                .id(s.getId())
                .quantiteDisponible(s.getQuantiteDisponible())
                .seuilMinimum(s.getSeuilMinimum())
                .sousLeSeuil(s.getQuantiteDisponible() <= s.getSeuilMinimum())
                .typeSanguinAboGroup(s.getTypeSanguin().getAboGroup())
                .pointCollecteNom(s.getPointCollecte() != null ? s.getPointCollecte().getNom() : null)
                .build();
    }
}
