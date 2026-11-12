import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../services/auth_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _atualController = TextEditingController();
  final _novaController = TextEditingController();
  final _confirmaController = TextEditingController();
  late final Future<Map<String, dynamic>> _usuario = _carregar();
  bool _salvando = false;

  Future<Map<String, dynamic>> _carregar() async {
    return AuthService.meusDados();
  }

  String? _validarSenha(String? v) => (v ?? '').length == 6 ? null : 'A senha deve ter exatamente 6 caracteres';

  Future<void> _alterarSenha(int id) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      await AuthService.alterarSenha(id, _atualController.text, _novaController.text, _confirmaController.text);
      if (!mounted) return;
      _atualController.clear();
      _novaController.clear();
      _confirmaController.clear();
      showMessage(context, 'Senha alterada com sucesso.');
    } on ApiException catch (e) {
      if (mounted) showMessage(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha conta')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _usuario,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final u = snapshot.data!;
          final admin = u['role'] == 'ADMIN';
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppColors.card(),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primarySoft,
                          child: Icon(admin ? Icons.admin_panel_settings : Icons.person, color: AppColors.primary, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u['username'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textStrong)),
                              const SizedBox(height: 6),
                              admin
                                  ? const StatusChip(label: 'Administrador', color: AppColors.primary, background: AppColors.primarySoft)
                                  : const StatusChip(label: 'Motorista', color: AppColors.textMuted, background: AppColors.inputFill),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SectionTitle('Alterar senha'),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _atualController,
                          obscureText: true,
                          maxLength: 6,
                          decoration: AppColors.input('Senha atual', Icons.lock_outline),
                          validator: _validarSenha,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _novaController,
                          obscureText: true,
                          maxLength: 6,
                          decoration: AppColors.input('Nova senha (6 caracteres)', Icons.lock_reset),
                          validator: _validarSenha,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmaController,
                          obscureText: true,
                          maxLength: 6,
                          decoration: AppColors.input('Confirme a nova senha', Icons.lock_reset),
                          validator: (v) => v == _novaController.text ? null : 'As senhas não conferem',
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _salvando ? null : () => _alterarSenha((u['id'] as num).toInt()),
                          style: AppColors.primaryButton(),
                          child: _salvando
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Salvar nova senha'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => logout(context),
                    icon: const Icon(Icons.logout),
                    label: Text('Sair de ${Session.username ?? 'sua conta'}'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
