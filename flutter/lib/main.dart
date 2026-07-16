import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';

/// Entry point for the CodexBar Flutter port.
///
/// Bootstraps the window manager, tray controller, and notification plugin,
/// then runs the app. The main window starts hidden (close-to-tray pattern);
/// the tray icon is the primary surface.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  runApp(
    const ProviderScope(
      child: CodexBarApp(),
    ),
  );
}
