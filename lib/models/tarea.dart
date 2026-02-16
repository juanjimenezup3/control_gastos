import 'package:hive/hive.dart';

part 'tarea.g.dart';

@HiveType(typeId: 2)
class Tarea extends HiveObject {
  @HiveField(0)
  String nombre;

  @HiveField(1)
  String descripcion;

  @HiveField(2)
  DateTime? fechaLimite;

  @HiveField(3)
  bool estaCompletada;

  Tarea({
    required this.nombre,
    required this.descripcion,
    this.fechaLimite,
    this.estaCompletada = false,
  });
}