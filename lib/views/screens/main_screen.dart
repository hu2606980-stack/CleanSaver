import 'package:flutter/material.dart';
import 'package:cleansaver/core/utils/responsive_builder.dart';
import 'package:cleansaver/views/layouts/mobile_layout.dart';
import 'package:cleansaver/views/layouts/tablet_layout.dart';
import 'package:cleansaver/views/layouts/desktop_layout.dart';
import 'package:cleansaver/views/screens/home_screen.dart';
import 'package:cleansaver/views/screens/downloads_screen.dart';
import 'package:cleansaver/views/screens/settings_screen.dart';

/// Main container screen that handles responsive navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const DownloadsScreen();
      case 2:
        return const SettingsScreen();
      default:
        return const HomeScreen();
    }
  }

  void _onIndexChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentScreen = _getCurrentScreen();

    return ResponsiveBuilder(
      mobile: (context) => MobileLayout(
        selectedIndex: _selectedIndex,
        onIndexChanged: _onIndexChanged,
        child: currentScreen,
      ),
      tablet: (context) => TabletLayout(
        selectedIndex: _selectedIndex,
        onIndexChanged: _onIndexChanged,
        child: currentScreen,
      ),
      desktop: (context) => DesktopLayout(
        selectedIndex: _selectedIndex,
        onIndexChanged: _onIndexChanged,
        child: currentScreen,
      ),
    );
  }
}
