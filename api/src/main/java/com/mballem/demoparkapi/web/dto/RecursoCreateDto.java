package com.mballem.demoparkapi.web.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class RecursoCreateDto {
    @NotBlank(message = "Informe o nome do recurso.")
    @Size(max = 40, message = "O nome deve ter no máximo 40 caracteres.")
    private String nome;
    @Size(max = 100, message = "A descrição deve ter no máximo 100 caracteres.")
    private String descricao;
}
