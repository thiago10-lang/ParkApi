package com.mballem.demoparkapi.web.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class VeiculoUpdateDto {
    @NotBlank(message = "Informe a placa.")
    @Pattern(regexp = "^([A-Za-z]{3}-[0-9]{4}|[A-Za-z]{3}[0-9][A-Za-z][0-9]{2})$",
            message = "A placa deve seguir o padrão AAA-0000 ou AAA0A00.")
    private String placa;
    @NotBlank(message = "Informe a marca.")
    @Size(max = 45)
    private String marca;
    @NotBlank(message = "Informe o modelo.")
    @Size(max = 45)
    private String modelo;
    @NotBlank(message = "Informe a cor.")
    @Size(max = 45)
    private String cor;
}
