import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart'; // Para kDebugMode

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 1. Inicializar zonas horarias (Vital para alarmas exactas)
    tz.initializeTimeZones();
    
    // 2. Configuración para Android (Icono de la app)
    // Asegúrate de tener un icono llamado 'ic_launcher' o 'app_icon' en android/app/src/main/res/drawable
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    // 3. Inicializar el plugin
    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Aquí puedes manejar qué pasa cuando tocan la notificación
        if (kDebugMode) {
          print('Notificación tocada: ${response.payload}');
        }
      },
    );

    // 4. Pedir permisos en Android 13+ (Opcional pero recomendado)
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
            
    await androidImplementation?.requestNotificationsPermission();
  }

  static Future<void> programarAviso({
    required int id,
    required String titulo,
    required String cuerpo,
    required DateTime fechaVencimiento,
  }) async {
    
    // Si la fecha ya pasó, no programamos nada
    if (fechaVencimiento.isBefore(DateTime.now())) return;

    // Convertimos la fecha a la zona horaria local
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      fechaVencimiento,
      tz.local,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      titulo,
      cuerpo,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'canal_alertas_gastos', // ID del canal (no cambiar)
          'Recordatorios de Pagos', // Nombre visible para el usuario
          channelDescription: 'Notificaciones para recordar pagos y tareas',
          importance: Importance.max, // <--- ESTO HACE QUE SUENE
          priority: Priority.high,    // <--- ESTO HACE QUE SALGA ARRIBA
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Permite sonar incluso en modo ahorro
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelarNotificacion(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}