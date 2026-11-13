package com.mballem.demoparkapi.web.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class VagaUpdateDto {
    @NotBlank(message = "Informe o código da vaga.")
    @Size(min = 4, max = 4, message = "O código da vaga deve ter 4 caracteres.")
    private String codigo;
    private List<Long> recursoIds;
}
