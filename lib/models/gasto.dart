import 'package:hive/hive.dart';

// Este archivo se genera automáticamente con build_runner
part 'gasto.g.dart';

@HiveType(typeId: 0)
class Gasto extends HiveObject {
  @HiveField(0)
  String nombre;

  @HiveField(1)
  double monto;

  @HiveField(2)
  bool estaPagado;
  
  @HiveField(3)
  DateTime fecha;

  @HiveField(4)
  DateTime? fechaVencimiento;

  @HiveField(5)
  String categoria; // <--- Nuevo: Para las gráficas de estadísticas

  Gasto({
    required this.nombre,
    required this.monto,
    this.estaPagado = false,
    DateTime? fecha,
    this.fechaVencimiento,
    this.categoria = 'Otros', // Por defecto será 'Otros'
  }) : fecha = fecha ?? DateTime.now();

  // Método útil para saber si un gasto está vencido rápidamente
  bool get esVencido {
    if (fechaVencimiento == null || estaPagado) return false;
    return fechaVencimiento!.isBefore(DateTime.now());
  }
}