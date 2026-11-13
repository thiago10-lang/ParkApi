package com.mballem.demoparkapi.web.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class VagaResponseDto {
    private Long id;
    private String codigo;
    private String status;
    private List<RecursoResponseDto> recursos = new ArrayList<>();
}
