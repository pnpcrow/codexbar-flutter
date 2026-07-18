import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/providers/provider_registry.dart';
import 'core/providers/unified_provider_registry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register all providers using unified registry
  final registry = ProviderRegistry();
  UnifiedProviderRegistry.registerAll(registry);

  // Initialize window manager for desktop
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(420, 640),
    minimumSize: Size(360, 480),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: true,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: CodexBarApp()));
}
