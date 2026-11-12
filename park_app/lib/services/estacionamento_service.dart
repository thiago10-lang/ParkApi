import 'dart:typed_data';
import '../models/ticket.dart';
import 'api_service.dart';

class EstacionamentoService {
  static Ticket _ticket(dynamic data) => Ticket.fromJson(Map<String, dynamic>.from(data));

  static List<Ticket> _lista(dynamic data) => List<Map<String, dynamic>>.from(data).map(Ticket.fromJson).toList();

  static Future<Ticket?> buscarAtivo() async {
    final data = await ApiService.getJson('/estacionamentos/ativo');
    return data == null ? null : _ticket(data);
  }

  static Future<Ticket> solicitar(Map<String, dynamic> dados) async {
    return _ticket(await ApiService.postJson('/estacionamentos/solicitar', dados));
  }

  static Future<void> cancelar() async {
    await ApiService.deleteJson('/estacionamentos/ativo');
  }

  static Future<List<Ticket>> historico() async {
    final data = await ApiService.getJson('/estacionamentos?size=50&sort=dataEntrada,desc');
    return _lista(data['content'] ?? []);
  }

  static Future<List<Ticket>> noPatio() async {
    return _lista(await ApiService.getJson('/estacionamentos/ativos'));
  }

  static Future<Map<String, dynamic>> historicoGeral(int pagina, String filtros) async {
    final data = await ApiService.getJson('/estacionamentos/todos?page=$pagina&size=30${filtros.isEmpty ? '' : '&$filtros'}');
    return Map<String, dynamic>.from(data);
  }

  static Future<Uint8List> exportarCsv(String filtros) async {
    final response = await ApiService.getBytes('/estacionamentos/exportar${filtros.isEmpty ? '' : '?$filtros'}', accept: 'text/csv');
    if (response.statusCode != 200) throw ApiException(response.statusCode, ApiService.errorMessage(response));
    return response.bodyBytes;
  }

  static Future<Ticket> buscarPorRecibo(String recibo) async {
    return _ticket(await ApiService.getJson('/estacionamentos/check-in/$recibo'));
  }

  static Future<Ticket> previa(String recibo) async {
    return _ticket(await ApiService.getJson('/estacionamentos/check-in/$recibo/previa'));
  }

  static Future<Ticket> checkout(String recibo, String formaPagamento) async {
    return _ticket(await ApiService.putJson('/estacionamentos/check-out/$recibo?formaPagamento=$formaPagamento'));
  }

  static Future<Ticket> checkinManual(Map<String, dynamic> dados) async {
    return _ticket(await ApiService.postJson('/estacionamentos/check-in', dados));
  }

  static Future<Map<String, dynamic>> dashboard() async {
    return Map<String, dynamic>.from(await ApiService.getJson('/dashboard'));
  }
}
