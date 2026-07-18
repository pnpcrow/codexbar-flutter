import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/usage_provider.dart';

/// System notification service.
/// Direct port of Swift AppNotifications + SessionQuotaNotifications.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notification service.
  Future<void> initialize() async {
    if (_initialized) return;

    const initializationSettings = InitializationSettings(
      macOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
      linux: LinuxInitializationSettings(
        defaultActionName: 'Open',
      ),
      windows: WindowsInitializationSettings(
        appName: 'CodexBar',
        appUserModelId: 'com.steipete.codexbar',
        guid: 'codexbar-notifications',
      ),
    );

    await _plugin.initialize(initializationSettings);
    _initialized = true;
  }

  /// Request notification permissions.
  Future<bool> requestPermission() async {
    if (Platform.isMacOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    return true;
  }

  /// Show usage change notification.
  Future<void> showUsageChangeNotification({
    required UsageProvider provider,
    required double previousPercent,
    required double currentPercent,
  }) async {
    if (!_initialized) await initialize();

    final change = currentPercent - previousPercent;
    final direction = change > 0 ? '↑' : '↓';
    final title = '${provider.displayName} Usage Changed';
    final body = '${previousPercent.toStringAsFixed(1)}% → ${currentPercent.toStringAsFixed(1)}% ($direction${change.abs().toStringAsFixed(1)}%)';

    await _showNotification(
      id: provider.index * 100,
      title: title,
      body: body,
    );
  }

  /// Show limit reset notification.
  Future<void> showLimitResetNotification({
    required UsageProvider provider,
    required String windowType, // 'session' or 'weekly'
  }) async {
    if (!_initialized) await initialize();

    final title = '${provider.displayName} Limit Reset';
    final body = 'Your $windowType limit has been reset.';

    await _showNotification(
      id: provider.index * 100 + 1,
      title: title,
      body: body,
    );
  }

  /// Show quota warning notification.
  Future<void> showQuotaWarningNotification({
    required UsageProvider provider,
    required double usedPercent,
  }) async {
    if (!_initialized) await initialize();

    final title = '${provider.displayName} Quota Warning';
    final body = 'Usage at ${usedPercent.toStringAsFixed(1)}% - approaching limit.';

    await _showNotification(
      id: provider.index * 100 + 2,
      title: title,
      body: body,
    );
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const notificationDetails = NotificationDetails(
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      linux: LinuxNotificationDetails(),
      windows: WindowsNotificationDetails(),
    );

    await _plugin.show(id, title, body, notificationDetails);
  }
}
