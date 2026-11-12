import 'api_service.dart';

class AuthService {
  static Future<String> login(String email, String senha) async {
    final data = await ApiService.postJson('/auth', {'username': email, 'password': senha});
    return data['token'];
  }

  static Future<void> cadastrar(String email, String senha) async {
    await ApiService.postJson('/usuarios', {'username': email, 'password': senha});
  }

  static Future<Map<String, dynamic>> meusDados() async {
    final data = await ApiService.getJson('/usuarios/me');
    return Map<String, dynamic>.from(data);
  }

  static Future<void> alterarSenha(int id, String atual, String nova, String confirma) async {
    await ApiService.patchJson('/usuarios/$id', {
      'senhaAtual': atual,
      'novaSenha': nova,
      'confirmaSenha': confirma,
    });
  }
}
