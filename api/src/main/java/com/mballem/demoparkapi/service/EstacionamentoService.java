package com.mballem.demoparkapi.service;

import com.mballem.demoparkapi.entity.Cliente;
import com.mballem.demoparkapi.entity.ClienteVaga;
import com.mballem.demoparkapi.entity.Tarifa;
import com.mballem.demoparkapi.entity.Vaga;
import com.mballem.demoparkapi.exception.RegraNegocioException;
import com.mballem.demoparkapi.exception.SolicitacaoVagaException;
import com.mballem.demoparkapi.util.EstacionamentoUtils;
import com.mballem.demoparkapi.web.dto.SolicitacaoVagaDto;
import com.mballem.demoparkapi.websocket.PainelEvento;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
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
    private final ApplicationEventPublisher eventos;

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
        eventos.publishEvent(new PainelEvento("SOLICITACAO_CANCELADA",
                "Solicitação da vaga " + clienteVaga.getVaga().getCodigo() + " cancelada pelo motorista."));
    }

    @Transactional
    public ClienteVaga atualizarVeiculo(String recibo, String placa, String marca, String modelo, String cor) {
        ClienteVaga clienteVaga = clienteVagaService.buscarPorRecibo(recibo);
        String novaPlaca = placa.trim().toUpperCase();
        if (!clienteVaga.getPlaca().equals(novaPlaca) && clienteVagaService.existeAtivoPorPlaca(novaPlaca)) {
            throw new RegraNegocioException("A placa " + novaPlaca + " já possui estacionamento em aberto.", HttpStatus.CONFLICT);
        }
        clienteVaga.setPlaca(novaPlaca);
        clienteVaga.setMarca(marca.trim());
        clienteVaga.setModelo(modelo.trim());
        clienteVaga.setCor(cor.trim());
        eventos.publishEvent(new PainelEvento("VEICULO_ATUALIZADO",
                "Dados do veículo da vaga " + clienteVaga.getVaga().getCodigo() + " atualizados (" + novaPlaca + ")."));
        return clienteVaga;
    }

    @Transactional
    public void excluirEmAberto(String recibo) {
        ClienteVaga clienteVaga = clienteVagaService.buscarPorRecibo(recibo);
        clienteVaga.getVaga().setStatus(Vaga.StatusVaga.LIVRE);
        clienteVagaService.excluir(clienteVaga);
        eventos.publishEvent(new PainelEvento("ESTACIONAMENTO_REMOVIDO",
                "Registro " + recibo + " removido e vaga " + clienteVaga.getVaga().getCodigo() + " liberada."));
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

        ClienteVaga salvo = clienteVagaService.salvar(clienteVaga);
        eventos.publishEvent(new PainelEvento("SAIDA",
                "Saída do veículo " + salvo.getPlaca() + " na vaga " + salvo.getVaga().getCodigo() + "."));
        return salvo;
    }

    private ClienteVaga registrarEntrada(ClienteVaga clienteVaga, Cliente cliente, String codigoVaga) {
        clienteVaga.setCliente(cliente);

        Vaga vaga = escolherVaga(codigoVaga);
        vaga.setStatus(Vaga.StatusVaga.OCUPADA);
        clienteVaga.setVaga(vaga);

        LocalDateTime entrada = LocalDateTime.now().withNano(0);
        while (clienteVagaService.existeRecibo(EstacionamentoUtils.gerarRecibo(entrada))) {
            entrada = entrada.plusSeconds(1);
        }
        clienteVaga.setDataEntrada(entrada);
        clienteVaga.setRecibo(EstacionamentoUtils.gerarRecibo(entrada));

        ClienteVaga salvo = clienteVagaService.salvar(clienteVaga);
        eventos.publishEvent(new PainelEvento("ENTRADA",
                "Entrada do veículo " + salvo.getPlaca() + " na vaga " + vaga.getCodigo() + "."));
        return salvo;
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
