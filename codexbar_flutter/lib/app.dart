import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'ui/menu/menu_card_view.dart';
import 'ui/settings/preferences_view.dart';
import 'ui/tray/tray_manager.dart';

/// Main application widget.
class CodexBarApp extends ConsumerStatefulWidget {
  const CodexBarApp({super.key});

  @override
  ConsumerState<CodexBarApp> createState() => _CodexBarAppState();
}

class _CodexBarAppState extends ConsumerState<CodexBarApp> {
  final TrayManager _trayManager = TrayManager();
  bool _showSettings = false;
  bool _trayInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeTray();
  }

  Future<void> _initializeTray() async {
    if (_trayInitialized) return;
    try {
      await _trayManager.initialize(
        onShowWindow: () async {
          await windowManager.show();
          await windowManager.focus();
        },
        onHideWindow: () async {
          await windowManager.hide();
        },
        onQuit: () async {
          _trayManager.dispose();
          await windowManager.destroy();
        },
      );
      _trayInitialized = true;
    } catch (_) {}
  }

  @override
  void dispose() {
    _trayManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodexBar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF607D8B), // blueGrey
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF607D8B),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade700),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: _showSettings
          ? PreferencesView(
              onBack: () => setState(() => _showSettings = false),
            )
          : MenuCardView(
              onOpenSettings: () => setState(() => _showSettings = true),
            ),
    );
  }
}
