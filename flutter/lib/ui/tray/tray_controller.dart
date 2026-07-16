import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/models/rate_window.dart';
import '../../core/models/usage_provider.dart';
import '../../core/storage/settings_state.dart';
import '../../state/settings_store.dart';
import '../../state/usage_store.dart';
import 'icon_renderer.dart';

/// Owns the system tray icon and the window show/hide lifecycle.
///
/// Replaces `StatusItemController` + `AppDelegate` lifecycle wiring. Flutter
/// cannot run windowless on desktop, so this uses the close-to-tray pattern:
/// the window is hidden on close and shown again from the tray.
class TrayController with TrayListener, WindowListener {
  TrayController();

  Timer? _iconDebounce;
  bool _initialized = false;

  Future<void> initialize(WidgetRef ref) async {
    if (_initialized) return;
    _initialized = true;
    _ref = ref;

    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        size: Size(360, 560),
        center: false,
        skipTaskbar: true,
        titleBarStyle: TitleBarStyle.normal,
      ),
      () async {
        await windowManager.setPreventClose(true);
        // Start hidden; the tray icon is the primary surface.
        await windowManager.hide();
      },
    );
    windowManager.addListener(this);

    await trayManager.setIcon(_blankIconPath());
    trayManager.addListener(this);
    await trayManager.setTitle('CodexBar');

    // NOTE: callers must subscribe to usage/settings providers from within a
    // build method (ref.listen) and invoke [refreshIcon] on change — see
    // CodexBarApp.build. Calling ref.listen here (outside build) throws an
    // assertion error.
    refreshIcon();
  }

  late WidgetRef _ref;

  /// Render the current usage state into a tray icon image.
  ///
  /// Debounced so rapid snapshot updates don't thrash the rasterizer.
  void refreshIcon() {
    _iconDebounce?.cancel();
    _iconDebounce = Timer(const Duration(milliseconds: 100), _renderAndApplyIcon);
  }

  Future<void> _renderAndApplyIcon() async {
    final ref = _ref;
    final usage = ref.read(usageStoreProvider);
    final settings = ref.read(settingsStoreProvider).value ?? const SettingsState();
    final providers = usage.keys.toList();
    if (providers.isEmpty) {
      await _setIconInput(const IconInput(stale: true));
      return;
    }
    // For the merged icon, take the worst-case remaining across providers.
    final inputs = providers.map((p) => _inputFor(p, usage[p], settings)).toList();
    final primary = inputs
        .map((i) => i.primaryRemaining)
        .whereType<double>()
        .fold<double?>(null, (a, b) => a == null ? b : (a < b ? a : b));
    await _setIconInput(IconInput(
      primaryRemaining: primary,
      stale: inputs.every((i) => i.stale),
      hideCritters: settings.menuBarHidesCritters || providers.length > 1,
    ));
  }

  IconInput _inputFor(
    UsageProvider provider,
    ProviderRuntimeState? state,
    SettingsState settings,
  ) {
    final snapshot = state?.snapshot;
    if (snapshot == null) {
      return IconInput(
        stale: true,
        style: IconStyle.forProvider(provider),
        hideCritters: settings.menuBarHidesCritters,
      );
    }
    return IconInput(
      primaryRemaining: _remainingFor(snapshot.primary),
      secondaryRemaining: _remainingFor(snapshot.secondary),
      creditsRemaining: snapshot.providerCost?.usedPercent != null
          ? 100 - snapshot.providerCost!.usedPercent
          : null,
      stale: false,
      style: IconStyle.forProvider(provider),
      hideCritters: settings.menuBarHidesCritters,
    );
  }

  double? _remainingFor(RateWindow? window) =>
      window == null ? null : window.remainingPercent;

  Future<void> _setIconInput(IconInput input) async {
    try {
      final png = await IconRenderer.rasterizeToPng(input);
      await trayManager.setIcon(_encodeDataUri(png));
    } on Object {
      // Icon rendering failures must never crash the app.
    }
  }

  // ---- TrayListener ----

  @override
  void onTrayIconMouseDown() => _toggleWindow();

  @override
  void onTrayIconRightMouseDown() => _toggleWindow();

  Future<void> _toggleWindow() async {
    _ref.read(usageStoreProvider.notifier).noteMenuOpened();
    if (await windowManager.isVisible()) {
      await windowManager.hide();
    } else {
      await windowManager.show();
      await windowManager.focus();
    }
  }

  // ---- WindowListener (close-to-tray) ----

  @override
  void onWindowClose() async {
    await windowManager.hide();
  }

  String _encodeDataUri(Uint8List png) {
    return 'data:image/png;base64,${base64Encode(png)}';
  }

  String _blankIconPath() => _encodeDataUri(_transparentPng());

  /// A 1×1 transparent PNG so the tray has an icon before the first render.
  Uint8List _transparentPng() {
    final bytes = <int>[
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
      0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41,
      0x54, 0x78, 0x9C, 0x62, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
      0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
      0x42, 0x60, 0x82,
    ];
    return Uint8List.fromList(bytes);
  }

  void dispose() {
    _iconDebounce?.cancel();
    trayManager.removeListener(this);
    windowManager.removeListener(this);
  }
}

/// Singleton provider for the [TrayController].
final trayControllerProvider = Provider<TrayController>((ref) {
  final controller = TrayController();
  ref.onDispose(controller.dispose);
  return controller;
});
