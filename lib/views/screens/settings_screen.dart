import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cleansaver/core/theme/app_colors.dart';
import 'package:cleansaver/views/widgets/glassmorphic_container.dart';
import 'package:cleansaver/viewmodels/download_viewmodel.dart';
import 'dart:io' show Platform;

/// Settings and About Screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final downloadVM = context.watch<DownloadViewModel>();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Settings',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Download Settings'),
          const SizedBox(height: 12),
          GlassmorphicContainer(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                if (!Platform.isAndroid && !Platform.isIOS) ...[
                  ListTile(
                    leading: const Icon(Icons.folder_outlined,
                        color: AppColors.textPrimary),
                    title: Text('Download Location',
                        style: GoogleFonts.inter(color: AppColors.textPrimary)),
                    subtitle: Text('C:\\Users\\Downloads\\CleanSaver',
                        style: GoogleFonts.inter(color: AppColors.textMuted)),
                    trailing: TextButton(
                      onPressed: () {
                        // Hook to storageService
                      },
                      child: Text('Change',
                          style: GoogleFonts.inter(
                              color: AppColors.primaryAccent)),
                    ),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                ],
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined,
                      color: AppColors.textPrimary),
                  title: Text('Demo Mode',
                      style: GoogleFonts.inter(color: AppColors.textPrimary)),
                  subtitle: Text('Use mock API responses',
                      style: GoogleFonts.inter(color: AppColors.textMuted)),
                  trailing: Switch(
                    value: false, // Wire up to App config
                    onChanged: (val) {},
                    activeColor: AppColors.primaryAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('About'),
          const SizedBox(height: 12),
          GlassmorphicContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.download_rounded,
                          color: AppColors.primaryAccent, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CleanSaver',
                            style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        Text('Version 1.0.0',
                            style:
                                GoogleFonts.inter(color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                    'The best way to download clean, watermark-free videos from your favorite social media platforms.',
                    style: GoogleFonts.inter(
                        color: AppColors.textSecondary, height: 1.5)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text('TikTok',
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 12)),
                      backgroundColor: Colors.black,
                      side: BorderSide.none,
                    ),
                    Chip(
                      label: Text('Facebook',
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 12)),
                      backgroundColor: const Color(0xFF1877F2),
                      side: BorderSide.none,
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Data'),
          const SizedBox(height: 12),
          GlassmorphicContainer(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading:
                  const Icon(Icons.delete_sweep, color: AppColors.errorAccent),
              title: Text('Clear completed downloads',
                  style: GoogleFonts.inter(color: AppColors.textPrimary)),
              onTap: () {
                downloadVM.clearCompleted();
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
      ),
    );
  }
}
