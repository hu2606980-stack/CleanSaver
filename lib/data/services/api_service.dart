import 'package:cleansaver/core/utils/url_validator.dart';
import 'package:cleansaver/data/models/media_item_model.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  late final Dio _dio;

  bool useDemoMode;

  // ✅ Vercel Webhook URL
  static const String _webhookUrl =
      'https://tiktok-webhook-xi.vercel.app/tiktok';

  ApiService({this.useDemoMode = false}) {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Future<MediaItemModel> fetchMediaInfo(String url) async {
    if (useDemoMode) {
      return _getDemoData(url);
    }

    try {
      final response = await _dio.post(
        _webhookUrl,
        data: {'url': url},
        options: Options(
          responseType: ResponseType.json,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data['success'] == true) {
          final platform = UrlValidator.detectPlatform(url);

          return MediaItemModel(
            id: const Uuid().v4(),
            title: data['title'] ?? 'TikTok Video',
            thumbnailUrl: data['thumbnailUrl'] ?? '',
            videoUrl: data['videoUrl'] ?? '',
            audioUrl: data['audioUrl'],
            sourcePlatform: platform,
            originalUrl: url,
          );
        } else {
          throw ApiException(
            data['error'] ?? 'Failed to parse video. Please try again.',
          );
        }
      } else {
        throw ApiException('Invalid response from server.');
      }
    } on DioException catch (e) {
      throw ApiException(_parseDioError(e));
    } catch (e) {
      throw ApiException('Error: ${e.toString()}');
    }
  }

  Future<MediaItemModel> _getDemoData(String url) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final platform = UrlValidator.detectPlatform(url);

    return MediaItemModel(
      id: const Uuid().v4(),
      title: 'Amazing viral video - Demo Mode',
      thumbnailUrl: 'https://picsum.photos/640/360',
      videoUrl:
          'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
      audioUrl: null,
      sourcePlatform: platform,
      originalUrl: url,
      durationSeconds: 30,
      fileSizeBytes: 1048576,
    );
  }

  String _parseDioError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      if (e.response?.data is Map && e.response?.data['error'] != null) {
        return e.response?.data['error'].toString() ?? 'Server error occurred.';
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Check your internet connection.';

      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again.';

      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Server took too long to respond.';

      case DioExceptionType.badCertificate:
        return 'Security certificate error.';

      case DioExceptionType.badResponse:
        return 'Server error (Status: ${e.response?.statusCode}).';

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.connectionError:
        return 'Network connection failed. Please check your internet connection.';

      case DioExceptionType.unknown:
      default:
        return e.error?.toString() ?? e.message ?? 'Network connection error.';
    }
  }
}
