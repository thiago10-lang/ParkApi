import 'api_service.dart';

class VagaService {
  static Future<List<Map<String, dynamic>>> listar() async {
    return List<Map<String, dynamic>>.from(await ApiService.getJson('/vagas'));
  }

  static Future<List<Map<String, dynamic>>> mapa() async {
    return List<Map<String, dynamic>>.from(await ApiService.getJson('/vagas/mapa'));
  }

  static Future<Map<String, int>> disponibilidade() async {
    final data = await ApiService.getJson('/vagas/disponibilidade');
    return {
      'livres': (data['livres'] as num).toInt(),
      'ocupadas': (data['ocupadas'] as num).toInt(),
    };
  }

  static Future<void> criar(String codigo) async {
    await ApiService.postJson('/vagas', {'codigo': codigo, 'status': 'LIVRE'});
  }

  static Future<void> remover(String codigo) async {
    await ApiService.deleteJson('/vagas/$codigo');
  }
}
