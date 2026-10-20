package com.mballem.demoparkapi.web.dto;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class TarifaDto {
    @NotNull(message = "Informe o valor dos primeiros 15 minutos.")
    @DecimalMin(value = "0.00", message = "O valor não pode ser negativo.")
    @Digits(integer = 5, fraction = 2, message = "Use no máximo duas casas decimais.")
    private BigDecimal primeiros15Minutos;
    @NotNull(message = "Informe o valor da primeira hora.")
    @DecimalMin(value = "0.00", message = "O valor não pode ser negativo.")
    @Digits(integer = 5, fraction = 2, message = "Use no máximo duas casas decimais.")
    private BigDecimal primeiraHora;
    @NotNull(message = "Informe o valor de cada 15 minutos adicionais.")
    @DecimalMin(value = "0.00", message = "O valor não pode ser negativo.")
    @Digits(integer = 5, fraction = 2, message = "Use no máximo duas casas decimais.")
    private BigDecimal adicional15Minutos;
    @NotNull(message = "Informe o percentual de desconto.")
    @Min(value = 0, message = "O desconto deve ficar entre 0% e 100%.")
    @Max(value = 100, message = "O desconto deve ficar entre 0% e 100%.")
    private Integer descontoPercentual;
    @NotNull(message = "Informe a quantidade de usos para o desconto.")
    @Min(value = 1, message = "A quantidade de usos deve ser no mínimo 1.")
    private Integer usosParaDesconto;
    @Size(max = 77, message = "A chave Pix deve ter no máximo 77 caracteres.")
    private String chavePix;
    @Size(max = 25, message = "O nome do recebedor deve ter no máximo 25 caracteres.")
    private String nomeRecebedor;
    @Size(max = 15, message = "A cidade deve ter no máximo 15 caracteres.")
    private String cidade;
}
