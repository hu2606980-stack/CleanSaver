import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cleansaver/core/utils/clipboard_helper.dart';
import 'package:cleansaver/core/utils/url_validator.dart';
import 'package:cleansaver/data/models/media_item_model.dart';
import 'package:cleansaver/data/repositories/video_repository.dart';
import 'package:cleansaver/data/services/api_service.dart';

// Removed 'abstract' keyword and changed 'implements' to 'with'
class HomeViewModel extends ChangeNotifier with WidgetsBindingObserver {
  final VideoRepository _repository;
  final TextEditingController urlController = TextEditingController();

  MediaItemModel? _mediaItem;
  bool _isLoading = false;
  String? _errorMessage;
  SupportedPlatform? _detectedPlatform;

  // Prevent re-checking same URL
  String _lastClipboardUrl = '';

  MediaItemModel? get mediaItem => _mediaItem;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SupportedPlatform? get detectedPlatform => _detectedPlatform;

  HomeViewModel({required VideoRepository repository})
      : _repository = repository {
    WidgetsBinding.instance.addObserver(this);
    urlController.addListener(_onUrlChanged);
  }

  void _onUrlChanged() {
    final url = urlController.text.trim();
    if (url.isNotEmpty && UrlValidator.isValidUrl(url)) {
      _detectedPlatform = UrlValidator.detectPlatform(url);
    } else {
      _detectedPlatform = null;
    }
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkClipboard();
    }
  }

  Future<void> checkClipboard() async {
    final url = await ClipboardHelper.getSupportedUrlFromClipboard();
    if (url != null && url != _lastClipboardUrl) {
      _lastClipboardUrl = url;
      urlController.text = url;
      _detectedPlatform = UrlValidator.detectPlatform(url);
      notifyListeners();
    }
  }

  Future<void> fetchMedia() async {
    final url = urlController.text.trim();
    if (url.isEmpty || !UrlValidator.isSupportedUrl(url)) {
      _errorMessage = 'Please enter a valid TikTok or Facebook URL';
      notifyListeners();
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    _mediaItem = null;
    notifyListeners();

    try {
      _mediaItem = await _repository.getMediaInfo(url);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearState() {
    urlController.clear();
    _mediaItem = null;
    _errorMessage = null;
    _detectedPlatform = null;
    _isLoading = false;
    notifyListeners();
  }

  void pasteAndFetch() async {
    await checkClipboard();
    if (urlController.text.isNotEmpty) {
      await fetchMedia();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    urlController.dispose();
    super.dispose();
  }
}
