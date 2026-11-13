package com.mballem.demoparkapi.util;

import com.mballem.demoparkapi.entity.Tarifa;
import lombok.AccessLevel;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

@NoArgsConstructor(access = AccessLevel.PRIVATE)
public class EstacionamentoUtils {

    public static BigDecimal calcularCusto(LocalDateTime entrada, LocalDateTime saida, Tarifa tarifa) {
        long minutos = entrada.until(saida, ChronoUnit.MINUTES);
        BigDecimal total;
        if (minutos <= 15) {
            total = tarifa.getPrimeiros15Minutos();
        } else if (minutos <= 60) {
            total = tarifa.getPrimeiraHora();
        } else {
            long adicionais = (minutos - 60 + 14) / 15;
            total = tarifa.getPrimeiraHora().add(tarifa.getAdicional15Minutos().multiply(BigDecimal.valueOf(adicionais)));
        }
        return total.setScale(2, RoundingMode.HALF_EVEN);
    }

    public static BigDecimal calcularDesconto(BigDecimal custo, long numeroDeVezes, Tarifa tarifa) {
        int usos = tarifa.getUsosParaDesconto();
        boolean aplica = numeroDeVezes > 0 && usos > 0 && numeroDeVezes % usos == 0;
        BigDecimal desconto = aplica
                ? custo.multiply(BigDecimal.valueOf(tarifa.getDescontoPercentual())).divide(BigDecimal.valueOf(100))
                : BigDecimal.ZERO;
        return desconto.setScale(2, RoundingMode.HALF_EVEN);
    }

    public static String gerarRecibo() {
        return gerarRecibo(LocalDateTime.now());
    }

    public static String gerarRecibo(LocalDateTime dataHora) {
        return dataHora.format(DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss"));
    }
}
