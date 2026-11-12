import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/park_logo.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class BoasVindasScreen extends StatelessWidget {
  const BoasVindasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final paisagem = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            ParkLogo(size: 32),
            SizedBox(width: 10),
            ParkNome(fontSize: 20),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: paisagem
                  ? Row(
                      children: [
                        Expanded(child: _apresentacao()),
                        const SizedBox(width: 32),
                        Expanded(child: _acoes(context)),
                      ],
                    )
                  : Column(
                      children: [
                        _apresentacao(),
                        const SizedBox(height: 32),
                        _acoes(context),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _apresentacao() {
    return const Column(
      children: [
        ParkLogo(size: 120),
        SizedBox(height: 16),
        Text(
          'Bem-vindo ao ParkAPI',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textStrong),
        ),
        SizedBox(height: 8),
        Text(
          'Estacionamento inteligente: solicite sua vaga pelo celular e apresente o QR Code na saída.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _acoes(BuildContext context) {
    return Column(
      children: [
        _item(Icons.local_parking, 'Vaga na hora', 'Escolha a vaga no mapa ou deixe o sistema escolher.'),
        _item(Icons.qr_code_2, 'Ticket com QR Code', 'Seu ticket fica salvo no app.'),
        _item(Icons.payments_outlined, 'Pagamento fácil', 'Pix, cartão ou dinheiro na saída.'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          child: const Text('Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          child: const Text('Criar conta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _item(IconData icone, String titulo, String texto) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primarySoft,
          child: Icon(icone, color: AppColors.primary),
        ),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textStrong)),
        subtitle: Text(texto, style: const TextStyle(color: AppColors.textMuted)),
      ),
    );
  }
}
