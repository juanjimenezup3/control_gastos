import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_init;

class NotificationService {
static final FlutterLocalNotificationsPlugin _notificationsPlugin =
FlutterLocalNotificationsPlugin();

static Future<void> init() async {
// Inicializar base de datos de zonas horarias
tz_init.initializeTimeZones();

// Fijar zona horaria manual (Colombia)
tz.setLocalLocation(tz.getLocation('America/Bogota'));

// Configuración Android
const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

const settings = InitializationSettings(
  android: androidSettings,
);

await _notificationsPlugin.initialize(settings);

// Permiso Android 13+
await _notificationsPlugin
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();


}

static Future<void> programarAviso({
required int id,
required String titulo,
required String cuerpo,
required DateTime fechaVencimiento,
}) async {
final scheduledDate = tz.TZDateTime.from(
DateTime(
fechaVencimiento.year,
fechaVencimiento.month,
fechaVencimiento.day,
8,
),
tz.local,
);

if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

const androidDetails = AndroidNotificationDetails(
  'canal_gastos',
  'Recordatorios de Pagos',
  channelDescription: 'Avisos de vencimientos',
  importance: Importance.max,
  priority: Priority.high,
);

const details = NotificationDetails(android: androidDetails);

await _notificationsPlugin.zonedSchedule(
  id,
  titulo,
  cuerpo,
  scheduledDate,
  details,
  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
);

}

static Future<void> cancelarNotificacion(int id) async {
await _notificationsPlugin.cancel(id);
}
}
