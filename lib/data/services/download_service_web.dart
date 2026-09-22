import 'dart:html' as html;
import 'package:dio/dio.dart';

class DownloadService {
  final Dio _dio = Dio();

  Future<String> downloadFile(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    const proxyUrl = 'https://tiktok-webhook-xi.vercel.app/download';

    final downloadUrl = '$proxyUrl?url=${Uri.encodeComponent(url)}';

    final fileName =
        savePath.isNotEmpty ? savePath.split('/').last : 'CleanSaver_video.mp4';

    final anchor = html.AnchorElement(href: downloadUrl)
      ..setAttribute('download', fileName)
      ..style.display = 'none';

    html.document.body?.append(anchor);

    anchor.click();

    anchor.remove();

    onProgress?.call(1, 1);

    return fileName;
  }

  Future<void> downloadAndSaveToGallery(
    String url, {
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    throw UnsupportedError(
      'Gallery download is not available on Web.',
    );
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
