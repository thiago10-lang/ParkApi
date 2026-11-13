package com.mballem.demoparkapi.web.dto.mapper;

import com.mballem.demoparkapi.entity.Recurso;
import com.mballem.demoparkapi.entity.Vaga;
import com.mballem.demoparkapi.web.dto.RecursoResponseDto;
import com.mballem.demoparkapi.web.dto.VagaCreateDto;
import com.mballem.demoparkapi.web.dto.VagaResponseDto;
import lombok.AccessLevel;
import lombok.NoArgsConstructor;
import org.modelmapper.ModelMapper;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

@NoArgsConstructor(access = AccessLevel.PRIVATE)
public class VagaMapper {

    public static Vaga toVaga(VagaCreateDto dto) {
        return new ModelMapper().map(dto, Vaga.class);
    }

    public static VagaResponseDto toDto(Vaga vaga) {
        List<RecursoResponseDto> recursos = vaga.getRecursos().stream()
                .sorted(Comparator.comparing(Recurso::getNome))
                .map(RecursoMapper::toDto)
                .toList();
        return new VagaResponseDto(vaga.getId(), vaga.getCodigo(), vaga.getStatus().name(), new ArrayList<>(recursos));
    }
}
