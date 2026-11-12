import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/tarifa.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';
import '../services/estacionamento_service.dart';
import '../services/notificacao_service.dart';
import '../services/vaga_service.dart';
import '../utils/formatters.dart';

class EstacionamentoProvider extends ChangeNotifier {
  static const minutosParaCancelar = 15;

  Ticket? ativo;
  int livres = 0;
  int ocupadas = 0;
  bool carregando = true;
  String? erro;
  bool sessaoExpirada = false;
  int historicoVersao = 0;
  Timer? _timer;

  bool get podeCancelar {
    final ticket = ativo;
    return ticket != null && Fmt.agora().difference(ticket.dataEntrada).inMinutes < minutosParaCancelar;
  }

  Future<void> carregar({bool silencioso = false}) async {
    if (!silencioso) {
      carregando = true;
      erro = null;
      notifyListeners();
    }
    try {
      await Tarifa.carregar();
      final disponibilidade = await VagaService.disponibilidade();
      final novo = await EstacionamentoService.buscarAtivo();
      final saiu = ativo != null && novo == null;
      livres = disponibilidade['livres']!;
      ocupadas = disponibilidade['ocupadas']!;
      ativo = novo;
      erro = null;
      if (saiu) {
        historicoVersao++;
        NotificacaoService.mostrar('Saída registrada', 'Sua saída foi registrada. Obrigado pela visita!');
      }
    } on ApiException catch (e) {
      if (e.status == 401) {
        sessaoExpirada = true;
      } else if (!silencioso) {
        erro = e.message;
      }
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  void iniciarAtualizacao() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => carregar(silencioso: true));
  }

  void registrarSolicitacao(Ticket ticket) {
    ativo = ticket;
    livres = livres > 0 ? livres - 1 : 0;
    ocupadas++;
    historicoVersao++;
    notifyListeners();
    NotificacaoService.mostrar(
      'Vaga ${ticket.vagaCodigo} reservada',
      'Placa ${ticket.placa}. Apresente o QR Code do ticket na saída.',
    );
  }

  Future<void> cancelarSolicitacao() async {
    final ticket = ativo;
    await EstacionamentoService.cancelar();
    ativo = null;
    historicoVersao++;
    notifyListeners();
    NotificacaoService.mostrar('Solicitação cancelada', 'A vaga ${ticket?.vagaCodigo ?? ''} foi liberada.');
    await carregar(silencioso: true);
  }

  void limpar() {
    _timer?.cancel();
    ativo = null;
    livres = 0;
    ocupadas = 0;
    carregando = true;
    erro = null;
    sessaoExpirada = false;
    historicoVersao = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
