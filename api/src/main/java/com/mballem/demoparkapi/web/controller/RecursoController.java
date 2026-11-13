package com.mballem.demoparkapi.web.controller;

import com.mballem.demoparkapi.entity.Recurso;
import com.mballem.demoparkapi.service.RecursoService;
import com.mballem.demoparkapi.web.dto.RecursoCreateDto;
import com.mballem.demoparkapi.web.dto.RecursoResponseDto;
import com.mballem.demoparkapi.web.dto.mapper.RecursoMapper;
import com.mballem.demoparkapi.web.exception.ErrorMessage;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.List;

@Tag(name = "Recursos", description = "Recursos das vagas (coberta, PCD, carregador elétrico). Relacionamento muitos-para-muitos com Vaga")
@RequiredArgsConstructor
@RestController
@RequestMapping("api/v1/recursos")
public class RecursoController {

    private final RecursoService recursoService;

    @Operation(summary = "Criar recurso", description = "Acesso restrito a Role='ADMIN'", security = @SecurityRequirement(name = "security"),
            responses = {
                    @ApiResponse(responseCode = "201", description = "Recurso criado",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = RecursoResponseDto.class))),
                    @ApiResponse(responseCode = "409", description = "Nome já cadastrado",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorMessage.class))),
                    @ApiResponse(responseCode = "422", description = "Dados inválidos",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorMessage.class)))
            })
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<RecursoResponseDto> create(@RequestBody @Valid RecursoCreateDto dto) {
        Recurso recurso = recursoService.salvar(RecursoMapper.toRecurso(dto));
        URI location = ServletUriComponentsBuilder.fromCurrentRequestUri().path("/{id}")
                .buildAndExpand(recurso.getId()).toUri();
        return ResponseEntity.created(location).body(RecursoMapper.toDto(recurso));
    }

    @Operation(summary = "Listar recursos", security = @SecurityRequirement(name = "security"))
    @GetMapping
    public ResponseEntity<List<RecursoResponseDto>> getAll() {
        return ResponseEntity.ok(RecursoMapper.toListDto(recursoService.buscarTodos()));
    }

    @Operation(summary = "Buscar recurso pelo id", security = @SecurityRequirement(name = "security"),
            responses = {
                    @ApiResponse(responseCode = "200", description = "Recurso encontrado",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = RecursoResponseDto.class))),
                    @ApiResponse(responseCode = "404", description = "Recurso não encontrado",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorMessage.class)))
            })
    @GetMapping("/{id}")
    public ResponseEntity<RecursoResponseDto> getById(@PathVariable Long id) {
        return ResponseEntity.ok(RecursoMapper.toDto(recursoService.buscarPorId(id)));
    }

    @Operation(summary = "Atualizar recurso", description = "Acesso restrito a Role='ADMIN'", security = @SecurityRequirement(name = "security"),
            responses = {
                    @ApiResponse(responseCode = "200", description = "Recurso atualizado",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = RecursoResponseDto.class))),
                    @ApiResponse(responseCode = "404", description = "Recurso não encontrado",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorMessage.class))),
                    @ApiResponse(responseCode = "409", description = "Nome já cadastrado",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorMessage.class)))
            })
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<RecursoResponseDto> update(@PathVariable Long id, @RequestBody @Valid RecursoCreateDto dto) {
        Recurso recurso = recursoService.atualizar(id, dto.getNome(), dto.getDescricao());
        return ResponseEntity.ok(RecursoMapper.toDto(recurso));
    }

    @Operation(summary = "Remover recurso", description = "Remove o recurso e as associações com as vagas. Acesso restrito a Role='ADMIN'",
            security = @SecurityRequirement(name = "security"),
            responses = {
                    @ApiResponse(responseCode = "204", description = "Recurso removido"),
                    @ApiResponse(responseCode = "404", description = "Recurso não encontrado",
                            content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorMessage.class)))
            })
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        recursoService.excluir(id);
        return ResponseEntity.noContent().build();
    }
}
