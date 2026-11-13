package com.mballem.demoparkapi.web.dto.mapper;

import com.mballem.demoparkapi.entity.Recurso;
import com.mballem.demoparkapi.web.dto.RecursoCreateDto;
import com.mballem.demoparkapi.web.dto.RecursoResponseDto;
import lombok.AccessLevel;
import lombok.NoArgsConstructor;

import java.util.List;

@NoArgsConstructor(access = AccessLevel.PRIVATE)
public class RecursoMapper {

    public static Recurso toRecurso(RecursoCreateDto dto) {
        Recurso recurso = new Recurso();
        recurso.setNome(dto.getNome().trim());
        recurso.setDescricao(dto.getDescricao());
        return recurso;
    }

    public static RecursoResponseDto toDto(Recurso recurso) {
        return new RecursoResponseDto(recurso.getId(), recurso.getNome(), recurso.getDescricao());
    }

    public static List<RecursoResponseDto> toListDto(List<Recurso> recursos) {
        return recursos.stream().map(RecursoMapper::toDto).toList();
    }
}
