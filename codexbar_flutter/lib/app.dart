import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/menu/menu_card_view.dart';
import 'ui/settings/preferences_view.dart';
import 'ui/tray/tray_manager.dart';

/// Main application widget.
/// Direct port of Swift CodexBarApp.
class CodexBarApp extends ConsumerStatefulWidget {
  const CodexBarApp({super.key});

  @override
  ConsumerState<CodexBarApp> createState() => _CodexBarAppState();
}

class _CodexBarAppState extends ConsumerState<CodexBarApp> {
  final TrayManager _trayManager = TrayManager();
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    _initializeTray();
  }

  Future<void> _initializeTray() async {
    await _trayManager.initialize(
      onShowWindow: () => _trayManager.showWindow(),
      onHideWindow: () => _trayManager.hideWindow(),
      onQuit: () {
        _trayManager.dispose();
        // Exit the app
      },
    );
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
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
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
