// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainingResultAdapter extends TypeAdapter<TrainingResult> {
  @override
  final int typeId = 0;

  @override
  TrainingResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrainingResult(
      date: fields[0] as DateTime,
      duration: fields[1] as int,
      cycles: fields[2] as int,
      exerciseId: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TrainingResult obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.duration)
      ..writeByte(2)
      ..write(obj.cycles)
      ..writeByte(3)
      ..write(obj.exerciseId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
