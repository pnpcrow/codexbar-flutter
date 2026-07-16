import 'package:flutter_test/flutter_test.dart';

import 'package:codexbar/core/models/rate_window.dart';
import 'package:codexbar/core/models/usage_provider.dart';
import 'package:codexbar/core/models/usage_snapshot.dart';
import 'package:codexbar/core/notifications/usage_change_detector.dart';
import 'package:codexbar/core/storage/settings_state.dart';

UsageSnapshot _snapshot(double usedPercent) {
  return UsageSnapshot(
    primary: RateWindow(usedPercent: usedPercent),
    updatedAt: DateTime.utc(2026, 7, 16, 12),
  );
}

void main() {
  const settings = SettingsState(
    changeDetectionNotificationsEnabled: true,
    thresholdNotificationsEnabled: true,
    thresholds: NotificationThresholds(sessionWarningPercent: 80, sessionCriticalPercent: 95),
  );

  group('UsageChangeDetector', () {
    test('no change detection on the first ever reading', () {
      final detector = UsageChangeDetector();
      final notifications = detector.process(
        provider: UsageProvider.openai,
        newSnapshot: _snapshot(30),
        settings: settings,
      );
      // No prior value → no change notification (but a threshold below 80 still doesn't fire).
      expect(notifications, isEmpty);
    });

    test('change detection fires when percent differs between refreshes', () {
      final detector = UsageChangeDetector();
      detector.process(
        provider: UsageProvider.openai,
        newSnapshot: _snapshot(30),
        settings: settings,
      );
      final notifications = detector.process(
        provider: UsageProvider.openai,
        newSnapshot: _snapshot(41),
        settings: settings,
      );
      final change = notifications.where((n) =>
          n.kind == UsageNotificationKind.changeDetected);
      expect(change, hasLength(1));
      expect(change.first.previousPercent, 30);
      expect(change.first.currentPercent, 41);
    });

    test('threshold warning fires once when crossing 80%', () {
      final detector = UsageChangeDetector();
      detector.process(
        provider: UsageProvider.openai,
        newSnapshot: _snapshot(70),
        settings: settings,
      );
      // Cross the warning threshold.
      var notifications = detector.process(
        provider: UsageProvider.openai,
        newSnapshot: _snapshot(82),
        settings: settings,
      );
      expect(
        notifications.where((n) => n.kind == UsageNotificationKind.thresholdReached),
        hasLength(1),
      );
      // Another refresh above 80% must NOT re-fire the warning.
      notifications = detector.process(
        provider: UsageProvider.openai,
        newSnapshot: _snapshot(85),
        settings: settings,
      );
      expect(
        notifications.where((n) => n.kind == UsageNotificationKind.thresholdReached),
        isEmpty,
      );
    });

    test('critical threshold fires separately from warning', () {
      final detector = UsageChangeDetector();
      detector.process(
        provider: UsageProvider.openai,
        newSnapshot: _snapshot(82),
        settings: settings,
      );
      final notifications = detector.process(
        provider: UsageProvider.openai,
        newSnapshot: _snapshot(96),
        settings: settings,
      );
      // 95% crossing fires; 80% already fired+armed in the prior step.
      final threshold = notifications
          .where((n) => n.kind == UsageNotificationKind.thresholdReached)
          .toList();
      expect(threshold, hasLength(1));
      expect(threshold.first.thresholdPercent, 95);
    });

    test('threshold re-arms when usage drops back below it', () {
      final detector = UsageChangeDetector();
      detector.process(provider: UsageProvider.openai, newSnapshot: _snapshot(85), settings: settings);
      // Drop well below the warning threshold.
      detector.process(provider: UsageProvider.openai, newSnapshot: _snapshot(50), settings: settings);
      // Crossing again should re-fire.
      final notifications = detector.process(
        provider: UsageProvider.openai,
        newSnapshot: _snapshot(81),
        settings: settings,
      );
      expect(
        notifications.where((n) => n.kind == UsageNotificationKind.thresholdReached),
        hasLength(1),
      );
    });

    test('change detection disabled produces no change notifications', () {
      final detector = UsageChangeDetector();
      const disabled = SettingsState(changeDetectionNotificationsEnabled: false);
      detector.process(provider: UsageProvider.openai, newSnapshot: _snapshot(30), settings: disabled);
      final notifications = detector.process(
        provider: UsageProvider.openai,
        newSnapshot: _snapshot(50),
        settings: disabled,
      );
      expect(
        notifications.where((n) => n.kind == UsageNotificationKind.changeDetected),
        isEmpty,
      );
    });

    test('notification copy includes provider and percentages', () {
      final n = UsageNotification.changeDetected(
        provider: UsageProvider.openai,
        previousPercent: 30,
        currentPercent: 41,
      );
      expect(n.title, contains('openai'));
      expect(n.body, contains('30%'));
      expect(n.body, contains('41%'));
    });
  });
}
