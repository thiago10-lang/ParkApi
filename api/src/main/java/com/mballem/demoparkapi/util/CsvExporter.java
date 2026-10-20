package com.mballem.demoparkapi.util;

import com.mballem.demoparkapi.repository.projection.ClienteVagaProjection;
import lombok.AccessLevel;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

@NoArgsConstructor(access = AccessLevel.PRIVATE)
public class CsvExporter {

    private static final String SEPARADOR = ";";
    private static final DateTimeFormatter DATA_HORA = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final Map<String, String> FORMAS = Map.of("PIX", "Pix", "CARTAO", "Cartão", "DINHEIRO", "Dinheiro");
    private static final String CABECALHO = String.join(SEPARADOR,
            "Recibo", "Placa", "Marca", "Modelo", "Cor", "Motorista", "CPF", "Vaga",
            "Entrada", "Saída", "Valor", "Desconto", "Total", "Pagamento", "Situação");

    public static byte[] estacionamentos(List<ClienteVagaProjection> registros) {
        StringBuilder csv = new StringBuilder("﻿").append(CABECALHO).append("\r\n");
        for (ClienteVagaProjection r : registros) {
            boolean finalizado = r.getDataSaida() != null;
            BigDecimal total = finalizado ? valor(r.getValor()).subtract(valor(r.getDesconto())) : null;
            csv.append(String.join(SEPARADOR,
                    texto(r.getRecibo()),
                    texto(r.getPlaca()),
                    texto(r.getMarca()),
                    texto(r.getModelo()),
                    texto(r.getCor()),
                    texto(r.getClienteNome()),
                    texto(r.getClienteCpf()),
                    texto(r.getVagaCodigo()),
                    data(r.getDataEntrada()),
                    data(r.getDataSaida()),
                    moeda(r.getValor()),
                    moeda(r.getDesconto()),
                    moeda(total),
                    texto(FORMAS.getOrDefault(String.valueOf(r.getFormaPagamento()), finalizado ? "Não informado" : "")),
                    finalizado ? "Finalizado" : "No pátio"
            )).append("\r\n");
        }
        return csv.toString().getBytes(StandardCharsets.UTF_8);
    }

    private static BigDecimal valor(BigDecimal valor) {
        return valor == null ? BigDecimal.ZERO : valor;
    }

    private static String moeda(BigDecimal valor) {
        return valor == null ? "" : valor.setScale(2, RoundingMode.HALF_EVEN).toPlainString().replace('.', ',');
    }

    private static String data(LocalDateTime data) {
        return data == null ? "" : data.format(DATA_HORA);
    }

    private static String texto(String valor) {
        if (valor == null) {
            return "";
        }
        String limpo = valor.replace("\"", "\"\"");
        return limpo.contains(SEPARADOR) || limpo.contains("\n") ? "\"" + limpo + "\"" : limpo;
    }
}
