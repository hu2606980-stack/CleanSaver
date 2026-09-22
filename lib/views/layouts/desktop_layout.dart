import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cleansaver/core/theme/app_colors.dart';
import 'package:cleansaver/core/constants/app_constants.dart';
import 'package:cleansaver/views/widgets/nav_items.dart';

/// Layout designed for desktop and web environments with collapsable side menu
class DesktopLayout extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;
  final Widget child;

  const DesktopLayout({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.child,
  });

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  bool _isNavExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            width: _isNavExpanded ? 240 : 72,
            color: AppColors.surface,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: _isNavExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.download_rounded, color: AppColors.primaryAccent, size: 32),
                      if (_isNavExpanded) ...[
                        const SizedBox(width: 12),
                        AnimatedOpacity(
                          opacity: _isNavExpanded ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            'CleanSaver',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ...NavItems.items.map((item) {
                  final isSelected = widget.selectedIndex == item.index;
                  return InkWell(
                    onTap: () => widget.onIndexChanged(item.index),
                    hoverColor: AppColors.surfaceLight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryAccent.withOpacity(0.1) : Colors.transparent,
                        border: Border(
                          left: BorderSide(
                            color: isSelected ? AppColors.primaryAccent : Colors.transparent,
                            width: 3.0,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: _isNavExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected ? AppColors.primaryAccent : AppColors.textMuted,
                          ),
                          if (_isNavExpanded) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: AnimatedOpacity(
                                opacity: _isNavExpanded ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  item.label,
                                  style: GoogleFonts.inter(
                                    color: isSelected ? AppColors.primaryAccent : AppColors.textMuted,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  );
                }),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isNavExpanded = !_isNavExpanded;
                    });
                  },
                  icon: Icon(
                    _isNavExpanded ? Icons.menu_open : Icons.menu,
                    color: AppColors.textMuted,
                  ),
                  tooltip: _isNavExpanded ? 'Collapse' : 'Expand',
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const VerticalDivider(width: 1, color: AppColors.border),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
