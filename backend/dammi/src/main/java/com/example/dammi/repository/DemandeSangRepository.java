package com.example.dammi.repository;

import com.example.dammi.entity.DemandeSang;
import com.example.dammi.entity.enums.StatutDemande;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface DemandeSangRepository extends JpaRepository<DemandeSang, Long> {
    List<DemandeSang> findByUserId(Long userId);
    List<DemandeSang> findByStatut(StatutDemande statut);
    List<DemandeSang> findByUrgenceTrue();
    List<DemandeSang> findByTypeSanguinId(Long typeSanguinId);
}
