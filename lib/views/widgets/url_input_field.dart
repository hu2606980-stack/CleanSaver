import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cleansaver/core/theme/app_colors.dart';
import 'package:cleansaver/core/theme/app_typography.dart';
import 'package:cleansaver/viewmodels/home_viewmodel.dart';
import 'glassmorphic_container.dart';

/// A premium, glassmorphic input field for pasting social media URLs.
class UrlInputField extends StatelessWidget {
  const UrlInputField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeVM = context.watch<HomeViewModel>();

    return GlassmorphicContainer(
      padding: const EdgeInsets.all(4),
      borderRadius: 16,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: homeVM.urlController,
              style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Paste TikTok or Facebook video link...',
                hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 15),
                prefixIcon: const Icon(Icons.link_rounded, color: AppColors.textMuted),
                suffixIcon: homeVM.urlController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                        onPressed: () => homeVM.clearState(),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: (_) => homeVM.fetchMedia(),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.primaryAccent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: homeVM.pasteAndFetch,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: const Icon(Icons.content_paste_rounded, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primaryAccent,
                    AppColors.primaryAccentLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: homeVM.isLoading ? null : homeVM.fetchMedia,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: homeVM.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          children: [
                            const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              'Fetch',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
