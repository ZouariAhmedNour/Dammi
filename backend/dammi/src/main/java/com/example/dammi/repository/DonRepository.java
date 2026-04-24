package com.example.dammi.repository;

import com.example.dammi.entity.Don;
import com.example.dammi.entity.enums.StatutDon;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface DonRepository extends JpaRepository<Don, Long> {
    List<Don> findByUserId(Long userId);
    List<Don> findByStatus(StatutDon status);
    List<Don> findByPointCollecteId(Long pointCollecteId);
    List<Don> findByDateDonBetween(LocalDate debut, LocalDate fin);
    long countByUserIdAndStatus(Long userId, StatutDon status);
    boolean existsByUserIdAndStatus(Long userId, StatutDon status);
}
