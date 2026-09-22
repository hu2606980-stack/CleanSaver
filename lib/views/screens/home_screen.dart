import 'package:cleansaver/views/widgets/url_input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cleansaver/core/theme/app_colors.dart';
import 'package:cleansaver/viewmodels/home_viewmodel.dart';
import 'package:cleansaver/viewmodels/download_viewmodel.dart';
import 'package:cleansaver/views/widgets/platform_selector.dart';
import 'package:cleansaver/views/widgets/preview_card.dart';
import 'package:cleansaver/views/widgets/glassmorphic_container.dart';

/// Premium designed home screen for processing and downloading media
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeVM = context.watch<HomeViewModel>();
    final downloadVM = context.watch<DownloadViewModel>();
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    // Safely access url only if mediaItem is not null
    final mediaItem = homeVM.mediaItem;
    final mediaUrl = mediaItem?.url ?? '';

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),

        // Hero Section
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.primaryAccent, AppColors.primaryAccentLight],
          ).createShader(bounds),
          child: Text(
            'CleanSaver',
            style: GoogleFonts.inter(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Download clean videos, no watermarks',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // URL Input
        const UrlInputField(),
        const SizedBox(height: 12),

        // Platform detection chip
        Center(child: PlatformSelector(platform: homeVM.detectedPlatform)),
        const SizedBox(height: 24),

        // Loading State
        if (homeVM.isLoading)
          const Center(
            child: SpinKitWave(
              color: AppColors.primaryAccent,
              size: 40.0,
            ),
          ),

        // Error State
        if (homeVM.errorMessage != null && !homeVM.isLoading)
          GlassmorphicContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.errorAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    homeVM.errorMessage!,
                    style: GoogleFonts.inter(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),

        // Success / Media Item State
        if (mediaItem != null && !homeVM.isLoading)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: PreviewCard(
              key: ValueKey(mediaUrl),
              mediaItem: mediaItem,
              onDownloadVideo: () async {
                await downloadVM.startDownload(mediaItem);
              },
              onDownloadAudio: () async {
                await downloadVM.startDownload(mediaItem, audioOnly: true);
              },
            ),
          ),
        const SizedBox(height: 32),
      ],
    );

    // Apply constraints on desktop
    if (isDesktop) {
      content = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: content,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => homeVM.checkClipboard(),
      color: AppColors.primaryAccent,
      backgroundColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24.0 : 16.0),
        child: content,
      ),
    );
  }
}
