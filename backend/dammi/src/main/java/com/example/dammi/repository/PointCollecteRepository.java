package com.example.dammi.repository;

import com.example.dammi.entity.PointCollecte;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
@Repository
public interface PointCollecteRepository extends JpaRepository<PointCollecte, Long> {
    List<PointCollecte> findByVille(String ville);
    List<PointCollecte> findByVilleContainingIgnoreCase(String ville);
}
