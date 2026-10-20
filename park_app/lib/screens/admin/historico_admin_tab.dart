import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/ticket.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/common.dart';
import '../../widgets/ticket_card.dart';

class HistoricoAdminTab extends StatefulWidget {
  const HistoricoAdminTab({super.key});

  @override
  State<HistoricoAdminTab> createState() => _HistoricoAdminTabState();
}

class _HistoricoAdminTabState extends State<HistoricoAdminTab> {
  static final _iso = DateFormat('yyyy-MM-dd');
  static final _curta = DateFormat('dd/MM/yyyy');

  final _placaController = TextEditingController();
  DateTimeRange? _periodo;
  final List<Ticket> _itens = [];
  int _pagina = 0;
  int _total = 0;
  bool _ultima = true;
  bool _carregando = true;
  bool _exportando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _buscar();
  }

  String _filtros() {
    final partes = <String>[];
    final placa = _placaController.text.trim();
    if (placa.isNotEmpty) partes.add('placa=${Uri.encodeQueryComponent(placa)}');
    if (_periodo != null) {
      partes.add('inicio=${_iso.format(_periodo!.start)}');
      partes.add('fim=${_iso.format(_periodo!.end)}');
    }
    return partes.join('&');
  }

  Future<void> _buscar({bool proxima = false}) async {
    setState(() {
      _carregando = true;
      _erro = null;
      if (!proxima) {
        _pagina = 0;
        _itens.clear();
      }
    });
    try {
      final filtros = _filtros();
      final data = await ApiService.getJson('/estacionamentos/todos?page=$_pagina&size=30${filtros.isEmpty ? '' : '&$filtros'}');
      if (!mounted) return;
      setState(() {
        _itens.addAll(List<Map<String, dynamic>>.from(data['content'] ?? []).map(Ticket.fromJson));
        _total = (data['totalElements'] as num?)?.toInt() ?? _itens.length;
        _ultima = data['last'] == true;
        _pagina++;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _escolherPeriodo() async {
    final agora = DateTime.now();
    final periodo = await showDateRangePicker(
      context: context,
      firstDate: DateTime(agora.year - 2),
      lastDate: agora,
      initialDateRange: _periodo ?? DateTimeRange(start: agora.subtract(const Duration(days: 6)), end: agora),
      helpText: 'Período de entrada',
      saveText: 'Aplicar',
    );
    if (periodo == null) return;
    setState(() => _periodo = periodo);
    _buscar();
  }

  Future<void> _exportar() async {
    setState(() => _exportando = true);
    try {
      final filtros = _filtros();
      final response = await ApiService.getBytes('/estacionamentos/exportar${filtros.isEmpty ? '' : '?$filtros'}', accept: 'text/csv');
      if (response.statusCode != 200) throw ApiException(response.statusCode, ApiService.errorMessage(response));
      final nome = 'estacionamentos_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}';
      await FileSaver.instance.saveFile(name: nome, bytes: response.bodyBytes, fileExtension: 'csv', mimeType: MimeType.csv);
      if (mounted) showMessage(context, 'Planilha $nome.csv gerada.');
    } on ApiException catch (e) {
      if (mounted) showMessage(context, e.message, error: true);
    } catch (_) {
      if (mounted) showMessage(context, 'Não foi possível salvar a planilha.', error: true);
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  void _detalhes(Ticket t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: TicketCard(ticket: t, showQr: false, doMotorista: false),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finalizados = _itens.where((t) => !t.ativo);
    final somaPagina = finalizados.fold<double>(0, (s, t) => s + t.valorFinal);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 240,
              child: TextField(
                controller: _placaController,
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (_) => _buscar(),
                decoration: AppColors.input('Filtrar por placa', Icons.search),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _escolherPeriodo,
              icon: const Icon(Icons.date_range),
              label: Text(_periodo == null ? 'Todo o período' : '${_curta.format(_periodo!.start)} a ${_curta.format(_periodo!.end)}'),
            ),
            if (_periodo != null || _placaController.text.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  _placaController.clear();
                  setState(() => _periodo = null);
                  _buscar();
                },
                icon: const Icon(Icons.clear),
                label: const Text('Limpar filtros'),
              ),
            ElevatedButton.icon(
              onPressed: () => _buscar(),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              icon: const Icon(Icons.filter_alt_outlined),
              label: const Text('Filtrar'),
            ),
            ElevatedButton.icon(
              onPressed: _exportando ? null : _exportar,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
              icon: _exportando
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.table_view),
              label: const Text('Exportar planilha'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: StatCard(label: 'Registros encontrados', value: '$_total', icon: Icons.receipt_long, color: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Recebido (itens exibidos)',
                value: Fmt.moeda(somaPagina),
                icon: Icons.payments_outlined,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_erro != null) ErrorState(message: _erro!, onRetry: _buscar),
        if (_erro == null && !_carregando && _itens.isEmpty)
          const EmptyState(icon: Icons.search_off, title: 'Nada encontrado', message: 'Nenhum estacionamento para os filtros escolhidos.'),
        Container(
          decoration: AppColors.card(),
          child: Column(
            children: [
              for (final t in _itens) ...[
                ListTile(
                  onTap: () => _detalhes(t),
                  leading: CircleAvatar(
                    backgroundColor: t.ativo ? AppColors.primarySoft : AppColors.inputFill,
                    child: Text(t.vagaCodigo, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: t.ativo ? AppColors.primary : AppColors.text)),
                  ),
                  title: Text('${t.placa} · ${t.clienteNome ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${Fmt.dataHora(t.dataEntrada)}${t.ativo ? '' : ' → ${Fmt.hora(t.dataSaida)}'} · ${t.veiculo}'),
                  trailing: t.ativo
                      ? const StatusChip(label: 'No pátio', color: AppColors.primary, background: AppColors.primarySoft)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(Fmt.moeda(t.valorFinal), style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(t.formaPagamentoLabel, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                ),
                const Divider(height: 1, color: AppColors.border),
              ],
              if (_carregando)
                const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
              else if (!_ultima)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextButton.icon(
                    onPressed: () => _buscar(proxima: true),
                    icon: const Icon(Icons.expand_more),
                    label: const Text('Carregar mais'),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
