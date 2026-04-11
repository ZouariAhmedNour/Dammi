package com.example.dammi.repository;

import com.example.dammi.entity.CreneauCollecte;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Repository
public interface CreneauCollecteRepository extends JpaRepository<CreneauCollecte, Long> {

    List<CreneauCollecte> findByPointCollecteIdAndTypeDonIdAndDateCollecteAndActifTrueOrderByHeureDebutAsc(
            Long pointCollecteId,
            Long typeDonId,
            LocalDate dateCollecte
    );

    List<CreneauCollecte> findByPointCollecteIdAndTypeDonIdAndDateCollecteBetweenAndActifTrueOrderByDateCollecteAscHeureDebutAsc(
            Long pointCollecteId,
            Long typeDonId,
            LocalDate start,
            LocalDate end
    );

    boolean existsByPointCollecteIdAndTypeDonIdAndDateCollecteAndHeureDebut(
            Long pointCollecteId,
            Long typeDonId,
            LocalDate dateCollecte,
            LocalTime heureDebut
    );

    void deleteByPointCollecteIdAndDateCollecteBetween(
            Long pointCollecteId,
            LocalDate start,
            LocalDate end
    );
}
