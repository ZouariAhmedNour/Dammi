package com.example.dammi.repository;

import com.example.dammi.entity.RendezVous;
import com.example.dammi.entity.enums.StatutRendezVous;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface RendezVousRepository extends JpaRepository<RendezVous, Long> {
    List<RendezVous> findByUserId(Long userId);
    List<RendezVous> findByStatut(StatutRendezVous statut);
    List<RendezVous> findByPointCollecteId(Long pointCollecteId);
    List<RendezVous> findByDateHeureBetween(LocalDateTime debut, LocalDateTime fin);
}
