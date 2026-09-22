import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cleansaver/core/theme/app_colors.dart';
import 'package:cleansaver/core/theme/app_typography.dart';
import 'package:cleansaver/core/utils/url_validator.dart';

/// A designated area acting as a drag-and-drop / paste zone for links.
class DragDropZone extends StatefulWidget {
  final Function(String) onLinkDropped;

  const DragDropZone({
    Key? key,
    required this.onLinkDropped,
  }) : super(key: key);

  @override
  State<DragDropZone> createState() => _DragDropZoneState();
}

class _DragDropZoneState extends State<DragDropZone> {
  bool _isDragOver = false;

  Future<void> _handlePaste() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null && clipboardData.text != null) {
      final text = clipboardData.text!.trim();
      if (UrlValidator.isValidUrl(text)) {
        widget.onLinkDropped(text);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid URL copied in clipboard')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handlePaste,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isDragOver = true),
        onExit: (_) => setState(() => _isDragOver = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 120),
          decoration: BoxDecoration(
            color: _isDragOver ? AppColors.primaryAccent.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isDragOver ? AppColors.primaryAccent : AppColors.border,
              width: _isDragOver ? 2 : 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.content_paste_go_rounded,
                  size: 40,
                  color: _isDragOver ? AppColors.primaryAccent : AppColors.textMuted,
                ),
                const SizedBox(height: 8),
                Text(
                  'Click to paste link from clipboard',
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'or type/paste URL in the field above',
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
