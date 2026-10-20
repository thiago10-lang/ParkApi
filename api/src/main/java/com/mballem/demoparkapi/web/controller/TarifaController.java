package com.mballem.demoparkapi.web.controller;

import com.mballem.demoparkapi.entity.Tarifa;
import com.mballem.demoparkapi.service.TarifaService;
import com.mballem.demoparkapi.web.dto.TarifaDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Tarifas", description = "Tabela de preços e dados de recebimento via Pix")
@RequiredArgsConstructor
@RestController
@RequestMapping("api/v1/tarifas")
public class TarifaController {

    private final TarifaService tarifaService;

    @Operation(summary = "Consultar a tabela de preços", description = "Requisição exige uso de um bearer token.",
            security = @SecurityRequirement(name = "security"))
    @GetMapping
    public ResponseEntity<TarifaDto> getTarifa() {
        return ResponseEntity.ok(toDto(tarifaService.obter()));
    }

    @Operation(summary = "Atualizar a tabela de preços", description = "Acesso restrito a Role='ADMIN'",
            security = @SecurityRequirement(name = "security"))
    @PutMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<TarifaDto> atualizar(@RequestBody @Valid TarifaDto dto) {
        return ResponseEntity.ok(toDto(tarifaService.atualizar(dto)));
    }

    private TarifaDto toDto(Tarifa tarifa) {
        return new TarifaDto(
                tarifa.getPrimeiros15Minutos(),
                tarifa.getPrimeiraHora(),
                tarifa.getAdicional15Minutos(),
                tarifa.getDescontoPercentual(),
                tarifa.getUsosParaDesconto(),
                tarifa.getChavePix(),
                tarifa.getNomeRecebedor(),
                tarifa.getCidade()
        );
    }
}
