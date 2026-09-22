import 'package:flutter/services.dart';
import 'url_validator.dart';

class ClipboardHelper {
  static Future<String?> getClipboardText() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      return clipboardData?.text;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getSupportedUrlFromClipboard() async {
    try {
      final text = await getClipboardText();
      if (text != null && text.isNotEmpty) {
        if (UrlValidator.isSupportedUrl(text)) {
          return text;
        }
      }
    } catch (e) {
      // Ignored
    }
    return null;
  }
}
