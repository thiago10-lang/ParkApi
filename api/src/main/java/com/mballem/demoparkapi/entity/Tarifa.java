package com.mballem.demoparkapi.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.io.Serializable;
import java.math.BigDecimal;

@Getter @Setter @NoArgsConstructor
@Entity
@Table(name = "tarifas")
public class Tarifa implements Serializable {

    public static final Long ID_PADRAO = 1L;

    @Id
    private Long id;
    @Column(name = "primeiros_15_minutos", nullable = false, columnDefinition = "decimal(7,2)")
    private BigDecimal primeiros15Minutos;
    @Column(name = "primeira_hora", nullable = false, columnDefinition = "decimal(7,2)")
    private BigDecimal primeiraHora;
    @Column(name = "adicional_15_minutos", nullable = false, columnDefinition = "decimal(7,2)")
    private BigDecimal adicional15Minutos;
    @Column(name = "desconto_percentual", nullable = false)
    private Integer descontoPercentual;
    @Column(name = "usos_para_desconto", nullable = false)
    private Integer usosParaDesconto;
    @Column(name = "chave_pix", length = 77)
    private String chavePix;
    @Column(name = "nome_recebedor", length = 25)
    private String nomeRecebedor;
    @Column(name = "cidade", length = 15)
    private String cidade;

    public static Tarifa padrao() {
        Tarifa tarifa = new Tarifa();
        tarifa.setId(ID_PADRAO);
        tarifa.setPrimeiros15Minutos(new BigDecimal("5.00"));
        tarifa.setPrimeiraHora(new BigDecimal("9.25"));
        tarifa.setAdicional15Minutos(new BigDecimal("1.75"));
        tarifa.setDescontoPercentual(30);
        tarifa.setUsosParaDesconto(10);
        tarifa.setChavePix("");
        tarifa.setNomeRecebedor("PARKAPI");
        tarifa.setCidade("SAO PAULO");
        return tarifa;
    }
}
