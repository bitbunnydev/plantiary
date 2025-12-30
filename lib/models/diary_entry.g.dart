// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiaryEntryAdapter extends TypeAdapter<DiaryEntry> {
  @override
  final int typeId = 0;

  @override
  DiaryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiaryEntry(
      id: fields[0] as String,
      name: fields[1] as String,
      disease: fields[2] as String,
      confidence: fields[3] as double,
      imagePath: fields[4] as String,
      notes: fields[5] as String,
      folder: fields[6] as String,
      date: fields[7] as DateTime,
      allConfidences: (fields[8] as Map).cast<String, double>(),
      imagePaths: (fields[9] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, DiaryEntry obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.disease)
      ..writeByte(3)
      ..write(obj.confidence)
      ..writeByte(4)
      ..write(obj.imagePath)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.folder)
      ..writeByte(7)
      ..write(obj.date)
      ..writeByte(8)
      ..write(obj.allConfidences)
      ..writeByte(9)
      ..write(obj.imagePaths);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
