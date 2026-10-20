import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/tarifa.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../utils/pix.dart';
import 'common.dart';

Future<Ticket?> confirmarCheckout(BuildContext context, {required String recibo, required String placa, required String vaga}) async {
  await Tarifa.carregar();
  if (!context.mounted) return null;
  final ticket = await showDialog<Ticket>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _CheckoutDialog(recibo: recibo),
  );
  if (ticket == null || !context.mounted) return ticket;

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
      title: const Text('Saída registrada'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InfoRow('Placa', ticket.placa),
          InfoRow('Vaga liberada', ticket.vagaCodigo),
          InfoRow('Permanência', Fmt.duracao(ticket.permanencia)),
          InfoRow('Pagamento', ticket.formaPagamentoLabel),
          const Divider(),
          InfoRow('Total recebido', Fmt.moeda(ticket.valorFinal), strong: true),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          child: const Text('Concluir'),
        ),
      ],
    ),
  );
  return ticket;
}

class _CheckoutDialog extends StatefulWidget {
  final String recibo;

  const _CheckoutDialog({required this.recibo});

  @override
  State<_CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<_CheckoutDialog> {
  static const _formas = [
    ('PIX', 'Pix', Icons.qr_code_2),
    ('CARTAO', 'Cartão', Icons.credit_card),
    ('DINHEIRO', 'Dinheiro', Icons.payments_outlined),
  ];

  late final Future<Ticket> _previa = _carregarPrevia();
  String _forma = 'PIX';
  bool _enviando = false;

  Future<Ticket> _carregarPrevia() async {
    final data = await ApiService.getJson('/estacionamentos/check-in/${widget.recibo}/previa');
    return Ticket.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> _confirmar() async {
    setState(() => _enviando = true);
    try {
      final data = await ApiService.putJson('/estacionamentos/check-out/${widget.recibo}?formaPagamento=$_forma');
      if (!mounted) return;
      Navigator.pop(context, Ticket.fromJson(Map<String, dynamic>.from(data)));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);
      showMessage(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pagamento e saída'),
      content: SizedBox(
        width: 380,
        child: FutureBuilder<Ticket>(
          future: _previa,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return Text(snapshot.error.toString(), style: const TextStyle(color: AppColors.danger));
            }
            final t = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InfoRow('Veículo', '${t.placa} · vaga ${t.vagaCodigo}'),
                  InfoRow('Motorista', t.clienteNome ?? '-'),
                  InfoRow('Permanência', Fmt.duracao(t.permanencia)),
                  InfoRow('Valor', Fmt.moeda(t.valor)),
                  if ((t.desconto ?? 0) > 0) InfoRow('Desconto fidelidade', '- ${Fmt.moeda(t.desconto)}'),
                  const Divider(),
                  InfoRow('Total a pagar', Fmt.moeda(t.valorFinal), strong: true),
                  const SizedBox(height: 16),
                  const Text('Forma de pagamento', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textStrong)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _formas
                        .map((f) => ChoiceChip(
                              avatar: Icon(f.$3, size: 18),
                              label: Text(f.$2),
                              selected: _forma == f.$1,
                              onSelected: (_) => setState(() => _forma = f.$1),
                            ))
                        .toList(),
                  ),
                  if (_forma == 'PIX') ...[
                    const SizedBox(height: 16),
                    _pix(t),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: _enviando ? null : () => Navigator.pop(context), child: const Text('Cancelar')),
        FutureBuilder<Ticket>(
          future: _previa,
          builder: (context, snapshot) => ElevatedButton(
            onPressed: snapshot.hasData && !_enviando ? _confirmar : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: _enviando
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Confirmar pagamento e saída'),
          ),
        ),
      ],
    );
  }

  Widget _pix(Ticket t) {
    final tarifa = Tarifa.atual;
    if (!tarifa.aceitaPix) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.warningSoft, borderRadius: BorderRadius.circular(12)),
        child: const Text(
          'Cadastre a chave Pix do estacionamento na aba Configurações para gerar o QR Code de pagamento.',
          style: TextStyle(color: AppColors.warning),
        ),
      );
    }
    final payload = Pix.gerarPayload(
      chave: tarifa.chavePix,
      nome: tarifa.nomeRecebedor,
      cidade: tarifa.cidade,
      valor: t.valorFinal,
      identificador: t.recibo,
    );
    return Column(
      children: [
        Center(
          child: QrImageView(
            data: payload,
            size: 190,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.primaryDark),
            dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppColors.textStrong),
          ),
        ),
        const SizedBox(height: 4),
        Text('Pix de ${Fmt.moeda(t.valorFinal)} para ${tarifa.nomeRecebedor}',
            textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        TextButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: payload));
            if (mounted) showMessage(context, 'Código Pix copiado.');
          },
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copiar Pix copia e cola'),
        ),
      ],
    );
  }
}
