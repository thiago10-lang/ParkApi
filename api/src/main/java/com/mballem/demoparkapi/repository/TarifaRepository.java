package com.mballem.demoparkapi.repository;

import com.mballem.demoparkapi.entity.Tarifa;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TarifaRepository extends JpaRepository<Tarifa, Long> {
}
