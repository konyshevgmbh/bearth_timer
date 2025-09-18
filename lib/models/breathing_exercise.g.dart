// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breathing_exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BreathingExerciseAdapter extends TypeAdapter<BreathingExercise> {
  @override
  final int typeId = 3;

  @override
  BreathingExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BreathingExercise(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime?,
      minCycles: fields[5] as int,
      maxCycles: fields[6] as int,
      cycleDurationStep: fields[7] as int,
      cycles: fields[8] as int,
      cycleDuration: fields[9] as int,
      phases: (fields[10] as List).cast<BreathPhase>(),
      deletedAt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BreathingExercise obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.deletedAt)
      ..writeByte(5)
      ..write(obj.minCycles)
      ..writeByte(6)
      ..write(obj.maxCycles)
      ..writeByte(7)
      ..write(obj.cycleDurationStep)
      ..writeByte(8)
      ..write(obj.cycles)
      ..writeByte(9)
      ..write(obj.cycleDuration)
      ..writeByte(10)
      ..write(obj.phases);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreathingExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
