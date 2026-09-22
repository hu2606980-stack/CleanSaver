import 'package:cleansaver/data/models/media_item_model.dart';

class UrlValidator {
  static bool isValidUrl(String url) {
    return Uri.tryParse(url)?.hasAbsolutePath ?? false;
  }

  static bool isSupportedUrl(String url) {
    if (!isValidUrl(url)) return false;
    final platform = detectPlatform(url);
    return platform == SupportedPlatform.tiktok ||
        platform == SupportedPlatform.facebook;
  }

  static SupportedPlatform detectPlatform(String url) {
    final lowerUrl = url.toLowerCase();

    if (lowerUrl.contains('tiktok.com') ||
        lowerUrl.contains('vm.tiktok.com') ||
        lowerUrl.contains('vt.tiktok.com')) {
      return SupportedPlatform.tiktok;
    }

    if (lowerUrl.contains('facebook.com') ||
        lowerUrl.contains('fb.watch') ||
        lowerUrl.contains('fb.com') ||
        lowerUrl.contains('m.facebook.com')) {
      return SupportedPlatform.facebook;
    }

    if (lowerUrl.contains('instagram.com') || lowerUrl.contains('instagr.am')) {
      return SupportedPlatform.instagram;
    }

    if (lowerUrl.contains('twitter.com') ||
        lowerUrl.contains('x.com') ||
        lowerUrl.contains('t.co')) {
      return SupportedPlatform.twitter;
    }

    return SupportedPlatform.unknown;
  }

  static String getPlatformLabel(SupportedPlatform platform) {
    switch (platform) {
      case SupportedPlatform.tiktok:
        return 'TikTok';
      case SupportedPlatform.facebook:
        return 'Facebook';
      case SupportedPlatform.instagram:
        return 'Instagram';
      case SupportedPlatform.twitter:
        return 'Twitter';
      case SupportedPlatform.unknown:
        return 'Unknown';
    }
  }
}
