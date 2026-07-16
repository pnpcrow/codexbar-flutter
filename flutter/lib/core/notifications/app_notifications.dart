import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'usage_change_detector.dart';

/// Wraps `flutter_local_notifications` to post usage notifications.
///
/// Ported conceptually from `AppNotifications` (Swift `UNUserNotificationCenter`
/// wrapper). Requests authorization on init and posts notifications via the
/// platform plugin. Suppressed on web/non-supported platforms.
class AppNotifications {
  AppNotifications({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _authorized = false;

  static const _channelId = 'codexbar_usage';
  static const _channelName = 'CodexBar usage';

  Future<void> initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      linux: LinuxInitializationSettings(defaultActionName: 'open'),
      macOS: DarwinInitializationSettings(),
    );
    final ok = await _plugin.initialize(settings: settings);
    _authorized = ok ?? false;
  }

  Future<void> requestAuthorization() async {
    try {
      final macOS = _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();
      if (macOS != null) {
        final granted = await macOS.requestPermissions(
          alert: true,
          sound: true,
          badge: true,
        );
        _authorized = granted ?? false;
        return;
      }
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        await android.requestNotificationsPermission();
        _authorized = true;
        return;
      }
      // Linux/Windows have no runtime permission prompt; assume granted.
      _authorized = true;
    } on Object {
      _authorized = false;
    }
  }

  bool get isAuthorized => _authorized;

  /// Post a [UsageNotification] if authorized. Returns true if posted.
  Future<bool> post(UsageNotification notification, {bool soundEnabled = true}) async {
    if (!_authorized) return false;
    try {
      await _plugin.show(
        // Stable per-provider id so a new notification replaces the prior one.
        id: notification.provider.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.high,
            priority: Priority.high,
            playSound: soundEnabled,
          ),
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: soundEnabled,
          ),
          linux: LinuxNotificationDetails(
            urgency: LinuxNotificationUrgency.normal,
            resident: false,
          ),
        ),
      );
      return true;
    } on Object {
      return false;
    }
  }
}
