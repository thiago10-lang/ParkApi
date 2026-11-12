import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificacaoService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _iniciado = false;
  static int _proximoId = 1;

  static Future<void> iniciar() async {
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
          web: WebInitializationSettings(),
        ),
      );
      _iniciado = true;
    } catch (e) {
      debugPrint('Notificações indisponíveis: $e');
    }
  }

  static Future<void> pedirPermissao() async {
    if (!_iniciado) return;
    try {
      if (kIsWeb) {
        final web = _plugin.resolvePlatformSpecificImplementation<WebFlutterLocalNotificationsPlugin>();
        if (web != null && web.permissionStatus != WebNotificationPermission.granted) {
          await web.requestNotificationsPermission();
        }
        return;
      }
      await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, sound: true);
    } catch (e) {
      debugPrint('Permissão de notificação não concedida: $e');
    }
  }

  static Future<void> mostrar(String titulo, String mensagem) async {
    debugPrint('Notificação: $titulo - $mensagem');
    if (!_iniciado) return;
    try {
      await _plugin.show(
        id: _proximoId++,
        title: titulo,
        body: mensagem,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'estacionamento',
            'Estacionamento',
            channelDescription: 'Avisos sobre a sua vaga',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('Falha ao mostrar notificação: $e');
    }
  }
}
