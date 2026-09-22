/// Enum for supported social media platforms.
/// YouTube is intentionally excluded for Play Store compliance.
enum SupportedPlatform {
  tiktok,
  facebook,
  instagram,
  twitter,
  unknown;

  toLowerCase() {}
}

/// Model representing a single media item retrieved from a social media URL.
class MediaItemModel {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  final String? audioUrl;
  final SupportedPlatform sourcePlatform;
  final String originalUrl;
  final int? durationSeconds;
  final int? fileSizeBytes;

  const MediaItemModel({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
    this.audioUrl,
    required this.sourcePlatform,
    required this.originalUrl,
    this.durationSeconds,
    this.fileSizeBytes,
  });

  factory MediaItemModel.fromJson(Map<String, dynamic> json) {
    SupportedPlatform parsePlatform(String? platformStr) {
      switch (platformStr?.toLowerCase()) {
        case 'tiktok':
          return SupportedPlatform.tiktok;
        case 'facebook':
          return SupportedPlatform.facebook;
        case 'instagram':
          return SupportedPlatform.instagram;
        case 'twitter':
        case 'x':
          return SupportedPlatform.twitter;
        default:
          return SupportedPlatform.unknown;
      }
    }

    return MediaItemModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      videoUrl: json['video_url'] ?? '',
      audioUrl: json['audio_url'],
      sourcePlatform: parsePlatform(json['source_platform']),
      originalUrl: json['original_url'] ?? '',
      durationSeconds: json['duration_seconds'] is int
          ? json['duration_seconds']
          : (json['duration_seconds'] != null
              ? int.tryParse(json['duration_seconds'].toString())
              : null),
      fileSizeBytes: json['file_size_bytes'] is int
          ? json['file_size_bytes']
          : (json['file_size_bytes'] != null
              ? int.tryParse(json['file_size_bytes'].toString())
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail_url': thumbnailUrl,
      'video_url': videoUrl,
      'audio_url': audioUrl,
      'source_platform': sourcePlatform.name,
      'original_url': originalUrl,
      'duration_seconds': durationSeconds,
      'file_size_bytes': fileSizeBytes,
    };
  }

  MediaItemModel copyWith({
    String? id,
    String? title,
    String? thumbnailUrl,
    String? videoUrl,
    String? audioUrl,
    SupportedPlatform? sourcePlatform,
    String? originalUrl,
    int? durationSeconds,
    int? fileSizeBytes,
  }) {
    return MediaItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      sourcePlatform: sourcePlatform ?? this.sourcePlatform,
      originalUrl: originalUrl ?? this.originalUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    );
  }

  String get formattedDuration {
    if (durationSeconds == null) return '--:--';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedFileSize {
    if (fileSizeBytes == null) return 'Unknown size';
    if (fileSizeBytes! < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes! < 1024 * 1024)
      return '${(fileSizeBytes! / 1024).toStringAsFixed(1)} KB';
    if (fileSizeBytes! < 1024 * 1024 * 1024)
      return '${(fileSizeBytes! / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(fileSizeBytes! / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaItemModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  Object? get url => null;

  @override
  String toString() {
    return 'MediaItemModel{id: $id, title: $title, platform: ${sourcePlatform.name}}';
  }
}
