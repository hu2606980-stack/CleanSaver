import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:cleansaver/core/theme/app_colors.dart';
import 'package:cleansaver/core/theme/app_typography.dart';
import 'package:cleansaver/data/models/download_task_model.dart';
import 'glassmorphic_container.dart';
import 'dynamic_progress_bar.dart';

/// A premium list tile representing a single download task.
class DownloadTile extends StatelessWidget {
  final DownloadTaskModel task;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  final VoidCallback? onRemove;

  const DownloadTile({
    Key? key,
    required this.task,
    this.onCancel,
    this.onRetry,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 16,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              task.mediaItem.thumbnailUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 48,
                height: 48,
                color: AppColors.surfaceLight,
                child: const Icon(Icons.image_not_supported_rounded, color: AppColors.textMuted, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.mediaItem.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (task.status == DownloadStatus.downloading)
                  DynamicProgressBar(progress: task.progress, speedBytesPerSec: task.speedBytesPerSec)
                else if (task.status == DownloadStatus.completed)
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.successAccent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Downloaded',
                        style: GoogleFonts.inter(color: AppColors.successAccent, fontSize: 12),
                      ),
                    ],
                  )
                else if (task.status == DownloadStatus.failed)
                  Row(
                    children: [
                      const Icon(Icons.error_rounded, color: AppColors.errorAccent, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          task.errorMessage ?? 'Download failed',
                          style: GoogleFonts.inter(color: AppColors.errorAccent, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else if (task.status == DownloadStatus.cancelled)
                  Row(
                    children: [
                      const Icon(Icons.cancel_rounded, color: AppColors.warningAccent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Cancelled',
                        style: GoogleFonts.inter(color: AppColors.warningAccent, fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (task.isAudioOnly)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'MP3',
                    style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              if (task.status == DownloadStatus.downloading)
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: onCancel,
                  tooltip: 'Cancel',
                )
              else if (task.status == DownloadStatus.failed || task.status == DownloadStatus.cancelled)
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryAccent),
                  onPressed: onRetry,
                  tooltip: 'Retry',
                )
              else if (task.status == DownloadStatus.completed)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted),
                  onPressed: onRemove,
                  tooltip: 'Remove',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
