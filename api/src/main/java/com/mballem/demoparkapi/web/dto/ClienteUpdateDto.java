package com.mballem.demoparkapi.web.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class ClienteUpdateDto {
    @NotBlank(message = "Informe o nome do cliente.")
    @Size(min = 5, max = 100, message = "O nome deve ter entre 5 e 100 caracteres.")
    private String nome;
}
