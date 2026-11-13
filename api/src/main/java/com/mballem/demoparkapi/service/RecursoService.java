package com.mballem.demoparkapi.service;

import com.mballem.demoparkapi.entity.Recurso;
import com.mballem.demoparkapi.entity.Vaga;
import com.mballem.demoparkapi.exception.EntityNotFoundException;
import com.mballem.demoparkapi.exception.RegraNegocioException;
import com.mballem.demoparkapi.repository.RecursoRepository;
import com.mballem.demoparkapi.websocket.PainelEvento;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@RequiredArgsConstructor
@Service
public class RecursoService {

    private final RecursoRepository recursoRepository;
    private final ApplicationEventPublisher eventos;

    @Transactional
    public Recurso salvar(Recurso recurso) {
        if (recursoRepository.existsByNome(recurso.getNome())) {
            throw new RegraNegocioException("Já existe um recurso com o nome " + recurso.getNome() + ".", HttpStatus.CONFLICT);
        }
        return recursoRepository.save(recurso);
    }

    @Transactional(readOnly = true)
    public Recurso buscarPorId(Long id) {
        return recursoRepository.findById(id).orElseThrow(
                () -> new EntityNotFoundException("Recurso", String.valueOf(id))
        );
    }

    @Transactional(readOnly = true)
    public List<Recurso> buscarTodos() {
        return recursoRepository.findAllByOrderByNomeAsc();
    }

    @Transactional(readOnly = true)
    public List<Recurso> buscarPorIds(List<Long> ids) {
        List<Recurso> recursos = new ArrayList<>();
        for (Long id : ids) {
            recursos.add(buscarPorId(id));
        }
        return recursos;
    }

    @Transactional
    public Recurso atualizar(Long id, String nome, String descricao) {
        Recurso recurso = buscarPorId(id);
        String novoNome = nome.trim();
        if (!recurso.getNome().equalsIgnoreCase(novoNome) && recursoRepository.existsByNome(novoNome)) {
            throw new RegraNegocioException("Já existe um recurso com o nome " + novoNome + ".", HttpStatus.CONFLICT);
        }
        recurso.setNome(novoNome);
        recurso.setDescricao(descricao);
        eventos.publishEvent(new PainelEvento("RECURSO_ATUALIZADO", "Recurso " + novoNome + " atualizado."));
        return recurso;
    }

    @Transactional
    public void excluir(Long id) {
        Recurso recurso = buscarPorId(id);
        for (Vaga vaga : recurso.getVagas()) {
            vaga.getRecursos().remove(recurso);
        }
        recurso.getVagas().clear();
        recursoRepository.delete(recurso);
        eventos.publishEvent(new PainelEvento("RECURSO_REMOVIDO", "Recurso " + recurso.getNome() + " removido."));
    }
}
