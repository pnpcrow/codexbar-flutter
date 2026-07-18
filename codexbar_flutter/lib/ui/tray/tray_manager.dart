import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:system_tray/system_tray.dart';

final _log = Logger('TrayManager');

/// System tray manager - handles the menu bar icon and window visibility.
class TrayManager {
  final SystemTray _systemTray = SystemTray();
  bool _initialized = false;

  /// Initialize the system tray.
  Future<void> initialize({
    required VoidCallback onShowWindow,
    required VoidCallback onHideWindow,
    required VoidCallback onQuit,
  }) async {
    if (_initialized) return;

    try {
      final iconPath = _getIconPath();
      if (!File(iconPath).existsSync()) {
        _log.warning('Tray icon not found at $iconPath');
        return;
      }

      await _systemTray.initSystemTray(
        title: 'CodexBar',
        iconPath: iconPath,
      );

      final menu = Menu();
      await menu.buildFrom([
        MenuItemLabel(
          label: 'Show CodexBar',
          onClicked: (_) => onShowWindow(),
        ),
        MenuItemLabel(
          label: 'Hide CodexBar',
          onClicked: (_) => onHideWindow(),
        ),
        MenuSeparator(),
        MenuItemLabel(
          label: 'Quit',
          onClicked: (_) => onQuit(),
        ),
      ]);

      await _systemTray.setContextMenu(menu);

      _systemTray.registerSystemTrayEventHandler((eventName) {
        if (eventName == kSystemTrayEventClick) {
          onShowWindow();
        } else if (eventName == kSystemTrayEventRightClick) {
          _systemTray.popUpContextMenu();
        }
      });

      _initialized = true;
      _log.info('System tray initialized');
    } catch (e) {
      _log.severe('Failed to initialize system tray: $e');
    }
  }

  String _getIconPath() {
    // Use absolute path to the asset
    final scriptDir = Platform.script.toFilePath();
    final projectRoot = scriptDir.contains('lib/')
        ? scriptDir.substring(0, scriptDir.indexOf('lib/'))
        : Directory.current.path;

    // Try multiple paths
    final candidates = [
      '$projectRoot/assets/icons/tray_icon.png',
      '${Directory.current.path}/assets/icons/tray_icon.png',
      '${Directory.current.path}/codexbar_flutter/assets/icons/tray_icon.png',
    ];

    for (final path in candidates) {
      if (File(path).existsSync()) return path;
    }

    // Return first candidate as fallback
    return candidates.first;
  }

  void dispose() {
    if (_initialized) {
      _systemTray.destroy();
    }
  }
}
