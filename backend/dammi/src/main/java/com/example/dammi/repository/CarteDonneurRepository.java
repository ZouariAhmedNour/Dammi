package com.example.dammi.repository;

import com.example.dammi.entity.CarteDonneur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.*;

@Repository
public interface CarteDonneurRepository extends JpaRepository<CarteDonneur, Long> {
    Optional<CarteDonneur> findByUserId(Long userId);
    boolean existsByUserId(Long userId);
}
