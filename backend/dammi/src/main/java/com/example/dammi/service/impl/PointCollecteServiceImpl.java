package com.example.dammi.service.impl;

import com.example.dammi.dto.request.PointCollecteRequest;
import com.example.dammi.entity.PointCollecte;
import com.example.dammi.entity.TypeDon;
import com.example.dammi.exception.ResourceNotFoundException;
import com.example.dammi.repository.PointCollecteRepository;
import com.example.dammi.repository.TypeDonRepository;
import com.example.dammi.service.PointCollecteService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class PointCollecteServiceImpl implements PointCollecteService {

    private final PointCollecteRepository repository;
    private final TypeDonRepository typeDonRepository;

    @Override @Transactional
    public PointCollecte ajouterPointCollecte(PointCollecteRequest req) {
        return repository.save(toEntity(req, new PointCollecte()));
    }

    @Override
    public PointCollecte getById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("PointCollecte", "id", id));
    }

    @Override
    public List<PointCollecte> getAll() { return repository.findAll(); }

    @Override
    public List<PointCollecte> getByGouvernorat(String gouvernorat) {
        return repository.findByGouvernoratContainingIgnoreCase(gouvernorat);
    }

    @Override @Transactional
    public PointCollecte modifierPointCollecte(Long id, PointCollecteRequest req) {
        PointCollecte pc = getById(id);
        return repository.save(toEntity(req, pc));
    }

    @Override @Transactional
    public void delete(Long id) { getById(id); repository.deleteById(id); }

    private PointCollecte toEntity(PointCollecteRequest req, PointCollecte pc) {
        pc.setNom(req.getNom());
        pc.setGouvernorat(req.getGouvernorat());
        pc.setDelegation(req.getDelegation());
        pc.setCodePostal(req.getCodePostal());
        pc.setAdressePostale(req.getAdressePostale());
        pc.setCapacite(req.getCapacite());
        pc.setTelephone(req.getTelephone());
        pc.setLatitude(req.getLatitude());
        pc.setLongitude(req.getLongitude());
        pc.setDescription(req.getDescription());
        pc.setTypesDon(resolveTypesDon(req.getTypeDonIds()));
        return pc;
    }

    private Set<TypeDon> resolveTypesDon(List<Long> ids) {
        Set<TypeDon> result = new LinkedHashSet<>();

        for (Long id : ids) {
            TypeDon typeDon = typeDonRepository.findById(id)
                    .orElseThrow(() -> new ResourceNotFoundException("TypeDon", "id", id));
            result.add(typeDon);
        }

        return result;
    }
}
