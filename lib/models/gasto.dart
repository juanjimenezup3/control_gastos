import 'package:hive/hive.dart';

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

  Gasto({required this.nombre, required this.monto, this.estaPagado = false, DateTime? fecha, this.fechaVencimiento}) : fecha = fecha ?? DateTime.now();
} 