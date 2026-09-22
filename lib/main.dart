import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:window_manager/window_manager.dart';
import 'package:cleansaver/core/constants/app_constants.dart';
import 'package:cleansaver/core/theme/app_colors.dart';
import 'package:cleansaver/data/repositories/video_repository.dart';
import 'package:cleansaver/data/services/api_service.dart';
import 'package:cleansaver/data/services/download_service.dart';
import 'package:cleansaver/data/services/storage_service.dart';
import 'package:cleansaver/viewmodels/download_viewmodel.dart';
import 'package:cleansaver/viewmodels/home_viewmodel.dart';
import 'package:cleansaver/viewmodels/theme_viewmodel.dart';
import 'package:cleansaver/views/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Desktop Window Initialization Guard
  if (!kIsWeb && Platform.isWindows) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(
        AppConstants.defaultWindowWidth,
        AppConstants.defaultWindowHeight,
      ),
      minimumSize: Size(
        AppConstants.minWindowWidth,
        AppConstants.minWindowHeight,
      ),
      center: true,
      title: AppConstants.appName,
      backgroundColor: AppColors.backgroundPrimary,
      titleBarStyle: TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // System UI overlay configuration for mobile
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.backgroundPrimary,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Lock orientation options
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Instantiate services and repositories once before app startup
  final apiService = ApiService(useDemoMode: false);
  final videoRepository = VideoRepository(apiService: apiService);
  final downloadService = DownloadService();
  final storageService = StorageService();

  runApp(
    CleanSaverApp(
      videoRepository: videoRepository,
      downloadService: downloadService,
      storageService: storageService,
    ),
  );
}

class CleanSaverApp extends StatelessWidget {
  final VideoRepository videoRepository;
  final DownloadService downloadService;
  final StorageService storageService;

  const CleanSaverApp({
    super.key,
    required this.videoRepository,
    required this.downloadService,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(repository: videoRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => DownloadViewModel(
            downloadService: downloadService,
            storageService: storageService,
          ),
        ),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVM, _) {
          return MaterialApp(
            title: AppConstants.appName,
            scaffoldMessengerKey: scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: themeVM.themeData,
            themeMode: themeVM.themeMode,
            builder: (context, child) => ResponsiveBreakpoints.builder(
              child: child!,
              breakpoints: const [
                Breakpoint(start: 0, end: 599, name: MOBILE),
                Breakpoint(start: 600, end: 1023, name: TABLET),
                Breakpoint(start: 1024, end: double.infinity, name: DESKTOP),
              ],
            ),
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
