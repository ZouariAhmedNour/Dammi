package com.example.dammi.repository;

import com.example.dammi.entity.TypeDon;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.*;

@Repository

public interface TypeDonRepository extends JpaRepository<TypeDon, Long> {
    Optional<TypeDon> findByLabel(String label);
    boolean existsByLabel(String label);
}
