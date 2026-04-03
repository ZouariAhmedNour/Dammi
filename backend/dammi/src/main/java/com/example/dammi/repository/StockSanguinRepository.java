package com.example.dammi.repository;

import com.example.dammi.entity.StockSanguin;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface StockSanguinRepository extends JpaRepository<StockSanguin, Long> {
    Optional<StockSanguin> findByTypeSanguinId(Long typeSanguinId);
    List<StockSanguin> findByPointCollecteId(Long pointCollecteId);

    @Query("SELECT s FROM StockSanguin s WHERE s.quantiteDisponible <= s.seuilMinimum")
    List<StockSanguin> findStocksEnDessousDuSeuil();
}
