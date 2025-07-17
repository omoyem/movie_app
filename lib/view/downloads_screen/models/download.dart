import 'package:hive/hive.dart';
part 'download.g.dart';

@HiveType(typeId: 1)
enum DownloadStatus {
  @HiveField(0)
  completed,
  @HiveField(1)
  failed,
  @HiveField(2)
  inProgress,
  @HiveField(3)
  pending,
}

@HiveType(typeId: 2)
class DownloadItem extends HiveObject {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String? thumbnailUrl;
  @HiveField(2)
  final String? details;
  @HiveField(3)
  final DownloadStatus status;
  @HiveField(4)
  final String? errorMessage;
  @HiveField(5)
  final String? filePath;
  @HiveField(6)
  final double progress;

  DownloadItem({
    required this.title,
    this.thumbnailUrl,
    this.details,
    required this.status,
    this.errorMessage,
    this.filePath,
    this.progress = 0.0,
  });

  DownloadItem copyWith({
    String? title,
    String? thumbnailUrl,
    String? details,
    DownloadStatus? status,
    String? errorMessage,
    String? filePath,
    double? progress,
  }) {
    return DownloadItem(
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      details: details ?? this.details,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      filePath: filePath ?? this.filePath,
      progress: progress ?? this.progress,
    );
  }
}
