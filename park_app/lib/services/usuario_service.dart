import 'api_service.dart';

class UsuarioService {
  static Future<List<Map<String, dynamic>>> listarUsuarios() async {
    return List<Map<String, dynamic>>.from(await ApiService.getJson('/usuarios'));
  }

  static Future<List<Map<String, dynamic>>> listarClientes() async {
    final data = await ApiService.getJson('/clientes?size=200&sort=nome,asc');
    return List<Map<String, dynamic>>.from(data['content'] ?? []);
  }

  static Future<void> alterarPerfil(int id, String role) async {
    await ApiService.patchJson('/usuarios/$id/perfil', {'role': role});
  }

  static Future<Map<String, dynamic>?> clienteLogado() async {
    try {
      return Map<String, dynamic>.from(await ApiService.getJson('/clientes/detalhes'));
    } on ApiException catch (_) {
      return null;
    }
  }
}
