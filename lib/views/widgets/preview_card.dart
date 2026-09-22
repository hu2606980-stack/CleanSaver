import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:cleansaver/core/theme/app_colors.dart';
import 'package:cleansaver/core/theme/app_typography.dart';
import 'package:cleansaver/data/models/media_item_model.dart';
import 'glassmorphic_container.dart';
import 'package:provider/provider.dart';
import 'package:cleansaver/viewmodels/download_viewmodel.dart';

/// A HERO widget displaying the fetched media thumbnail and download options.
/// Features a stunning premium look with hover effects on desktop.
class PreviewCard extends StatefulWidget {
  final MediaItemModel mediaItem;
  final VoidCallback onDownloadVideo;
  final VoidCallback? onDownloadAudio;

  const PreviewCard({
    Key? key,
    required this.mediaItem,
    required this.onDownloadVideo,
    this.onDownloadAudio,
  }) : super(key: key);

  @override
  State<PreviewCard> createState() => _PreviewCardState();
}

class _PreviewCardState extends State<PreviewCard> {
  bool _isHovered = false;

  Color _getPlatformColor(SupportedPlatform p) {
    switch (p) {
      case SupportedPlatform.tiktok:
        return AppColors.tiktokColor;
      case SupportedPlatform.facebook:
        return AppColors.facebookColor;
      case SupportedPlatform.instagram:
        return AppColors.instagramColor;
      case SupportedPlatform.twitter:
        return AppColors.twitterColor;
      default:
        return AppColors.primaryAccent;
    }
  }

  IconData _getPlatformIcon(SupportedPlatform p) {
    switch (p) {
      case SupportedPlatform.tiktok:
        return Icons.music_note_rounded;
      case SupportedPlatform.facebook:
        return Icons.facebook_rounded;
      case SupportedPlatform.instagram:
        return Icons.camera_alt_rounded;
      case SupportedPlatform.twitter:
        return Icons.tag_rounded;
      default:
        return Icons.public_rounded;
    }
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  void _showStartSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.greenAccent, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Monitor active downloads state
    final activeDownloads = context.watch<DownloadViewModel>().activeDownloads;

    final isVideoDownloading = activeDownloads.any(
      (task) => task.mediaItem.id == widget.mediaItem.id && !task.isAudioOnly,
    );

    final isAudioDownloading = activeDownloads.any(
      (task) => task.mediaItem.id == widget.mediaItem.id && task.isAudioOnly,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        transformAlignment: Alignment.center,
        child: GlassmorphicContainer(
          padding: EdgeInsets.zero,
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thumbnail Section
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      widget.mediaItem.thumbnailUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: AppColors.surfaceLight,
                        child: const Center(
                          child: Icon(Icons.image_not_supported_rounded,
                              color: AppColors.textMuted, size: 48),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black26],
                          ),
                        ),
                      ),
                    ),
                    if (widget.mediaItem.durationSeconds != null)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatDuration(widget.mediaItem.durationSeconds!),
                            style: GoogleFonts.inter(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getPlatformColor(
                              widget.mediaItem.sourcePlatform),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getPlatformIcon(widget.mediaItem.sourcePlatform),
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mediaItem.title,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (widget.mediaItem.fileSizeBytes != null)
                          _buildChip(Icons.storage_rounded,
                              _formatSize(widget.mediaItem.fileSizeBytes!)),
                        if (widget.mediaItem.durationSeconds != null)
                          _buildChip(
                              Icons.timer_rounded,
                              _formatDuration(
                                  widget.mediaItem.durationSeconds!)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // MP4 Video Download Button
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isVideoDownloading
                                  ? null
                                  : () {
                                      _showStartSnackBar(
                                          context, 'Video download started...');
                                      widget.onDownloadVideo();
                                    },
                              borderRadius: BorderRadius.circular(12),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: isVideoDownloading
                                      ? null
                                      : const LinearGradient(
                                          colors: [
                                            AppColors.primaryAccent,
                                            AppColors.primaryAccentLight
                                          ],
                                        ),
                                  color: isVideoDownloading
                                      ? AppColors.surfaceLight
                                      : null,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isVideoDownloading) ...[
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'Downloading...',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ] else ...[
                                      const Icon(Icons.download_rounded,
                                          color: Colors.white, size: 18),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'Download MP4',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // MP3 Audio Download Button (Optional)
                        if (widget.onDownloadAudio != null) ...[
                          const SizedBox(width: 8),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isAudioDownloading
                                  ? null
                                  : () {
                                      _showStartSnackBar(
                                          context, 'Audio download started...');
                                      widget.onDownloadAudio!();
                                    },
                              borderRadius: BorderRadius.circular(12),
                              child: Ink(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.primaryAccent),
                                  color: isAudioDownloading
                                      ? AppColors.surfaceLight
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 14),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isAudioDownloading) ...[
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primaryAccent,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'Downloading...',
                                          style: GoogleFonts.inter(
                                            color: AppColors.primaryAccent,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ] else ...[
                                      const Icon(Icons.audiotrack_rounded,
                                          color: AppColors.primaryAccent,
                                          size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        'MP3',
                                        style: GoogleFonts.inter(
                                          color: AppColors.primaryAccent,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
