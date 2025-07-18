// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadItemAdapter extends TypeAdapter<DownloadItem> {
  @override
  final int typeId = 2;

  @override
  DownloadItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadItem(
      title: fields[0] as String,
      thumbnailUrl: fields[1] as String?,
      details: fields[2] as String?,
      status: fields[3] as DownloadStatus,
      errorMessage: fields[4] as String?,
      filePath: fields[5] as String?,
      progress: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.thumbnailUrl)
      ..writeByte(2)
      ..write(obj.details)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.errorMessage)
      ..writeByte(5)
      ..write(obj.filePath)
      ..writeByte(6)
      ..write(obj.progress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DownloadStatusAdapter extends TypeAdapter<DownloadStatus> {
  @override
  final int typeId = 1;

  @override
  DownloadStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DownloadStatus.completed;
      case 1:
        return DownloadStatus.failed;
      case 2:
        return DownloadStatus.inProgress;
      case 3:
        return DownloadStatus.pending;
      default:
        return DownloadStatus.completed;
    }
  }

  @override
  void write(BinaryWriter writer, DownloadStatus obj) {
    switch (obj) {
      case DownloadStatus.completed:
        writer.writeByte(0);
        break;
      case DownloadStatus.failed:
        writer.writeByte(1);
        break;
      case DownloadStatus.inProgress:
        writer.writeByte(2);
        break;
      case DownloadStatus.pending:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
