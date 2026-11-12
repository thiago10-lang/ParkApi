import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/tarifa.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/common.dart';
import '../../services/tarifa_service.dart';

class ConfiguracoesTab extends StatefulWidget {
  const ConfiguracoesTab({super.key});

  @override
  State<ConfiguracoesTab> createState() => _ConfiguracoesTabState();
}

class _ConfiguracoesTabState extends State<ConfiguracoesTab> {
  final _formKey = GlobalKey<FormState>();
  final _quinze = TextEditingController();
  final _hora = TextEditingController();
  final _adicional = TextEditingController();
  final _desconto = TextEditingController();
  final _usos = TextEditingController();
  final _chavePix = TextEditingController();
  final _recebedor = TextEditingController();
  final _cidade = TextEditingController();
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  String _moeda(double v) => v.toStringAsFixed(2).replaceAll('.', ',');

  double? _numero(String texto) {
    final limpo = texto.trim();
    return double.tryParse(limpo.contains(',') ? limpo.replaceAll('.', '').replaceAll(',', '.') : limpo);
  }

  Future<void> _carregar() async {
    final t = await Tarifa.carregar();
    if (!mounted) return;
    setState(() {
      _quinze.text = _moeda(t.primeiros15Minutos);
      _hora.text = _moeda(t.primeiraHora);
      _adicional.text = _moeda(t.adicional15Minutos);
      _desconto.text = '${t.descontoPercentual}';
      _usos.text = '${t.usosParaDesconto}';
      _chavePix.text = t.chavePix;
      _recebedor.text = t.nomeRecebedor;
      _cidade.text = t.cidade;
      _carregando = false;
    });
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      final nova = Tarifa(
        primeiros15Minutos: _numero(_quinze.text)!,
        primeiraHora: _numero(_hora.text)!,
        adicional15Minutos: _numero(_adicional.text)!,
        descontoPercentual: int.parse(_desconto.text),
        usosParaDesconto: int.parse(_usos.text),
        chavePix: _chavePix.text.trim(),
        nomeRecebedor: _recebedor.text.trim(),
        cidade: _cidade.text.trim(),
      );
      Tarifa.atual = await TarifaService.salvar(nova);
      if (mounted) showMessage(context, 'Configurações salvas. Os novos valores já valem para as próximas saídas.');
    } on ApiException catch (e) {
      if (mounted) showMessage(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  String? _validarMoeda(String? v) {
    final n = _numero(v ?? '');
    return n == null || n < 0 ? 'Valor inválido' : null;
  }

  Widget _campo(TextEditingController c, String rotulo, IconData icone, {String? Function(String?)? validator, bool inteiro = false, int? max}) {
    return TextFormField(
      controller: c,
      maxLength: max,
      keyboardType: inteiro ? TextInputType.number : const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: inteiro ? [FilteringTextInputFormatter.digitsOnly] : [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
      decoration: AppColors.input(rotulo, icone, label: rotulo),
      validator: validator ?? _validarMoeda,
      onChanged: (_) => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) return const Center(child: CircularProgressIndicator());

    final previa = Tarifa(
      primeiros15Minutos: _numero(_quinze.text) ?? 0,
      primeiraHora: _numero(_hora.text) ?? 0,
      adicional15Minutos: _numero(_adicional.text) ?? 0,
      descontoPercentual: int.tryParse(_desconto.text) ?? 0,
      usosParaDesconto: int.tryParse(_usos.text) ?? 1,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SectionTitle('Tabela de preços'),
              Row(
                children: [
                  Expanded(child: _campo(_quinze, 'Até 15 min (R\$)', Icons.timer_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _campo(_hora, 'Até 1 hora (R\$)', Icons.schedule)),
                ],
              ),
              const SizedBox(height: 12),
              _campo(_adicional, 'Cada 15 min adicionais (R\$)', Icons.more_time),
              const SizedBox(height: 20),
              const SectionTitle('Programa de fidelidade'),
              Row(
                children: [
                  Expanded(
                    child: _campo(_desconto, 'Desconto (%)', Icons.percent, inteiro: true, max: 3, validator: (v) {
                      final n = int.tryParse(v ?? '');
                      return n == null || n > 100 ? 'Entre 0 e 100' : null;
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _campo(_usos, 'A cada quantos usos', Icons.repeat, inteiro: true, max: 3, validator: (v) {
                      final n = int.tryParse(v ?? '');
                      return n == null || n < 1 ? 'Mínimo 1' : null;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Simulação', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    const SizedBox(height: 6),
                    InfoRow('30 minutos', Fmt.moeda(previa.calcularCusto(30))),
                    InfoRow('1h30', Fmt.moeda(previa.calcularCusto(90))),
                    InfoRow('3 horas', Fmt.moeda(previa.calcularCusto(180))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionTitle('Recebimento via Pix'),
              const Text(
                'Com a chave preenchida, a tela de saída gera um QR Code Pix com o valor exato da cobrança.',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _chavePix,
                maxLength: 77,
                decoration: AppColors.input('Chave Pix (CPF, CNPJ, e-mail, telefone ou aleatória)', Icons.key, label: 'Chave Pix'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _recebedor,
                      maxLength: 25,
                      decoration: AppColors.input('Nome do recebedor', Icons.storefront, label: 'Nome do recebedor'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cidade,
                      maxLength: 15,
                      decoration: AppColors.input('Cidade', Icons.location_city, label: 'Cidade'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _salvando ? null : _salvar,
                style: AppColors.primaryButton(),
                icon: _salvando
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_outlined),
                label: const Text('Salvar configurações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
