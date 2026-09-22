import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cleansaver/core/theme/app_colors.dart';
import 'package:cleansaver/views/widgets/nav_items.dart';
import 'package:cleansaver/views/widgets/glassmorphic_container.dart';

/// Layout designed specifically for mobile devices, using a custom floating navigation bar
class MobileLayout extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;
  final Widget child;

  const MobileLayout({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: child,
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
        child: GlassmorphicContainer(
          borderRadius: 24,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: NavItems.items.map((item) {
              final isSelected = selectedIndex == item.index;
              return InkWell(
                onTap: () => onIndexChanged(item.index),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(isSelected ? 4.0 : 0.0),
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected ? AppColors.primaryAccent : AppColors.textMuted,
                        size: isSelected ? 28 : 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isSelected ? AppColors.primaryAccent : AppColors.textMuted,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryAccent : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
