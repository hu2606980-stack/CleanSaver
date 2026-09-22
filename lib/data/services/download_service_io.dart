// TODO Implement this library.
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
      sendTimeout: const Duration(seconds: 30),
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
    try {
      const proxyUrl = 'https://tiktok-webhook-xi.vercel.app/download';

      final response = await _dio.get<ResponseBody>(
        proxyUrl,
        queryParameters: {
          'url': url,
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'User-Agent': 'Mozilla/5.0',
            'Accept': '*/*',
          },
        ),
        cancelToken: cancelToken,
      );

      if (response.statusCode != 200 || response.data == null) {
        throw DownloadException(
          'Server error: ${response.statusCode}',
        );
      }

      final file = File(savePath);

      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }

      final sink = file.openWrite();

      int received = 0;
      final total = response.data!.contentLength;

      try {
        await for (final chunk in response.data!.stream) {
          if (cancelToken?.isCancelled ?? false) {
            throw DownloadCancelledException();
          }

          sink.add(chunk);
          received += chunk.length;

          onProgress?.call(received, total);
        }
      } finally {
        await sink.close();
      }

      if (!await file.exists()) {
        throw DownloadException(
          'File was not created.',
        );
      }

      final size = await file.length();

      if (size == 0) {
        await file.delete();
        throw DownloadException(
          'Downloaded file is empty.',
        );
      }

      return savePath;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw DownloadCancelledException();
      }

      throw DownloadException(
        'Download failed: ${e.message}',
      );
    }
  }

  Future<void> downloadAndSaveToGallery(
    String url, {
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final tempDir = await getTemporaryDirectory();

    final fileName = 'CleanSaver_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final tempPath = '${tempDir.path}/$fileName';

    await downloadFile(
      url,
      tempPath,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );

    await Gal.putVideo(
      tempPath,
      album: 'CleanSaver',
    );

    final file = File(tempPath);

    if (await file.exists()) {
      await file.delete();
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
