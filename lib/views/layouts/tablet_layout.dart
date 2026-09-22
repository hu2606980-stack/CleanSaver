import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cleansaver/core/theme/app_colors.dart';
import 'package:cleansaver/views/widgets/nav_items.dart';

/// Layout designed for tablet devices, using a NavigationRail
class TabletLayout extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;
  final Widget child;

  const TabletLayout({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: AppColors.surface,
            selectedIndex: selectedIndex,
            onDestinationSelected: onIndexChanged,
            useIndicator: true,
            indicatorColor: AppColors.primaryAccent.withOpacity(0.15),
            labelType: NavigationRailLabelType.all,
            leading: const Padding(
              padding: EdgeInsets.only(bottom: 24.0, top: 16.0),
              child: Icon(
                Icons.download_rounded,
                color: AppColors.primaryAccent,
                size: 32,
              ),
            ),
            destinations: NavItems.items.map((item) {
              return NavigationRailDestination(
                icon: Icon(item.icon, color: AppColors.textMuted),
                selectedIcon: Icon(item.activeIcon, color: AppColors.primaryAccent),
                label: Text(
                  item.label,
                  style: GoogleFonts.inter(
                    color: selectedIndex == item.index ? AppColors.primaryAccent : AppColors.textMuted,
                    fontWeight: selectedIndex == item.index ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
          const VerticalDivider(width: 1, color: AppColors.border),
          Expanded(child: child),
        ],
      ),
    );
  }
}
