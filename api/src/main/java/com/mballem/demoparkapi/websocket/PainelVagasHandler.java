package com.mballem.demoparkapi.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mballem.demoparkapi.entity.Vaga;
import com.mballem.demoparkapi.repository.VagaRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Component
@RequiredArgsConstructor
public class PainelVagasHandler extends TextWebSocketHandler {

    private static final DateTimeFormatter HORA = DateTimeFormatter.ofPattern("HH:mm:ss");

    private final Set<WebSocketSession> sessoes = ConcurrentHashMap.newKeySet();
    private final VagaRepository vagaRepository;
    private final ObjectMapper objectMapper;

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        sessoes.add(session);
        log.info("Painel conectado: {} ({} conectado(s))", session.getId(), sessoes.size());
        enviar(session, montarMensagem("CONECTADO", "Conectado ao painel de vagas em tempo real."));
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) {
        String texto = message.getPayload().trim().toLowerCase();
        if (texto.equals("atualizar")) {
            enviar(session, montarMensagem("ATUALIZACAO", "Situação das vagas atualizada a pedido do painel."));
        } else {
            enviar(session, montarMensagem("AVISO", "Comando não reconhecido: " + message.getPayload()));
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        sessoes.remove(session);
        log.info("Painel desconectado: {} ({} conectado(s))", session.getId(), sessoes.size());
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT, fallbackExecution = true)
    public void aoAlterarEstacionamento(PainelEvento evento) {
        String mensagem = montarMensagem(evento.tipo(), evento.mensagem());
        for (WebSocketSession session : sessoes) {
            enviar(session, mensagem);
        }
    }

    public int totalConectados() {
        return sessoes.size();
    }

    private String montarMensagem(String tipo, String texto) {
        List<Vaga> vagas = vagaRepository.findAllByOrderByCodigoAsc();
        long ocupadas = vagas.stream().filter(v -> v.getStatus() == Vaga.StatusVaga.OCUPADA).count();
        Map<String, Object> dados = new LinkedHashMap<>();
        dados.put("tipo", tipo);
        dados.put("mensagem", texto);
        dados.put("hora", LocalDateTime.now().format(HORA));
        dados.put("total", vagas.size());
        dados.put("livres", vagas.size() - ocupadas);
        dados.put("ocupadas", ocupadas);
        dados.put("vagas", vagas.stream()
                .map(v -> Map.of("codigo", v.getCodigo(), "status", v.getStatus().name()))
                .toList());
        try {
            return objectMapper.writeValueAsString(dados);
        } catch (IOException e) {
            return "{\"tipo\":\"ERRO\",\"mensagem\":\"Falha ao montar a mensagem.\"}";
        }
    }

    private void enviar(WebSocketSession session, String mensagem) {
        if (!session.isOpen()) {
            sessoes.remove(session);
            return;
        }
        try {
            synchronized (session) {
                session.sendMessage(new TextMessage(mensagem));
            }
        } catch (IOException e) {
            sessoes.remove(session);
        }
    }
}
