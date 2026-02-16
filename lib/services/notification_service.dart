import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart'; // Importante
import 'dart:developer'; // Para ver logs en consola

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 1. Inicializar la base de datos de zonas horarias
    tz.initializeTimeZones();
    
    // 2. Obtener la ubicación REAL del celular (ej: America/Bogota)
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    log("Zona horaria configurada: $timeZoneName");

    // 3. Configuración básica
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(settings);
  }

  static Future<void> programarAviso({
    required int id,
    required String titulo,
    required String cuerpo,
    required DateTime fechaVencimiento,
  }) async {
    
    // Convertir la fecha que elegiste a la zona horaria TZ
    final tz.TZDateTime fechaProgramada = tz.TZDateTime.from(
      fechaVencimiento,
      tz.local,
    );

    // Si la fecha ya pasó, no hacemos nada
    if (fechaProgramada.isBefore(tz.TZDateTime.now(tz.local))) {
      log("INTENTO FALLIDO: La hora elegida ya pasó ($fechaProgramada)");
      return;
    }

    log("PROGRAMANDO ALARMA: $titulo para $fechaProgramada (ID: $id)");

    await _notificationsPlugin.zonedSchedule(
      id,
      titulo,
      cuerpo,
      fechaProgramada,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'canal_alertas_v2', // CAMBIAMOS EL ID PARA FORZAR SONIDO
          'Alertas Importantes',
          channelDescription: 'Canal para recordatorios de gastos y tareas',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelarNotificacion(int id) async {
    await _notificationsPlugin.cancel(id);
    log("Notificación cancelada (ID: $id)");
  }
}