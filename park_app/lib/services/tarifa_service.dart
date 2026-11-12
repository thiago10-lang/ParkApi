import '../models/tarifa.dart';
import 'api_service.dart';

class TarifaService {
  static Future<Tarifa> buscar() async {
    return Tarifa.fromJson(Map<String, dynamic>.from(await ApiService.getJson('/tarifas')));
  }

  static Future<Tarifa> salvar(Tarifa tarifa) async {
    return Tarifa.fromJson(Map<String, dynamic>.from(await ApiService.putJson('/tarifas', tarifa.toJson())));
  }
}
