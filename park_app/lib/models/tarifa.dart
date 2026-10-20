import '../services/api_service.dart';

class Tarifa {
  final double primeiros15Minutos;
  final double primeiraHora;
  final double adicional15Minutos;
  final int descontoPercentual;
  final int usosParaDesconto;
  final String chavePix;
  final String nomeRecebedor;
  final String cidade;

  const Tarifa({
    required this.primeiros15Minutos,
    required this.primeiraHora,
    required this.adicional15Minutos,
    required this.descontoPercentual,
    required this.usosParaDesconto,
    this.chavePix = '',
    this.nomeRecebedor = 'PARKAPI',
    this.cidade = 'SAO PAULO',
  });

  static const padrao = Tarifa(
    primeiros15Minutos: 5.00,
    primeiraHora: 9.25,
    adicional15Minutos: 1.75,
    descontoPercentual: 30,
    usosParaDesconto: 10,
  );

  static Tarifa atual = padrao;

  factory Tarifa.fromJson(Map<String, dynamic> json) {
    double numero(String chave, double padrao) => (json[chave] as num?)?.toDouble() ?? padrao;
    return Tarifa(
      primeiros15Minutos: numero('primeiros15Minutos', 5.00),
      primeiraHora: numero('primeiraHora', 9.25),
      adicional15Minutos: numero('adicional15Minutos', 1.75),
      descontoPercentual: (json['descontoPercentual'] as num?)?.toInt() ?? 30,
      usosParaDesconto: (json['usosParaDesconto'] as num?)?.toInt() ?? 10,
      chavePix: json['chavePix'] ?? '',
      nomeRecebedor: json['nomeRecebedor'] ?? '',
      cidade: json['cidade'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'primeiros15Minutos': primeiros15Minutos,
        'primeiraHora': primeiraHora,
        'adicional15Minutos': adicional15Minutos,
        'descontoPercentual': descontoPercentual,
        'usosParaDesconto': usosParaDesconto,
        'chavePix': chavePix,
        'nomeRecebedor': nomeRecebedor,
        'cidade': cidade,
      };

  bool get aceitaPix => chavePix.trim().isNotEmpty;

  double calcularCusto(int minutos) {
    if (minutos <= 15) return primeiros15Minutos;
    if (minutos <= 60) return primeiraHora;
    final adicionais = ((minutos - 60) / 15).ceil();
    return primeiraHora + adicional15Minutos * adicionais;
  }

  static Future<Tarifa> carregar() async {
    try {
      final data = await ApiService.getJson('/tarifas');
      atual = Tarifa.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {}
    return atual;
  }
}
