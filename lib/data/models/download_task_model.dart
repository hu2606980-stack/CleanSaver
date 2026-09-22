import 'package:cleansaver/data/models/media_item_model.dart';

/// Enum representing the current status of a download task.
enum DownloadStatus { idle, downloading, completed, failed, cancelled }

/// Model representing a download task for a media item.
class DownloadTaskModel {
  final String id;
  final MediaItemModel mediaItem;
  DownloadStatus status;
  double progress;
  double speedBytesPerSec;
  String? savedFilePath;
  String? errorMessage;
  final DateTime createdAt;
  final bool isAudioOnly;

  DownloadTaskModel({
    required this.id,
    required this.mediaItem,
    this.status = DownloadStatus.idle,
    this.progress = 0.0,
    this.speedBytesPerSec = 0.0,
    this.savedFilePath,
    this.errorMessage,
    DateTime? createdAt,
    this.isAudioOnly = false,
  }) : createdAt = createdAt ?? DateTime.now();

  DownloadTaskModel copyWith({
    String? id,
    MediaItemModel? mediaItem,
    DownloadStatus? status,
    double? progress,
    double? speedBytesPerSec,
    String? savedFilePath,
    String? errorMessage,
    DateTime? createdAt,
    bool? isAudioOnly,
  }) {
    return DownloadTaskModel(
      id: id ?? this.id,
      mediaItem: mediaItem ?? this.mediaItem,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      speedBytesPerSec: speedBytesPerSec ?? this.speedBytesPerSec,
      savedFilePath: savedFilePath ?? this.savedFilePath,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      isAudioOnly: isAudioOnly ?? this.isAudioOnly,
    );
  }

  double get progressPercent => progress * 100;

  String get formattedSpeed {
    if (speedBytesPerSec < 1024) {
      return '${speedBytesPerSec.toStringAsFixed(1)} B/s';
    } else if (speedBytesPerSec < 1024 * 1024) {
      return '${(speedBytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${(speedBytesPerSec / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
  }

  bool get isActive => status == DownloadStatus.downloading;
  bool get isCompleted => status == DownloadStatus.completed;
  bool get canRetry => status == DownloadStatus.failed || status == DownloadStatus.cancelled;
}
