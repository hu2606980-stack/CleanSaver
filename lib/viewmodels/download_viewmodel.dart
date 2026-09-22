import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cleansaver/core/utils/platform_utils.dart';
import 'package:cleansaver/data/models/download_task_model.dart';
import 'package:cleansaver/data/models/media_item_model.dart';
import 'package:cleansaver/data/services/download_service.dart';
import 'package:cleansaver/data/services/storage_service.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class DownloadViewModel extends ChangeNotifier {
  final DownloadService _downloadService;
  final StorageService _storageService;

  final List<DownloadTaskModel> _downloads = [];

  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, DateTime> _speedTimestamps = {};
  final Map<String, int> _speedReceivedBytes = {};

  List<DownloadTaskModel> get downloads => List.unmodifiable(_downloads);

  List<DownloadTaskModel> get activeDownloads =>
      _downloads.where((d) => d.isActive).toList();

  List<DownloadTaskModel> get completedDownloads =>
      _downloads.where((d) => d.isCompleted).toList();

  int get activeCount => activeDownloads.length;

  DownloadViewModel({
    required DownloadService downloadService,
    required StorageService storageService,
  })  : _downloadService = downloadService,
        _storageService = storageService;

  Future<void> startDownload(
    MediaItemModel mediaItem, {
    bool audioOnly = false,
  }) async {
    if (kDebugMode) {
      print(
        '🚀 [CleanSaver] Download triggered for: ${mediaItem.title}',
      );
    }

    final sourceUrl = audioOnly
        ? (mediaItem.audioUrl ?? mediaItem.videoUrl)
        : mediaItem.videoUrl;

    if (kDebugMode) {
      print(
        '🔗 [CleanSaver] Target Source URL: $sourceUrl',
      );
    }

    if (sourceUrl.isEmpty) {
      print(
        '❌ [CleanSaver] Source URL is empty.',
      );

      _showErrorNotification(
        'Download URL is empty.',
      );

      return;
    }

    // ============================================================
    // STORAGE PERMISSION
    // ============================================================

    final hasPermission = await _storageService.requestPermissions();

    if (kDebugMode) {
      print(
        '🔑 [CleanSaver] Storage Permission Status: '
        '$hasPermission',
      );
    }

    if (!hasPermission) {
      print(
        '❌ [CleanSaver] Storage permission denied.',
      );

      _showErrorNotification(
        'Storage permission denied.',
      );

      return;
    }

    // ============================================================
    // TASK
    // ============================================================

    final taskId = '${DateTime.now().millisecondsSinceEpoch}_${mediaItem.id}';

    final extension = audioOnly ? 'mp3' : 'mp4';

    final fileName = '${_sanitizeFileName(mediaItem.title)}_$taskId.$extension';

    // ============================================================
    // SAVE PATH
    // ============================================================

    String savePath;

    // ------------------------------------------------------------
    // CHROME / WEB
    // ------------------------------------------------------------
    if (kIsWeb) {
      savePath = fileName;

      if (kDebugMode) {
        print(
          '🌐 [CleanSaver] Web browser download mode',
        );

        print(
          '📁 [CleanSaver] Browser file name: $savePath',
        );
      }
    }

    // ------------------------------------------------------------
    // WINDOWS
    // ------------------------------------------------------------
    else if (PlatformUtils.isWindows) {
      final selectedDirectory = await _storageService.pickSaveDirectory();

      final dir =
          selectedDirectory ?? await _storageService.getDefaultDownloadPath();

      savePath = '$dir\\$fileName';

      if (kDebugMode) {
        print(
          '🪟 [CleanSaver] Windows save path: $savePath',
        );
      }
    }

    // ------------------------------------------------------------
    // ANDROID / IOS
    // ------------------------------------------------------------
    else {
      savePath = await _storageService.getTempDownloadPath(
        fileName,
      );

      if (kDebugMode) {
        print(
          '📱 [CleanSaver] Mobile temp path: $savePath',
        );
      }
    }

    if (kDebugMode) {
      print(
        '📁 [CleanSaver] Destination Path: $savePath',
      );
    }

    // ============================================================
    // CREATE DOWNLOAD TASK
    // ============================================================

    final task = DownloadTaskModel(
      id: taskId,
      mediaItem: mediaItem,
      isAudioOnly: audioOnly,
      status: DownloadStatus.downloading,
    );

    _downloads.insert(0, task);

    final cancelToken = CancelToken();

    _cancelTokens[taskId] = cancelToken;

    _speedTimestamps[taskId] = DateTime.now();

    _speedReceivedBytes[taskId] = 0;

    notifyListeners();

    // ============================================================
    // START DOWNLOAD
    // ============================================================

    try {
      print(
        '⏬ [CleanSaver] Network download initiated...',
      );

      await _downloadService.downloadFile(
        sourceUrl,
        savePath,
        onProgress: (received, total) {
          if (kDebugMode && total > 0) {
            final progressPercent =
                ((received / total) * 100).toStringAsFixed(0);

            print(
              '📊 [CleanSaver] Downloading: '
              '$progressPercent% '
              '($received/$total bytes)',
            );
          }

          _updateProgress(
            taskId,
            received,
            total,
          );
        },
        cancelToken: cancelToken,
      );

      // ==========================================================
      // WINDOWS VERIFICATION
      // ==========================================================

      // Web par File verification nahi karni.
      // Windows verification DownloadService already karta hai.

      if (PlatformUtils.isMobile && !audioOnly) {
        await _storageService.saveVideoToGallery(
          savePath,
          fileName,
        );

        if (kDebugMode) {
          print(
            '🎉 [CleanSaver] Successfully saved to Mobile Gallery!',
          );
        }
      }

      // ==========================================================
      // COMPLETED
      // ==========================================================

      _updateTaskStatus(
        taskId,
        DownloadStatus.completed,
        savedPath: savePath,
      );

      _showSuccessNotification(
        audioOnly
            ? 'Audio downloaded successfully!'
            : 'Video downloaded successfully!',
      );
    }

    // ============================================================
    // CANCELLED
    // ============================================================

    on DownloadCancelledException {
      print(
        '⚠️ [CleanSaver] Download cancelled by user.',
      );

      _updateTaskStatus(
        taskId,
        DownloadStatus.cancelled,
      );
    }

    // ============================================================
    // ERROR
    // ============================================================

    catch (e) {
      print(
        '❌ [CleanSaver] Critical Exception during download: $e',
      );

      _updateTaskStatus(
        taskId,
        DownloadStatus.failed,
        error: e.toString(),
      );

      _showErrorNotification(
        'Download failed: $e',
      );
    }

    // ============================================================
    // CLEANUP
    // ============================================================

    finally {
      _cancelTokens.remove(taskId);
      _speedTimestamps.remove(taskId);
      _speedReceivedBytes.remove(taskId);
    }
  }

  // ==============================================================
  // SUCCESS MESSAGE
  // ==============================================================

  void _showSuccessNotification(String message) {
    scaffoldMessengerKey.currentState?.clearSnackBars();

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.greenAccent,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ==============================================================
  // ERROR MESSAGE
  // ==============================================================

  void _showErrorNotification(String message) {
    scaffoldMessengerKey.currentState?.clearSnackBars();

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ==============================================================
  // PROGRESS
  // ==============================================================

  void _updateProgress(
    String taskId,
    int received,
    int total,
  ) {
    final index = _downloads.indexWhere(
      (d) => d.id == taskId,
    );

    if (index == -1) return;

    final now = DateTime.now();

    final lastTimestamp = _speedTimestamps[taskId] ?? now;

    final elapsed = now.difference(lastTimestamp).inMilliseconds;

    double speed = 0;

    if (elapsed > 500) {
      final byteDiff = received - (_speedReceivedBytes[taskId] ?? 0);

      speed = byteDiff / (elapsed / 1000.0);

      _speedTimestamps[taskId] = now;

      _speedReceivedBytes[taskId] = received;
    } else {
      speed = _downloads[index].speedBytesPerSec;
    }

    _downloads[index] = _downloads[index].copyWith(
      progress: total > 0 ? received / total : 0,
      speedBytesPerSec: speed,
    );

    notifyListeners();
  }

  // ==============================================================
  // TASK STATUS
  // ==============================================================

  void _updateTaskStatus(
    String taskId,
    DownloadStatus status, {
    String? savedPath,
    String? error,
  }) {
    final index = _downloads.indexWhere(
      (d) => d.id == taskId,
    );

    if (index == -1) return;

    _downloads[index] = _downloads[index].copyWith(
      status: status,
      savedFilePath: savedPath,
      errorMessage: error,
      progress: status == DownloadStatus.completed ? 1.0 : null,
    );

    notifyListeners();
  }

  // ==============================================================
  // CANCEL
  // ==============================================================

  void cancelDownload(String taskId) {
    _cancelTokens[taskId]?.cancel();
  }

  // ==============================================================
  // RETRY
  // ==============================================================

  void retryDownload(String taskId) {
    final index = _downloads.indexWhere(
      (d) => d.id == taskId,
    );

    if (index == -1) return;

    final task = _downloads[index];

    removeDownload(taskId);

    startDownload(
      task.mediaItem,
      audioOnly: task.isAudioOnly,
    );
  }

  // ==============================================================
  // REMOVE
  // ==============================================================

  void removeDownload(String taskId) {
    _downloads.removeWhere(
      (d) => d.id == taskId,
    );

    _cancelTokens.remove(taskId);

    notifyListeners();
  }

  // ==============================================================
  // CLEAR COMPLETED
  // ==============================================================

  void clearCompleted() {
    _downloads.removeWhere(
      (d) => d.isCompleted,
    );

    notifyListeners();
  }

  // ==============================================================
  // FILE NAME
  // ==============================================================

  String _sanitizeFileName(String name) {
    var sanitized = name.replaceAll(
      RegExp(r'[\\/:*?"<>|]'),
      '_',
    );

    if (sanitized.length > 50) {
      sanitized = sanitized.substring(0, 50);
    }

    return sanitized;
  }

  // ==============================================================
  // SPEED
  // ==============================================================

  static String formatSpeed(
    double bytesPerSec,
  ) {
    if (bytesPerSec > 1024 * 1024) {
      return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(2)} MB/s';
    } else if (bytesPerSec > 1024) {
      return '${(bytesPerSec / 1024).toStringAsFixed(2)} KB/s';
    }

    return '${bytesPerSec.toStringAsFixed(0)} B/s';
  }

  // ==============================================================
  // FILE SIZE
  // ==============================================================

  static String formatFileSize(
    int bytes,
  ) {
    if (bytes > 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (bytes > 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else if (bytes > 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }

    return '$bytes B';
  }
}
