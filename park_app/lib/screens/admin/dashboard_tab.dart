import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/ticket.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/common.dart';
import '../../services/estacionamento_service.dart';

class DashboardTab extends StatefulWidget {
  final void Function(int) onNavegar;

  const DashboardTab({super.key, required this.onNavegar});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  Map<String, dynamic>? _data;
  String? _erro;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _carregar();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _carregar());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _carregar() async {
    try {
      final data = await EstacionamentoService.dashboard();
      if (mounted) {
        setState(() {
          _data = Map<String, dynamic>.from(data);
          _erro = null;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      if (_erro != null) return ErrorState(message: _erro!, onRetry: _carregar);
      return const Center(child: CircularProgressIndicator());
    }
    final d = _data!;
    num n(String k) => (d[k] as num?) ?? 0;
    final largura = MediaQuery.of(context).size.width;
    final colunas = largura >= 1200 ? 4 : (largura >= 700 ? 3 : 2);

    final cards = [
      StatCard(label: 'Vagas livres', value: '${n('vagasLivres')}', hint: 'de ${n('totalVagas')} vagas', icon: Icons.check_circle_outline, color: AppColors.success),
      StatCard(label: 'Vagas ocupadas', value: '${n('vagasOcupadas')}', icon: Icons.block, color: AppColors.danger),
      StatCard(label: 'Entradas hoje', value: '${n('entradasHoje')}', icon: Icons.login, color: AppColors.primary),
      StatCard(label: 'Saídas hoje', value: '${n('saidasHoje')}', icon: Icons.logout, color: AppColors.warning),
      StatCard(label: 'Faturamento hoje', value: Fmt.moeda(n('faturamentoHoje')), icon: Icons.payments_outlined, color: AppColors.success),
      StatCard(label: 'Faturamento total', value: Fmt.moeda(n('faturamentoTotal')), icon: Icons.account_balance_wallet_outlined, color: AppColors.primaryDark),
      StatCard(label: 'Usuários', value: '${n('totalUsuarios')}', hint: '${n('totalAdministradores')} administrador(es)', icon: Icons.people_outline, color: AppColors.primary),
      StatCard(label: 'Clientes', value: '${n('totalClientes')}', icon: Icons.badge_outlined, color: AppColors.textMuted),
    ];

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ocupacao(n('taxaOcupacao').toDouble(), n('vagasOcupadas').toInt(), n('totalVagas').toInt(), n('veiculosNoPatio').toInt()),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: colunas,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: colunas == 2 ? 1.45 : (colunas == 3 ? 2.8 : 3.4),
            children: cards,
          ),
          const SizedBox(height: 16),
          _linha(
            _grafico('Faturamento nos últimos 7 dias', List<Map<String, dynamic>>.from(d['faturamentoUltimos7Dias'] ?? []), 'valor',
                (v) => 'R\$ ${v.round()}', AppColors.success),
            _formasPagamento(List<Map<String, dynamic>>.from(d['faturamentoPorFormaPagamento'] ?? [])),
          ),
          const SizedBox(height: 16),
          _linha(
            _grafico('Entradas nos últimos 7 dias', List<Map<String, dynamic>>.from(d['entradasUltimos7Dias'] ?? []), 'entradas',
                (v) => '${v.toInt()}', AppColors.primary),
            _movimentacoes(List<Map<String, dynamic>>.from(d['ultimasMovimentacoes'] ?? [])),
          ),
        ],
      ),
    );
  }

  Widget _ocupacao(double taxa, int ocupadas, int total, int noPatio) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Ocupação do estacionamento', style: TextStyle(color: Colors.white70))),
              TextButton.icon(
                onPressed: () => widget.onNavegar(1),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                icon: const Icon(Icons.grid_view, size: 18),
                label: const Text('Ver mapa'),
              ),
            ],
          ),
          Text('${taxa.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : ocupadas / total,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text('$ocupadas de $total vagas ocupadas · $noPatio veículo(s) no pátio', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _linha(Widget esquerda, Widget direita) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < 900) {
        return Column(children: [esquerda, const SizedBox(height: 16), direita]);
      }
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: esquerda),
            const SizedBox(width: 16),
            Expanded(child: direita),
          ],
        ),
      );
    });
  }

  Widget _formasPagamento(List<Map<String, dynamic>> formas) {
    const cores = {'PIX': AppColors.primary, 'CARTAO': AppColors.warning, 'DINHEIRO': AppColors.success};
    final total = formas.fold<double>(0, (s, f) => s + (f['valor'] as num).toDouble());
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('Recebimentos por forma de pagamento',
              trailing: Text(Fmt.moeda(total), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textStrong))),
          if (formas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Nenhum pagamento registrado ainda.', style: TextStyle(color: AppColors.textMuted))),
            ),
          ...formas.map((f) {
            final valor = (f['valor'] as num).toDouble();
            final fracao = total == 0 ? 0.0 : valor / total;
            final cor = cores[f['forma']] ?? AppColors.textMuted;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(Ticket.rotuloForma(f['forma']), style: const TextStyle(fontWeight: FontWeight.w600))),
                      Text('${Fmt.moeda(valor)} · ${(fracao * 100).toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: fracao,
                      minHeight: 10,
                      backgroundColor: AppColors.inputFill,
                      valueColor: AlwaysStoppedAnimation(cor),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _grafico(String titulo, List<Map<String, dynamic>> dias, String chave, String Function(num) rotulo, Color cor) {
    final maximo = dias.fold<num>(0, (m, e) => (e[chave] as num) > m ? e[chave] as num : m);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(titulo),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dias.map((e) {
                final valor = e[chave] as num;
                final dia = DateTime.parse(e['dia']);
                final hoje = dia.day == Fmt.agora().day;
                final altura = maximo == 0 ? 0.0 : 120 * valor / maximo;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(rotulo(valor), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text)),
                        const SizedBox(height: 4),
                        Container(
                          height: altura < 4 ? 4 : altura,
                          decoration: BoxDecoration(
                            color: hoje ? cor : cor.withValues(alpha: 0.35),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(Fmt.diaSemana(dia), style: TextStyle(fontSize: 12, color: hoje ? cor : AppColors.textMuted)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _movimentacoes(List<Map<String, dynamic>> itens) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('Últimas movimentações', trailing: TextButton(onPressed: () => widget.onNavegar(2), child: const Text('Ver pátio'))),
          if (itens.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Nenhuma movimentação ainda.', style: TextStyle(color: AppColors.textMuted))),
            ),
          ...itens.map((e) {
            final t = Ticket.fromJson(e);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: t.ativo ? AppColors.primarySoft : AppColors.inputFill,
                child: Icon(t.ativo ? Icons.login : Icons.logout, color: t.ativo ? AppColors.primary : AppColors.textMuted, size: 20),
              ),
              title: Text('${t.placa} · vaga ${t.vagaCodigo}', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(t.clienteNome ?? ''),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Fmt.hora(t.ativo ? t.dataEntrada : t.dataSaida), style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  t.ativo
                      ? const Text('Entrada', style: TextStyle(color: AppColors.primary, fontSize: 12))
                      : Text(Fmt.moeda(t.valorFinal), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
