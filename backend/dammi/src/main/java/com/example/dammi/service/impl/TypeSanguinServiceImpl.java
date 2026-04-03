package com.example.dammi.service.impl;

import com.example.dammi.dto.request.TypeSanguinRequest;
import com.example.dammi.entity.TypeSanguin;
import com.example.dammi.exception.BadRequestException;
import com.example.dammi.exception.ResourceNotFoundException;
import com.example.dammi.repository.TypeSanguinRepository;
import com.example.dammi.service.TypeSanguinService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TypeSanguinServiceImpl implements TypeSanguinService {

    private final TypeSanguinRepository repository;


    @Override @Transactional
    public TypeSanguin ajouterType(TypeSanguinRequest req) {
        if (repository.existsByAboGroup(req.getAboGroup()))
            throw new BadRequestException("Type sanguin déjà existant : " + req.getAboGroup());
        return repository.save(TypeSanguin.builder()
                .label(req.getLabel()).aboGroup(req.getAboGroup()).build());
    }

    @Override
    public TypeSanguin getById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("TypeSanguin", "id", id));
    }

    @Override
    public List<TypeSanguin> getAll() { return repository.findAll(); }

    @Override @Transactional
    public TypeSanguin modifierType(Long id, TypeSanguinRequest req) {
        TypeSanguin t = getById(id);
        t.setLabel(req.getLabel());
        t.setAboGroup(req.getAboGroup());
        return repository.save(t);
    }

    @Override @Transactional
    public void supprimerType(Long id) { getById(id); repository.deleteById(id); }

}
