package com.example.dammi.repository;

import com.example.dammi.entity.TypeSanguin;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.*;

@Repository

public interface TypeSanguinRepository extends JpaRepository<TypeSanguin, Long> {
    Optional<TypeSanguin> findByAboGroup(String aboGroup);
    boolean existsByAboGroup(String aboGroup);
}
