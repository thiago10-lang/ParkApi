import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/estacionamento_provider.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/cliente/cliente_shell.dart';
import 'screens/boas_vindas_screen.dart';
import 'services/notificacao_service.dart';
import 'services/session.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificacaoService.iniciar();
  runApp(
    ChangeNotifierProvider(
      create: (context) => EstacionamentoProvider(),
      child: const ParkApp(),
    ),
  );
}

class ParkApp extends StatelessWidget {
  const ParkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkAPI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.tema,
      home: const SessionGate(),
    );
  }
}

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  static Widget homeFor() => Session.isAdmin ? const AdminShell() : const ClienteShell();

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  late final Future<bool> _restored = Session.restore();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _restored,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.data == true ? SessionGate.homeFor() : const BoasVindasScreen();
      },
    );
  }
}
