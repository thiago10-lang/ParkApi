package com.mballem.demoparkapi.service;

import com.mballem.demoparkapi.entity.Vaga;
import com.mballem.demoparkapi.exception.CodigoUniqueViolationException;
import com.mballem.demoparkapi.exception.EntityNotFoundException;
import com.mballem.demoparkapi.exception.VagaDisponivelException;
import com.mballem.demoparkapi.exception.RegraNegocioException;
import com.mballem.demoparkapi.repository.ClienteVagaRepository;
import com.mballem.demoparkapi.repository.VagaRepository;
import com.mballem.demoparkapi.web.dto.DisponibilidadeDto;
import lombok.RequiredArgsConstructor;
import com.mballem.demoparkapi.websocket.PainelEvento;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static com.mballem.demoparkapi.entity.Vaga.StatusVaga.LIVRE;
import static com.mballem.demoparkapi.entity.Vaga.StatusVaga.OCUPADA;

@RequiredArgsConstructor
@Service
public class VagaService {

    private final VagaRepository vagaRepository;
    private final ClienteVagaRepository clienteVagaRepository;
    private final RecursoService recursoService;
    private final ApplicationEventPublisher eventos;

    @Transactional
    public Vaga salvar(Vaga vaga) {
        try {
            Vaga salva = vagaRepository.save(vaga);
            eventos.publishEvent(new PainelEvento("VAGA_CRIADA", "Vaga " + salva.getCodigo() + " cadastrada."));
            return salva;
        } catch (DataIntegrityViolationException ex) {
            throw new CodigoUniqueViolationException("Vaga", vaga.getCodigo());
        }
    }

    @Transactional
    public Vaga atualizar(String codigo, String novoCodigo, List<Long> recursoIds) {
        Vaga vaga = buscarPorCodigo(codigo);
        String codigoFinal = novoCodigo.trim().toUpperCase();
        if (!vaga.getCodigo().equals(codigoFinal) && vagaRepository.existsByCodigo(codigoFinal)) {
            throw new CodigoUniqueViolationException("Vaga", codigoFinal);
        }
        vaga.setCodigo(codigoFinal);
        if (recursoIds != null) {
            vaga.getRecursos().clear();
            vaga.getRecursos().addAll(recursoService.buscarPorIds(recursoIds));
        }
        eventos.publishEvent(new PainelEvento("VAGA_ATUALIZADA", "Vaga " + codigoFinal + " atualizada."));
        return vaga;
    }

    @Transactional
    public void excluir(String codigo) {
        Vaga vaga = buscarPorCodigo(codigo);
        if (vaga.getStatus() == OCUPADA) {
            throw new RegraNegocioException("Não é possível remover uma vaga ocupada.", HttpStatus.CONFLICT);
        }
        if (clienteVagaRepository.existsByVagaId(vaga.getId())) {
            throw new RegraNegocioException("A vaga possui histórico de estacionamentos e não pode ser removida.", HttpStatus.CONFLICT);
        }
        vaga.getRecursos().clear();
        vagaRepository.delete(vaga);
        eventos.publishEvent(new PainelEvento("VAGA_REMOVIDA", "Vaga " + codigo + " removida."));
    }

    @Transactional(readOnly = true)
    public Vaga buscarPorCodigo(String codigo) {
        return vagaRepository.findByCodigo(codigo).orElseThrow(
                () -> new EntityNotFoundException("Vaga", codigo)
        );
    }

    @Transactional(readOnly = true)
    public Vaga buscarPorVagaLivre() {
        return vagaRepository.findFirstByStatus(LIVRE).orElseThrow(
                () -> new VagaDisponivelException()
        );
    }

    @Transactional(readOnly = true)
    public List<Vaga> buscarTodas() {
        return vagaRepository.findAllByOrderByCodigoAsc();
    }

    @Transactional(readOnly = true)
    public DisponibilidadeDto buscarDisponibilidade() {
        long livres = vagaRepository.countByStatus(LIVRE);
        long ocupadas = vagaRepository.countByStatus(OCUPADA);
        return new DisponibilidadeDto(livres + ocupadas, livres, ocupadas);
    }
}
