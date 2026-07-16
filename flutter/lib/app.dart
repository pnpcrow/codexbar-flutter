import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'core/notifications/app_notifications.dart';
import 'state/settings_store.dart';
import 'state/usage_store.dart';
import 'ui/menu_card/tray_popup.dart';
import 'ui/settings/settings_view.dart';
import 'ui/theme/app_theme.dart';
import 'ui/tray/tray_controller.dart';

/// Root widget for the CodexBar Flutter port.
///
/// Hosts a [MaterialApp] with two routes: the tray popup (`/`) and settings
/// (`/settings`). The tray controller and notification plugin are initialized
/// once the first frame is built.
class CodexBarApp extends ConsumerStatefulWidget {
  const CodexBarApp({super.key});

  @override
  ConsumerState<CodexBarApp> createState() => _CodexBarAppState();
}

class _CodexBarAppState extends ConsumerState<CodexBarApp> with WindowListener {
  final _SizeRouter _router = _SizeRouter();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final tray = ref.read(trayControllerProvider);
    await tray.initialize(ref);
    final notifications = ref.read(appNotificationsProvider);
    await notifications.initialize();
    await notifications.requestAuthorization();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    // Close-to-tray: hide instead of closing.
    await windowManager.hide();
  }

  @override
  Widget build(BuildContext context) {
    // Subscribe to state changes from within build (ref.listen is only legal
    // here) and refresh the tray icon accordingly.
    final tray = ref.read(trayControllerProvider);
    ref.listen(usageStoreProvider, (_, __) => tray.refreshIcon());
    ref.listen(settingsStoreProvider, (_, __) => tray.refreshIcon());

    return MaterialApp(
      title: 'CodexBar',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: '/',
      navigatorObservers: [_router],
      onGenerateRoute: _router.onGenerateRoute,
    );
  }
}

/// A [NavigatorObserver] that resizes the host window to match the current
/// route: a compact size for the tray popup and a larger one for settings.
///
/// Real CodexBar shows its settings window at 880×620; the tray popup is a
/// narrow menu card. Because Flutter can't run windowless on desktop, we host
/// both surfaces in the same window and resize on navigation.
class _SizeRouter extends NavigatorObserver {
  static const _traySize = Size(360, 560);
  static const _settingsSize = Size(900, 640);

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsView(),
          settings: settings,
        );
      case '/':
      default:
        return MaterialPageRoute(
          builder: (_) => const _TraySurface(),
          settings: const RouteSettings(name: '/'),
        );
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _resizeFor(route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _resizeFor(previousRoute?.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _resizeFor(newRoute?.settings.name);
  }

  void _resizeFor(String? name) {
    final size = name == '/settings' ? _settingsSize : _traySize;
    // Resize without forcing — avoids jarring jumps on platforms that ignore it.
    windowManager.setSize(size);
  }
}

/// The surface shown when the window is visible: the tray popup card.
class _TraySurface extends StatelessWidget {
  const _TraySurface();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const TrayPopup(),
        ),
      ),
    );
  }
}
