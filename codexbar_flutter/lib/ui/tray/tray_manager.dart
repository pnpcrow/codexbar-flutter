import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

final _log = Logger('TrayManager');

/// System tray manager - handles the menu bar icon and window visibility.
/// Direct port of Swift StatusItemController.
class TrayManager {
  static final TrayManager _instance = TrayManager._();
  factory TrayManager() => _instance;
  TrayManager._();

  final SystemTray _systemTray = SystemTray();
  bool _initialized = false;
  bool _isWindowVisible = false;

  /// Initialize the system tray.
  Future<void> initialize({
    required VoidCallback onShowWindow,
    required VoidCallback onHideWindow,
    required VoidCallback onQuit,
  }) async {
    if (_initialized) return;

    try {
      // Initialize system tray
      await _systemTray.initSystemTray(
        title: 'CodexBar',
        iconPath: _getIconPath(),
      );

      // Build context menu
      final menu = Menu();
      await menu.buildFrom([
        MenuItemLabel(
          label: 'Show CodexBar',
          onClicked: (_) {
            onShowWindow();
            _isWindowVisible = true;
          },
        ),
        MenuItemLabel(
          label: 'Hide CodexBar',
          onClicked: (_) {
            onHideWindow();
            _isWindowVisible = false;
          },
        ),
        MenuSeparator(),
        MenuItemLabel(
          label: 'Refresh All',
          onClicked: (_) {
            // TODO: Trigger refresh
          },
        ),
        MenuSeparator(),
        MenuItemLabel(
          label: 'Preferences...',
          onClicked: (_) {
            // TODO: Open preferences
          },
        ),
        MenuSeparator(),
        MenuItemLabel(
          label: 'Quit',
          onClicked: (_) {
            onQuit();
          },
        ),
      ]);

      await _systemTray.setContextMenu(menu);

      // Handle tray click
      _systemTray.registerSystemTrayEventHandler((eventName) {
        if (eventName == kSystemTrayEventClick) {
          if (_isWindowVisible) {
            onHideWindow();
            _isWindowVisible = false;
          } else {
            onShowWindow();
            _isWindowVisible = true;
          }
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

  /// Update the tray icon with usage percentage.
  Future<void> updateIcon({double? usagePercent, String? providerName}) async {
    if (!_initialized) return;

    try {
      // Update title with usage info
      if (usagePercent != null) {
        await _systemTray.setTitle('${usagePercent.toStringAsFixed(0)}%');
      } else {
        await _systemTray.setTitle('');
      }
    } catch (e) {
      _log.warning('Failed to update tray icon: $e');
    }
  }

  /// Get the icon path based on platform.
  String _getIconPath() {
    if (Platform.isMacOS) {
      return 'assets/icons/tray_icon.png';
    } else if (Platform.isLinux) {
      return 'assets/icons/tray_icon.png';
    } else if (Platform.isWindows) {
      return 'assets/icons/tray_icon.ico';
    }
    return 'assets/icons/tray_icon.png';
  }

  /// Show the main window.
  Future<void> showWindow() async {
    await windowManager.show();
    await windowManager.focus();
    _isWindowVisible = true;
  }

  /// Hide the main window.
  Future<void> hideWindow() async {
    await windowManager.hide();
    _isWindowVisible = false;
  }

  /// Toggle window visibility.
  Future<void> toggleWindow() async {
    if (_isWindowVisible) {
      await hideWindow();
    } else {
      await showWindow();
    }
  }

  /// Dispose resources.
  void dispose() {
    _systemTray.destroy();
  }
}
