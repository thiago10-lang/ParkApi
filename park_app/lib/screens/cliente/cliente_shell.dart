import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ticket.dart';
import '../../providers/estacionamento_provider.dart';
import '../../services/notificacao_service.dart';
import '../../services/session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/park_logo.dart';
import '../perfil_screen.dart';
import 'historico_tab.dart';
import 'inicio_tab.dart';
import 'minha_vaga_tab.dart';
import 'solicitar_vaga_screen.dart';

class ClienteShell extends StatefulWidget {
  const ClienteShell({super.key});

  @override
  State<ClienteShell> createState() => _ClienteShellState();
}

class _ClienteShellState extends State<ClienteShell> {
  int _index = 0;
  late final EstacionamentoProvider _provider;
  bool _saindo = false;

  @override
  void initState() {
    super.initState();
    _provider = context.read<EstacionamentoProvider>();
    _provider.addListener(_verificarSessao);
    _provider.carregar();
    _provider.iniciarAtualizacao();
  }

  @override
  void dispose() {
    _provider.removeListener(_verificarSessao);
    super.dispose();
  }

  void _verificarSessao() {
    if (mounted && !_saindo && _provider.sessaoExpirada) {
      _saindo = true;
      logout(context);
    }
  }

  Future<void> _solicitar() async {
    final provider = _provider;
    if (provider.ativo != null) {
      setState(() => _index = 1);
      return;
    }
    await NotificacaoService.pedirPermissao();
    if (!mounted) return;
    final ticket = await Navigator.push<Ticket>(
      context,
      MaterialPageRoute(builder: (_) => const SolicitarVagaScreen()),
    );
    if (ticket == null || !mounted) return;
    provider.registrarSolicitacao(ticket);
    setState(() => _index = 1);
    provider.carregar(silencioso: true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EstacionamentoProvider>();
    final tabs = [
      InicioTab(onSolicitar: _solicitar, onVerTicket: () => setState(() => _index = 1)),
      MinhaVagaTab(onSolicitar: _solicitar),
      HistoricoTab(key: ValueKey(provider.historicoVersao)),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const ParkLogo(size: 38),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Olá, motorista!', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(Session.username ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(tooltip: 'Atualizar', icon: const Icon(Icons.refresh), onPressed: provider.carregar),
          IconButton(
            tooltip: 'Minha conta',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilScreen())),
          ),
          IconButton(tooltip: 'Sair', icon: const Icon(Icons.logout), onPressed: () => logout(context)),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: IndexedStack(index: _index, children: tabs),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(
            icon: Badge(isLabelVisible: provider.ativo != null, child: const Icon(Icons.qr_code_2_outlined)),
            selectedIcon: const Icon(Icons.qr_code_2),
            label: 'Minha vaga',
          ),
          const NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Histórico'),
        ],
      ),
    );
  }
}
