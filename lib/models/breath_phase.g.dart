// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breath_phase.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BreathPhaseAdapter extends TypeAdapter<BreathPhase> {
  @override
  final int typeId = 2;

  @override
  BreathPhase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BreathPhase(
      name: fields[0] as String,
      duration: fields[1] as int,
      minDuration: fields[2] as int,
      maxDuration: fields[3] as int,
      colorValue: fields[4] as int?,
      claps: fields[5] as int,
      deletedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BreathPhase obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.duration)
      ..writeByte(2)
      ..write(obj.minDuration)
      ..writeByte(3)
      ..write(obj.maxDuration)
      ..writeByte(4)
      ..write(obj.colorValue)
      ..writeByte(5)
      ..write(obj.claps)
      ..writeByte(6)
      ..write(obj.deletedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreathPhaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
