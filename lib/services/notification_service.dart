/// Servicio de notificaciones locales.
/// 
/// Gestiona las notificaciones programadas para gastos y tareas.
/// Usa flutter_local_notifications y timezone para programar recordatorios.
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:developer';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa el sistema de notificaciones.
  /// 
  /// Debe ser llamado en main() antes de runApp().
  /// Configura permisos de Android y zona horaria automáticamente.
  static Future<void> init() async {
    // Inicializar la base de datos de zonas horarias
    tz.initializeTimeZones();
    
    // Obtener la ubicación real del dispositivo (ej: America/Bogota)
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    log("Zona horaria configurada: $timeZoneName");

    // Configuración de notificaciones Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(settings);
  }

  /// Programa una notificación para una fecha específica.
  /// 
  /// [id] identificador único (usar hashCode del objeto)
  /// [titulo] título de la notificación
  /// [cuerpo] mensaje de la notificación
  /// [fechaVencimiento] fecha y hora exacta en que se mostrará
  static Future<void> programarAviso({
    required int id,
    required String titulo,
    required String cuerpo,
    required DateTime fechaVencimiento,
  }) async {
    
    // Convertir fecha a zona horaria local
    final tz.TZDateTime fechaProgramada = tz.TZDateTime.from(
      fechaVencimiento,
      tz.local,
    );

    // Validar que la fecha no haya pasado
    if (fechaProgramada.isBefore(tz.TZDateTime.now(tz.local))) {
      log("ADVERTENCIA: La fecha programada ya pasó ($fechaProgramada)");
      return;
    }

    log("Programando notificación: $titulo para $fechaProgramada (ID: $id)");

    await _notificationsPlugin.zonedSchedule(
      id,
      titulo,
      cuerpo,
      fechaProgramada,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'canal_alertas_v2',
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

  /// Cancela una notificación programada.
  /// 
  /// [id] debe ser el mismo usado al programarla
  static Future<void> cancelarNotificacion(int id) async {
    await _notificationsPlugin.cancel(id);
    log("Notificación cancelada (ID: $id)");
  }
}