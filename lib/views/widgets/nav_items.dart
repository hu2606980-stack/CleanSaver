import 'package:flutter/material.dart';

/// Data model for navigation items used in the main app layout.
class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  
  const NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
  });
}

/// Provides a static list of navigation items for consistent routing.
class NavItems {
  static const List<NavItemData> items = [
    NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      index: 0,
    ),
    NavItemData(
      icon: Icons.download_outlined,
      activeIcon: Icons.download_rounded,
      label: 'Downloads',
      index: 1,
    ),
    NavItemData(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
      index: 2,
    ),
  ];
}
