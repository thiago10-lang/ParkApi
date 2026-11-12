import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/common.dart';
import '../../widgets/park_logo.dart';
import '../../services/estacionamento_service.dart';
import '../../services/vaga_service.dart';
import '../../services/usuario_service.dart';

class SolicitarVagaScreen extends StatefulWidget {
  const SolicitarVagaScreen({super.key});

  @override
  State<SolicitarVagaScreen> createState() => _SolicitarVagaScreenState();
}

class _SolicitarVagaScreenState extends State<SolicitarVagaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _placaController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _corController = TextEditingController();
  static final _placaRegex = RegExp(r'^([A-Z]{3}-[0-9]{4}|[A-Z]{3}[0-9][A-Z][0-9]{2})$');
  static const _cores = ['Branco', 'Preto', 'Prata', 'Cinza', 'Vermelho', 'Azul'];

  bool _carregandoCliente = true;
  bool _enviando = false;
  Map<String, dynamic>? _cliente;
  List<Map<String, dynamic>> _vagas = [];
  String? _vagaEscolhida;

  @override
  void initState() {
    super.initState();
    _buscarCliente();
  }

  Future<void> _buscarCliente() async {
    try {
      _vagas = await VagaService.mapa();
    } on ApiException catch (_) {
      _vagas = [];
    }
    _cliente = await UsuarioService.clienteLogado();
    if (mounted) setState(() => _carregandoCliente = false);
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    final dados = {
      if (_cliente == null) 'nome': _nomeController.text.trim(),
      if (_cliente == null) 'cpf': _cpfController.text.trim(),
      'placa': _placaController.text.trim().toUpperCase(),
      'marca': _marcaController.text.trim(),
      'modelo': _modeloController.text.trim(),
      'cor': _corController.text.trim(),
      if (_vagaEscolhida != null) 'vagaCodigo': _vagaEscolhida,
    };
    debugPrint('Solicitação de vaga: $dados');
    setState(() => _enviando = true);
    try {
      final ticket = await EstacionamentoService.solicitar(dados);
      if (!mounted) return;
      Navigator.pop(context, ticket);
    } on ApiException catch (e) {
      if (mounted) showMessage(context, e.message, error: true);
      if (e.status == 409 && _vagaEscolhida != null) {
        await _buscarCliente();
        if (mounted) setState(() => _vagaEscolhida = null);
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Widget _mapaVagas() {
    if (_vagas.isEmpty) return const SizedBox.shrink();
    final livres = _vagas.where((v) => v['status'] == 'LIVRE').length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        SectionTitle('Escolha sua vaga', trailing: Text('$livres livres', style: const TextStyle(color: AppColors.textMuted, fontSize: 13))),
        ChoiceChip(
          avatar: const Icon(Icons.auto_awesome, size: 18),
          label: const Text('Escolher automaticamente'),
          selected: _vagaEscolhida == null,
          onSelected: (_) => setState(() => _vagaEscolhida = null),
        ),
        const SizedBox(height: 12),
        GridView.extent(
          maxCrossAxisExtent: 84,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.3,
          children: _vagas.map((v) {
            final codigo = v['codigo'] as String;
            final livre = v['status'] == 'LIVRE';
            final escolhida = _vagaEscolhida == codigo;
            return InkWell(
              onTap: livre ? () => setState(() => _vagaEscolhida = codigo) : null,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: escolhida ? AppColors.primary : (livre ? Colors.white : AppColors.inputFill),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: escolhida ? AppColors.primary : (livre ? AppColors.success : AppColors.border), width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(codigo, style: TextStyle(fontWeight: FontWeight.bold, color: escolhida ? Colors.white : (livre ? AppColors.textStrong : AppColors.textSoft))),
                    Icon(livre ? Icons.local_parking : Icons.directions_car, size: 16, color: escolhida ? Colors.white : (livre ? AppColors.success : AppColors.textSoft)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          _vagaEscolhida == null ? 'O sistema reservará a primeira vaga livre.' : 'Você escolheu a vaga $_vagaEscolhida.',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      ],
    );
  }

  String? _obrigatorio(String? v, String campo) => (v == null || v.trim().isEmpty) ? 'Informe $campo' : null;

  String? _validarCpf(String? v) {
    final cpf = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (cpf.length != 11 || RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return 'CPF inválido';
    int digito(int tamanho) {
      var soma = 0;
      for (var i = 0; i < tamanho; i++) {
        soma += int.parse(cpf[i]) * (tamanho + 1 - i);
      }
      final resto = (soma * 10) % 11;
      return resto == 10 ? 0 : resto;
    }

    if (digito(9) != int.parse(cpf[9]) || digito(10) != int.parse(cpf[10])) return 'CPF inválido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textStrong,
        titleSpacing: 0,
        title: const Row(
          children: [
            ParkLogo(size: 30),
            SizedBox(width: 10),
            ParkNome(fontSize: 18),
          ],
        ),
      ),
      body: _carregandoCliente
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      const Text('Solicitar vaga', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textStrong)),
                      const SizedBox(height: 8),
                      const Text(
                        'Preencha os dados abaixo. Uma vaga livre será reservada e você receberá um QR Code.',
                        style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 28),
                      if (_cliente == null) ...[
                        const SectionTitle('Seus dados'),
                        TextFormField(
                          controller: _nomeController,
                          textCapitalization: TextCapitalization.words,
                          maxLength: 100,
                          decoration: AppColors.input('Nome completo', Icons.person_outline),
                          validator: (v) => _obrigatorio(v, 'seu nome'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _cpfController,
                          keyboardType: TextInputType.number,
                          maxLength: 11,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: AppColors.input('CPF (somente números)', Icons.badge_outlined),
                          validator: _validarCpf,
                        ),
                        const SizedBox(height: 20),
                      ] else
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${_cliente!['nome']} · CPF ${Fmt.cpfMascarado(_cliente!['cpf'])}',
                                  style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SectionTitle('Veículo'),
                      TextFormField(
                        controller: _placaController,
                        maxLength: 8,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          TextInputFormatter.withFunction((oldValue, newValue) => newValue.copyWith(text: newValue.text.toUpperCase())),
                        ],
                        decoration: AppColors.input('Placa (ABC1D23 ou ABC-1234)', Icons.pin_outlined),
                        validator: (v) => _placaRegex.hasMatch((v ?? '').trim().toUpperCase()) ? null : 'Placa inválida',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _marcaController,
                              maxLength: 45,
                              textCapitalization: TextCapitalization.words,
                              decoration: AppColors.input('Marca', Icons.directions_car_outlined),
                              validator: (v) => _obrigatorio(v, 'a marca'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _modeloController,
                              maxLength: 45,
                              textCapitalization: TextCapitalization.words,
                              decoration: AppColors.input('Modelo', Icons.car_repair_outlined),
                              validator: (v) => _obrigatorio(v, 'o modelo'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _corController,
                        maxLength: 45,
                        textCapitalization: TextCapitalization.words,
                        decoration: AppColors.input('Cor', Icons.palette_outlined),
                        onChanged: (_) => setState(() {}),
                        validator: (v) => _obrigatorio(v, 'a cor'),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _cores
                            .map((cor) => ChoiceChip(
                                  label: Text(cor),
                                  selected: _corController.text == cor,
                                  onSelected: (_) => setState(() => _corController.text = cor),
                                ))
                            .toList(),
                      ),
                      _mapaVagas(),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: _enviando ? null : _enviar,
                        style: AppColors.primaryButton(),
                        child: _enviando
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Gerar QR Code da vaga'),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
