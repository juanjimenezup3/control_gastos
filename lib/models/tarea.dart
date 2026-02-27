import 'package:hive/hive.dart';

part 'tarea.g.dart';

/// Modelo de datos para representar una tarea pendiente.
/// 
/// Las tareas pueden tener descripción, fecha límite y notificaciones.
@HiveType(typeId: 2)
class Tarea extends HiveObject {
  /// Nombre de la tarea (ej: "Pagar internet", "Llamar al banco")
  @HiveField(0)
  String nombre;

  /// Descripción detallada de la tarea (opcional)
  @HiveField(1)
  String descripcion;

  /// Fecha límite para completar la tarea
  @HiveField(2)
  DateTime? fechaLimite;

  /// Indica si la tarea ya fue completada
  @HiveField(3)
  bool estaCompletada;

  /// Constructor de la tarea
  /// 
  /// [nombre] es obligatorio
  /// [descripcion] por defecto es cadena vacía
  /// [fechaLimite] y [estaCompletada] son opcionales
  Tarea({
    required this.nombre,
    this.descripcion = '',
    this.fechaLimite,
    this.estaCompletada = false,
  });
}