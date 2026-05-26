// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trusted_device.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrustedDeviceAdapter extends TypeAdapter<TrustedDevice> {
  @override
  final int typeId = 5;

  @override
  TrustedDevice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrustedDevice(
      deviceId: fields[0] as String,
      displayName: fields[1] as String,
      pairedAt: fields[2] as DateTime,
      lastSyncedAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TrustedDevice obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.deviceId)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.pairedAt)
      ..writeByte(3)
      ..write(obj.lastSyncedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrustedDeviceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
