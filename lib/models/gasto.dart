import 'package:hive/hive.dart';

// Este archivo se genera automáticamente con build_runner
part 'gasto.g.dart';

/// Modelo de datos para representar un gasto.
/// 
/// Usa Hive para persistencia local en el dispositivo.
/// Los gastos pueden ser marcados como pagados y tener fecha de vencimiento.
@HiveType(typeId: 0)
class Gasto extends HiveObject {
  /// Nombre o descripción del gasto (ej: "Arriendo", "Mercado")
  @HiveField(0)
  String nombre;

  /// Monto del gasto en pesos colombianos
  @HiveField(1)
  double monto;

  /// Indica si el gasto ya fue pagado
  @HiveField(2)
  bool estaPagado;
  
  /// Fecha en que se registró el gasto
  @HiveField(3)
  DateTime fecha;

  /// Fecha límite de pago (opcional)
  @HiveField(4)
  DateTime? fechaVencimiento;

  /// Categoría del gasto para estadísticas
  /// Ejemplos: "Hogar", "Transporte", "Alimentación"
  @HiveField(5)
  String categoria;

  /// Constructor del gasto
  /// 
  /// [nombre] y [monto] son obligatorios
  /// [estaPagado] por defecto es false
  /// [fecha] por defecto es la fecha actual
  /// [fechaVencimiento] y [categoria] son opcionales
  Gasto({
    required this.nombre,
    required this.monto,
    this.estaPagado = false,
    DateTime? fecha,
    this.fechaVencimiento,
    this.categoria = 'Otros',
  }) : fecha = fecha ?? DateTime.now();

  /// Verifica si el gasto está vencido
  /// 
  /// Retorna true si:
  /// - Tiene fecha de vencimiento
  /// - No está pagado
  /// - La fecha de vencimiento ya pasó
  bool get esVencido {
    if (fechaVencimiento == null || estaPagado) return false;
    return fechaVencimiento!.isBefore(DateTime.now());
  }
}