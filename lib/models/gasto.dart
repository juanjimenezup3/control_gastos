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

  Gasto({required this.nombre, required this.monto, this.estaPagado = false});
} 