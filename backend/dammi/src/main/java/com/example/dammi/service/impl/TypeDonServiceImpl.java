package com.example.dammi.service.impl;

import com.example.dammi.dto.request.TypeDonRequest;
import com.example.dammi.entity.TypeDon;
import com.example.dammi.exception.BadRequestException;
import com.example.dammi.exception.ResourceNotFoundException;
import com.example.dammi.repository.TypeDonRepository;
import com.example.dammi.service.TypeDonService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TypeDonServiceImpl implements TypeDonService {

    private final TypeDonRepository repository;

    @Override @Transactional
    public TypeDon ajouterType(TypeDonRequest req) {
        if (repository.existsByLabel(req.getLabel()))
            throw new BadRequestException("Type de don déjà existant : " + req.getLabel());
        return repository.save(TypeDon.builder().label(req.getLabel()).build());
    }

    @Override
    public TypeDon getById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("TypeDon", "id", id));
    }

    @Override
    public List<TypeDon> getAll() { return repository.findAll(); }

    @Override @Transactional
    public TypeDon modifierType(Long id, TypeDonRequest req) {
        TypeDon t = getById(id);
        t.setLabel(req.getLabel());
        return repository.save(t);
    }

    @Override @Transactional
    public void supprimerType(Long id) { getById(id); repository.deleteById(id); }



}
