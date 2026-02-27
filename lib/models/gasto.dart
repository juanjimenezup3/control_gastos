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
  DateTime? fechaVencimiento;

  @HiveField(3)
  bool estaPagado;

  @HiveField(4)
  bool esFijo; // 📌 NUEVO: Indica si es un gasto recurrente (arriendo) o variable (comida)

  Gasto({
    required this.nombre,
    required this.monto,
    this.fechaVencimiento,
    this.estaPagado = false,
    this.esFijo = false, // 📌 Por defecto, los gastos se crean como variables
  });
}