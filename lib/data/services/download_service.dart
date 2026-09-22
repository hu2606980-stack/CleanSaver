import 'dart:io';

import 'package:cleansaver/data/services/web_download_service_subt.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

import 'package:cleansaver/core/constants/api_constants.dart';

export 'download_service_io.dart'
    if (dart.library.html) 'download_service_web.dart';

class DownloadService {
  final Dio _dio;

  DownloadService()
      : _dio = Dio(
          BaseOptions(
            connectTimeout: ApiConstants.downloadTimeout,
            receiveTimeout: ApiConstants.downloadTimeout,
            sendTimeout: ApiConstants.downloadTimeout,
            followRedirects: true,
            maxRedirects: 5,
          ),
        );

  Future<String> downloadFile(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    // ============================================================
    // CHROME / WEB
    // ============================================================
    if (kIsWeb) {
      print('🌐 [DownloadService] Chrome download started');

      final fileName = savePath.split('/').last.isNotEmpty
          ? savePath.split('/').last
          : 'CleanSaver_video.mp4';

      const proxyUrl = 'https://tiktok-webhook-xi.vercel.app/download';

      final downloadUrl = '$proxyUrl?url=${Uri.encodeComponent(url)}';

      print('🔗 [DownloadService] Browser URL prepared');

      await downloadInBrowser(
        downloadUrl,
        fileName,
      );

      print('✅ [DownloadService] Browser download triggered');

      onProgress?.call(1, 1);

      return fileName;
    }

    // ============================================================
    // ANDROID / WINDOWS
    // ============================================================
    try {
      print('🌐 [DownloadService] Original video URL received');
      print('📁 [DownloadService] Save path: $savePath');

      const proxyUrl = 'https://tiktok-webhook-xi.vercel.app/download';

      print(
        '🔄 [DownloadService] Using Vercel download proxy',
      );

      final response = await _dio.get<ResponseBody>(
        proxyUrl,
        queryParameters: {
          'url': url,
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
                'AppleWebKit/537.36 (KHTML, like Gecko) '
                'Chrome/153.0.0.0 Safari/537.36',
            'Accept': '*/*',
          },
        ),
        cancelToken: cancelToken,
      );

      if (response.statusCode != 200) {
        throw DownloadException(
          'Server returned status ${response.statusCode}',
        );
      }

      final file = File(savePath);

      final parentDirectory = file.parent;

      if (!await parentDirectory.exists()) {
        await parentDirectory.create(recursive: true);
      }

      final sink = file.openWrite();

      int received = 0;

      final contentLength = response.data?.contentLength ?? -1;

      try {
        await for (final chunk in response.data!.stream) {
          if (cancelToken?.isCancelled ?? false) {
            throw DownloadCancelledException();
          }

          sink.add(chunk);

          received += chunk.length;

          onProgress?.call(
            received,
            contentLength,
          );
        }
      } finally {
        await sink.close();
      }

      if (!await file.exists()) {
        throw DownloadException(
          'Downloaded file was not created.',
        );
      }

      final fileSize = await file.length();

      print(
        '📦 [DownloadService] File size: $fileSize bytes',
      );

      if (fileSize <= 0) {
        await file.delete();

        throw DownloadException(
          'Downloaded file is empty.',
        );
      }

      print(
        '✅ [DownloadService] Video saved successfully.',
      );

      return savePath;
    } on DioException catch (e) {
      print(
        '❌ [DownloadService] Dio error: ${e.message}',
      );

      print(
        '❌ [DownloadService] Dio type: ${e.type}',
      );

      print(
        '❌ [DownloadService] Status code: '
        '${e.response?.statusCode}',
      );

      if (e.type == DioExceptionType.cancel) {
        throw DownloadCancelledException();
      }

      throw DownloadException(
        'Download failed: '
        '${e.message ?? 'Unknown network error'}',
      );
    } on DownloadCancelledException {
      rethrow;
    } on DownloadException {
      rethrow;
    } catch (e) {
      print(
        '❌ [DownloadService] Unknown error: $e',
      );

      throw DownloadException(
        'Download failed: $e',
      );
    }
  }

  Future<void> downloadAndSaveToGallery(
    String url, {
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();

      final tempFilePath = '${tempDir.path}/CleanSaver_'
          '${DateTime.now().millisecondsSinceEpoch}.mp4';

      await downloadFile(
        url,
        tempFilePath,
        onProgress: onProgress,
        cancelToken: cancelToken,
      );

      await Gal.putVideo(tempFilePath);

      final file = File(tempFilePath);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      if (e is DownloadCancelledException) {
        rethrow;
      }

      if (e is DownloadException) {
        rethrow;
      }

      throw DownloadException(
        'Gallery Save Failed: $e',
      );
    }
  }
}

class DownloadException implements Exception {
  final String message;

  DownloadException(this.message);

  @override
  String toString() => message;
}

class DownloadCancelledException implements Exception {
  @override
  String toString() => 'Download was cancelled.';
}
