import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/material.dart';

class NotificacionesHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa el plugin de notificaciones
  static Future<void> inicializar() async {
    tz.initializeTimeZones(); // ✅ Inicializamos zonas horarias

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Programa una notificación para una fecha y hora específicas
  static Future<void> programarNotificacion({
    required int id,
    required String titulo,
    required String cuerpo,
    required DateTime fechaHora,
  }) async {
    final tz.TZDateTime tzDateTime = tz.TZDateTime.from(fechaHora, tz.local);

    debugPrint('🔔 Programando notificación "$titulo" para $fechaHora');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      titulo,
      cuerpo,
      tzDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'canal_tareas',
          'Tareas',
          channelDescription: 'Notificaciones de recordatorio de tareas',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }
}
