package com.mballem.demoparkapi.service;

import com.mballem.demoparkapi.entity.Tarifa;
import com.mballem.demoparkapi.repository.TarifaRepository;
import com.mballem.demoparkapi.web.dto.TarifaDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@RequiredArgsConstructor
@Service
public class TarifaService {

    private final TarifaRepository repository;

    @Transactional
    public Tarifa obter() {
        return repository.findById(Tarifa.ID_PADRAO).orElseGet(() -> repository.save(Tarifa.padrao()));
    }

    @Transactional
    public Tarifa atualizar(TarifaDto dto) {
        Tarifa tarifa = obter();
        tarifa.setPrimeiros15Minutos(dto.getPrimeiros15Minutos());
        tarifa.setPrimeiraHora(dto.getPrimeiraHora());
        tarifa.setAdicional15Minutos(dto.getAdicional15Minutos());
        tarifa.setDescontoPercentual(dto.getDescontoPercentual());
        tarifa.setUsosParaDesconto(dto.getUsosParaDesconto());
        tarifa.setChavePix(limpar(dto.getChavePix()));
        tarifa.setNomeRecebedor(limpar(dto.getNomeRecebedor()));
        tarifa.setCidade(limpar(dto.getCidade()));
        return tarifa;
    }

    private String limpar(String valor) {
        return valor == null ? "" : valor.trim();
    }
}
