package com.mballem.demoparkapi.repository;

import com.mballem.demoparkapi.entity.Recurso;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RecursoRepository extends JpaRepository<Recurso, Long> {

    List<Recurso> findAllByOrderByNomeAsc();

    boolean existsByNome(String nome);
}
