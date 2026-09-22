import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cleansaver/core/theme/app_colors.dart';
import 'package:cleansaver/viewmodels/download_viewmodel.dart';
import 'package:cleansaver/views/widgets/download_tile.dart';

/// Screen to display active and completed downloads
class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final downloadVM = context.watch<DownloadViewModel>();

    if (downloadVM.downloads.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (downloadVM.activeDownloads.isNotEmpty) ...[
            _buildSectionHeader('Active Downloads',
                badgeCount: downloadVM.activeCount),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Column(
                key: ValueKey(
                    'active_list_${downloadVM.activeDownloads.length}'),
                children: downloadVM.activeDownloads
                    .map((task) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: DownloadTile(
                            task: task,
                            onCancel: () => downloadVM.cancelDownload(task.id),
                            onRetry: null,
                            onRemove: null,
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (downloadVM.completedDownloads.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('Completed'),
                TextButton(
                  onPressed: () => downloadVM.clearCompleted(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryAccent,
                  ),
                  child: Text(
                    'Clear All',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Column(
                key: ValueKey(
                    'completed_list_${downloadVM.completedDownloads.length}'),
                children: downloadVM.completedDownloads
                    .map((task) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: DownloadTile(
                            task: task,
                            onCancel: null,
                            onRetry: null,
                            onRemove: () => downloadVM.removeDownload(task.id),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_download_outlined,
            size: 80,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'No downloads yet',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your downloaded media will appear here',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {int? badgeCount}) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (badgeCount != null && badgeCount > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badgeCount.toString(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
