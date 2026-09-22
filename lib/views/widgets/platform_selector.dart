import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:cleansaver/core/theme/app_colors.dart';
import 'package:cleansaver/core/theme/app_typography.dart';
import 'package:cleansaver/core/utils/url_validator.dart';
import 'package:cleansaver/data/models/media_item_model.dart';

/// Visually indicates the recognized social media platform of the parsed link.
class PlatformSelector extends StatelessWidget {
  final SupportedPlatform? platform;

  const PlatformSelector({Key? key, this.platform}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    if (platform == null) return const SizedBox.shrink();

    final color = _getPlatformColor(platform!);
    final icon = _getPlatformIcon(platform!);
    final label = UrlValidator.getPlatformLabel(platform!);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(platform),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.check_circle_rounded, color: AppColors.successAccent, size: 14),
          ],
        ),
      ),
    );
  }
}
