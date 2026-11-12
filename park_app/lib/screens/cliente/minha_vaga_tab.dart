import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/estacionamento_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/ticket_card.dart';

class MinhaVagaTab extends StatefulWidget {
  final VoidCallback onSolicitar;

  const MinhaVagaTab({super.key, required this.onSolicitar});

  @override
  State<MinhaVagaTab> createState() => _MinhaVagaTabState();
}

class _MinhaVagaTabState extends State<MinhaVagaTab> {
  Timer? _timer;
  bool _cancelando = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cancelar(EstacionamentoProvider provider) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar solicitação?'),
        content: const Text('A vaga será liberada para outro motorista.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Voltar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancelar vaga', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    setState(() => _cancelando = true);
    try {
      await provider.cancelarSolicitacao();
      if (mounted) showMessage(context, 'Solicitação cancelada. A vaga foi liberada.');
    } on ApiException catch (e) {
      if (mounted) showMessage(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _cancelando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EstacionamentoProvider>();
    final ticket = provider.ativo;
    if (ticket == null) {
      if (provider.carregando) return const Center(child: CircularProgressIndicator());
      return EmptyState(
        icon: Icons.local_parking,
        title: 'Nenhuma vaga ativa',
        message: 'Quando você solicitar uma vaga, o ticket com QR Code aparecerá aqui.',
        action: SizedBox(
          width: 240,
          child: ElevatedButton.icon(
            onPressed: widget.onSolicitar,
            style: AppColors.primaryButton(),
            icon: const Icon(Icons.add),
            label: const Text('Solicitar vaga'),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.carregar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: AppColors.successSoft, borderRadius: BorderRadius.circular(12)),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Vaga reservada e veículo em permanência', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TicketCard(ticket: ticket),
          const SizedBox(height: 16),
          const Text(
            'O valor estimado é atualizado automaticamente. O valor final é calculado no momento da saída.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: provider.carregar,
            icon: const Icon(Icons.refresh),
            label: const Text('Atualizar status'),
          ),
          if (provider.podeCancelar) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _cancelando ? null : () => _cancelar(provider),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancelar solicitação'),
            ),
            const SizedBox(height: 4),
            const Text(
              'O cancelamento é permitido nos primeiros ${EstacionamentoProvider.minutosParaCancelar} minutos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
