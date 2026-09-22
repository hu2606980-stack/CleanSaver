import 'package:cleansaver/data/models/media_item_model.dart';
import 'package:cleansaver/data/services/api_service.dart';

class VideoRepository {
  final ApiService _apiService;

  // FIX: Force useDemoMode to FALSE
  VideoRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService(useDemoMode: false);

  Future<MediaItemModel> getMediaInfo(String url) async {
    return await _apiService.fetchMediaInfo(url);
  }
}
