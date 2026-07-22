import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class TrayManagerImpl implements TrayListener {
  static final TrayManagerImpl _instance = TrayManagerImpl._();
  factory TrayManagerImpl() => _instance;
  TrayManagerImpl._();

  bool _isPopupVisible = false;

  Future<void> initialize() async {
    await TrayManager.instance.setIcon(
      'assets/icons/tray_icon.png',
      isTemplate: true,
    );
    TrayManager.instance.addListener(this);
    await TrayManager.instance.setToolTip('CodexBar');
  }

  @override
  void onTrayIconMouseDown() {
    _togglePopup();
  }

  @override
  void onTrayIconMouseUp() {
    // No-op
  }

  @override
  void onTrayIconRightMouseDown() {
    _showContextMenu();
  }

  @override
  void onTrayIconRightMouseUp() {
    // No-op
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'settings':
        // Open settings window
        break;
      case 'refresh':
        // Trigger refresh
        break;
      case 'quit':
        exit(0);
    }
  }

  void _togglePopup() {
    if (_isPopupVisible) {
      _hidePopup();
    } else {
      _showPopup();
    }
  }

  Future<void> _showPopup() async {
    _isPopupVisible = true;

    // Get tray icon position
    final trayBounds = await TrayManager.instance.getBounds();
    if (trayBounds == null) return;

    // Position the popup window near the tray icon
    final popupX = trayBounds.left.clamp(0, 1920 - 400).toDouble();
    final popupY = trayBounds.bottom + 4;

    await windowManager.setSize(const Size(380, 500));
    await windowManager.setPosition(Offset(popupX, popupY));
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _hidePopup() async {
    _isPopupVisible = false;
    await windowManager.hide();
  }

  Future<void> _showContextMenu() async {
    final menu = Menu(
      items: [
        MenuItem(key: 'settings', label: 'Settings'),
        MenuItem(key: 'refresh', label: 'Refresh All'),
        MenuItem.separator(),
        MenuItem(key: 'quit', label: 'Quit CodexBar'),
      ],
    );
    await TrayManager.instance.setContextMenu(menu);
  }
}

final navigatorKey = GlobalKey<NavigatorState>();
