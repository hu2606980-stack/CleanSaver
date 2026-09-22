import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:cleansaver/core/theme/app_colors.dart';
import 'package:cleansaver/core/theme/app_typography.dart';
import 'package:cleansaver/viewmodels/download_viewmodel.dart';

/// A polished, animated progress bar that displays real-time speed.
class DynamicProgressBar extends StatelessWidget {
  final double progress;
  final double speedBytesPerSec;

  const DynamicProgressBar({
    Key? key,
    required this.progress,
    required this.speedBytesPerSec,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final isComplete = clampedProgress >= 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(clampedProgress * 100).toStringAsFixed(1)}%',
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
            ),
            Text(
              DownloadViewModel.formatSpeed(speedBytesPerSec),
              style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 6,
                    color: AppColors.surfaceLight,
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 6,
                    width: constraints.maxWidth * clampedProgress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isComplete
                            ? [AppColors.successAccent, const Color(0xFF34D399)]
                            : [AppColors.primaryAccent, AppColors.primaryAccentLight],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
