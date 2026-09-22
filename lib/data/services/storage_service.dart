import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cleansaver/core/utils/platform_utils.dart';

class StorageService {
  Future<String> saveVideoToGallery(
    String tempFilePath,
    String fileName,
  ) async {
    await Gal.putVideo(
      tempFilePath,
      album: 'CleanSaver',
    );

    return tempFilePath;
  }

  Future<String> getTempDownloadPath(
    String fileName,
  ) async {
    final dir = await getTemporaryDirectory();

    return '${dir.path}/$fileName';
  }

  Future<String?> pickSaveDirectory() async {
    // FilePicker directory selection is for
    // Windows/Desktop platforms.
    if (kIsWeb) {
      return null;
    }

    return await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose download location',
    );
  }

  Future<String> getDefaultDownloadPath() async {
    // Web does not have a normal filesystem path.
    if (kIsWeb) {
      final dir = await getTemporaryDirectory();

      return dir.path;
    }

    if (PlatformUtils.isWindows) {
      final dir = await getDownloadsDirectory();

      return dir?.path ?? (await getApplicationDocumentsDirectory()).path;
    }

    final dir = await getTemporaryDirectory();

    return dir.path;
  }

  Future<String> saveFile(
    String tempPath,
    String fileName,
  ) async {
    if (PlatformUtils.isMobile) {
      return await saveVideoToGallery(
        tempPath,
        fileName,
      );
    }

    return tempPath;
  }

  Future<bool> requestPermissions() async {
    // ==================================================
    // WEB / CHROME
    // ==================================================

    if (kIsWeb) {
      return true;
    }

    // ==================================================
    // WINDOWS
    // ==================================================

    if (PlatformUtils.isWindows) {
      return true;
    }

    // ==================================================
    // MOBILE
    // ==================================================

    if (PlatformUtils.isMobile) {
      final hasGalAccess = await Gal.hasAccess(
        toAlbum: true,
      );

      if (hasGalAccess) {
        return true;
      }

      final requestGal = await Gal.requestAccess(
        toAlbum: true,
      );

      if (requestGal) {
        return true;
      }
    }

    // ==================================================
    // ANDROID
    // ==================================================

    if (!kIsWeb && Platform.isAndroid) {
      final Map<Permission, PermissionStatus> statuses = await [
        Permission.videos,
        Permission.photos,
        Permission.audio,
        Permission.storage,
      ].request();

      final isGranted = (statuses[Permission.videos]?.isGranted ?? false) ||
          (statuses[Permission.photos]?.isGranted ?? false) ||
          (statuses[Permission.audio]?.isGranted ?? false) ||
          (statuses[Permission.storage]?.isGranted ?? false);

      if (isGranted) {
        return true;
      }

      if (await Permission.manageExternalStorage.isDenied) {
        final status = await Permission.manageExternalStorage.request();

        if (status.isGranted) {
          return true;
        }
      }

      return false;
    }

    // ==================================================
    // iOS
    // ==================================================

    if (!kIsWeb && Platform.isIOS) {
      final status = await Permission.photos.request();

      return status.isGranted || status.isLimited;
    }

    return false;
  }
}
