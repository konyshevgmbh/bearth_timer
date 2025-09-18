// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SoundSettingsAdapter extends TypeAdapter<SoundSettings> {
  @override
  final int typeId = 4;

  @override
  SoundSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SoundSettings(
      soundEnabled: fields[0] as bool,
      volume: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SoundSettings obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.soundEnabled)
      ..writeByte(1)
      ..write(obj.volume);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoundSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
