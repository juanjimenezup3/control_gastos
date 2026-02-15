// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gasto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GastoAdapter extends TypeAdapter<Gasto> {
  @override
  final int typeId = 0;

  @override
  Gasto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Gasto(
      nombre: fields[0] as String,
      monto: fields[1] as double,
      estaPagado: fields[2] as bool,
      fecha: fields[3] as DateTime?,
      fechaVencimiento: fields[4] as DateTime?,
      categoria: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Gasto obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.nombre)
      ..writeByte(1)
      ..write(obj.monto)
      ..writeByte(2)
      ..write(obj.estaPagado)
      ..writeByte(3)
      ..write(obj.fecha)
      ..writeByte(4)
      ..write(obj.fechaVencimiento)
      ..writeByte(5)
      ..write(obj.categoria);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GastoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
