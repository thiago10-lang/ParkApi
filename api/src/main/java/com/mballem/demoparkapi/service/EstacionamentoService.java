package com.mballem.demoparkapi.service;

import com.mballem.demoparkapi.entity.Cliente;
import com.mballem.demoparkapi.entity.ClienteVaga;
import com.mballem.demoparkapi.entity.Tarifa;
import com.mballem.demoparkapi.entity.Vaga;
import com.mballem.demoparkapi.exception.RegraNegocioException;
import com.mballem.demoparkapi.exception.SolicitacaoVagaException;
import com.mballem.demoparkapi.util.EstacionamentoUtils;
import com.mballem.demoparkapi.web.dto.SolicitacaoVagaDto;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;

@RequiredArgsConstructor
@Service
public class EstacionamentoService {

    private final ClienteVagaService clienteVagaService;
    private final ClienteService clienteService;
    private final VagaService vagaService;
    private final TarifaService tarifaService;

    public static final int MINUTOS_PARA_CANCELAR = 15;

    public record Previa(ClienteVaga clienteVaga, LocalDateTime saida, BigDecimal valor, BigDecimal desconto) {
    }

    @Transactional
    public ClienteVaga checkIn(ClienteVaga clienteVaga) {
        Cliente cliente = clienteService.buscarPorCpf(clienteVaga.getCliente().getCpf());
        return registrarEntrada(clienteVaga, cliente, null);
    }

    @Transactional
    public ClienteVaga solicitarVaga(Long usuarioId, SolicitacaoVagaDto dto) {
        Cliente cliente = clienteService.buscarOuCriarParaUsuario(usuarioId, dto.getNome(), dto.getCpf());

        if (clienteVagaService.existeAtivoPorCliente(cliente.getId())) {
            throw new SolicitacaoVagaException("exception.solicitacao.clienteAtivo", HttpStatus.CONFLICT);
        }

        String placa = dto.getPlaca().trim().toUpperCase();
        if (clienteVagaService.existeAtivoPorPlaca(placa)) {
            throw new SolicitacaoVagaException("exception.solicitacao.placaAtiva", HttpStatus.CONFLICT, placa);
        }

        ClienteVaga clienteVaga = new ClienteVaga();
        clienteVaga.setPlaca(placa);
        clienteVaga.setMarca(dto.getMarca().trim());
        clienteVaga.setModelo(dto.getModelo().trim());
        clienteVaga.setCor(dto.getCor().trim());
        return registrarEntrada(clienteVaga, cliente, dto.getVagaCodigo());
    }

    @Transactional
    public void cancelarSolicitacao(Long usuarioId) {
        ClienteVaga clienteVaga = clienteVagaService.buscarAtivoPorUsuarioId(usuarioId).orElseThrow(
                () -> new RegraNegocioException("Você não possui vaga reservada.", HttpStatus.NOT_FOUND)
        );
        long minutos = Duration.between(clienteVaga.getDataEntrada(), LocalDateTime.now()).toMinutes();
        if (minutos >= MINUTOS_PARA_CANCELAR) {
            throw new RegraNegocioException("O cancelamento só é permitido nos primeiros 15 minutos. " +
                    "Procure o atendente para registrar a saída.", HttpStatus.CONFLICT);
        }
        clienteVaga.getVaga().setStatus(Vaga.StatusVaga.LIVRE);
        clienteVagaService.excluir(clienteVaga);
    }

    @Transactional
    public Previa calcularPrevia(String recibo) {
        ClienteVaga clienteVaga = clienteVagaService.buscarPorRecibo(recibo);
        LocalDateTime saida = LocalDateTime.now();
        Tarifa tarifa = tarifaService.obter();
        BigDecimal valor = EstacionamentoUtils.calcularCusto(clienteVaga.getDataEntrada(), saida, tarifa);
        long totalDeVezes = clienteVagaService.getTotalDeVezesEstacionamentoCompleto(clienteVaga.getCliente().getCpf());
        BigDecimal desconto = EstacionamentoUtils.calcularDesconto(valor, totalDeVezes, tarifa);
        return new Previa(clienteVaga, saida, valor, desconto);
    }

    @Transactional
    public ClienteVaga checkOut(String recibo, ClienteVaga.FormaPagamento formaPagamento) {
        Previa previa = calcularPrevia(recibo);
        ClienteVaga clienteVaga = previa.clienteVaga();

        clienteVaga.setValor(previa.valor());
        clienteVaga.setDesconto(previa.desconto());
        clienteVaga.setDataSaida(previa.saida());
        clienteVaga.setFormaPagamento(formaPagamento);
        clienteVaga.getVaga().setStatus(Vaga.StatusVaga.LIVRE);

        return clienteVagaService.salvar(clienteVaga);
    }

    private ClienteVaga registrarEntrada(ClienteVaga clienteVaga, Cliente cliente, String codigoVaga) {
        clienteVaga.setCliente(cliente);

        Vaga vaga = escolherVaga(codigoVaga);
        vaga.setStatus(Vaga.StatusVaga.OCUPADA);
        clienteVaga.setVaga(vaga);

        clienteVaga.setDataEntrada(LocalDateTime.now());

        clienteVaga.setRecibo(EstacionamentoUtils.gerarRecibo());

        return clienteVagaService.salvar(clienteVaga);
    }

    private Vaga escolherVaga(String codigoVaga) {
        if (codigoVaga == null || codigoVaga.isBlank()) {
            return vagaService.buscarPorVagaLivre();
        }
        Vaga vaga = vagaService.buscarPorCodigo(codigoVaga.trim().toUpperCase());
        if (vaga.getStatus() != Vaga.StatusVaga.LIVRE) {
            throw new RegraNegocioException(
                    "A vaga " + vaga.getCodigo() + " acabou de ser ocupada. Escolha outra vaga.", HttpStatus.CONFLICT);
        }
        return vaga;
    }
}
