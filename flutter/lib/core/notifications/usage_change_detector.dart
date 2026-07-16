import 'package:flutter/foundation.dart';

import '../models/usage_provider.dart';
import '../models/usage_snapshot.dart';
import '../storage/settings_state.dart';

/// Detects usage changes and threshold crossings between refreshes, producing
/// the notifications to post.
///
/// This implements the user's core requirement: "notify when the previous
/// state differs from the current usage", plus optional threshold warnings.
/// It is a pure, testable state machine mirroring the role of Swift's
/// `SessionQuotaNotifications` but simplified to change + threshold detection.
class UsageChangeDetector {
  UsageChangeDetector();

  /// Last seen usedPercent per provider, for change detection.
  final Map<UsageProvider, double> _lastUsedPercent = {};

  /// Thresholds already notified for each provider (so we don't re-fire while
  /// usage stays above the threshold). Reset when usage drops back below.
  final Map<UsageProvider, Set<int>> _firedThresholds = {};

  /// Compute the notifications to post after a refresh produced [newSnapshot]
  /// for [provider], given the current [settings].
  ///
  /// Call this on the main thread after each successful fetch. Returns the
  /// list of notifications to post (possibly empty).
  List<UsageNotification> process({
    required UsageProvider provider,
    required UsageSnapshot newSnapshot,
    required SettingsState settings,
  }) {
    final notifications = <UsageNotification>[];
    final usedPercent = _effectiveUsedPercent(newSnapshot);

    // Change detection: notify if the previous value differs.
    if (settings.changeDetectionNotificationsEnabled && usedPercent != null) {
      final previous = _lastUsedPercent[provider];
      if (previous != null && (previous - usedPercent).abs() >= 0.5) {
        notifications.add(UsageNotification.changeDetected(
          provider: provider,
          previousPercent: previous,
          currentPercent: usedPercent,
        ));
      }
      _lastUsedPercent[provider] = usedPercent;
    }

    // Threshold warnings: fire once per upward crossing.
    if (settings.thresholdNotificationsEnabled && usedPercent != null) {
      final thresholds = settings.thresholds.sortedPercents.toSet();
      final fired = _firedThresholds.putIfAbsent(provider, () => <int>{});
      for (final threshold in thresholds) {
        if (usedPercent >= threshold && !fired.contains(threshold)) {
          fired.add(threshold);
          notifications.add(UsageNotification.thresholdReached(
            provider: provider,
            thresholdPercent: threshold,
            currentPercent: usedPercent,
          ));
        } else if (usedPercent < threshold - 2) {
          // Hysteresis: re-arm once usage drops comfortably below.
          fired.remove(threshold);
        }
      }
    }

    return notifications;
  }

  /// Reset all tracked state (e.g. when a provider is disabled).
  void reset(UsageProvider provider) {
    _lastUsedPercent.remove(provider);
    _firedThresholds.remove(provider);
  }

  /// Reset everything.
  void resetAll() {
    _lastUsedPercent.clear();
    _firedThresholds.clear();
  }

  /// Effective usedPercent for a snapshot, preferring primary then secondary.
  static double? _effectiveUsedPercent(UsageSnapshot snapshot) {
    final primary = snapshot.primary?.usedPercent;
    if (primary != null) return primary;
    final secondary = snapshot.secondary?.usedPercent;
    if (secondary != null) return secondary;
    final cost = snapshot.providerCost;
    if (cost != null && cost.limit > 0) return cost.usedPercent;
    return null;
  }
}

/// A notification to post. Sealed so the UI/bridge layer can format copy per
/// kind.
@immutable
class UsageNotification {
  const UsageNotification._({
    required this.provider,
    required this.kind,
    required this.currentPercent,
    this.previousPercent,
    this.thresholdPercent,
  });

  final UsageProvider provider;
  final UsageNotificationKind kind;
  final double currentPercent;
  final double? previousPercent;
  final int? thresholdPercent;

  factory UsageNotification.changeDetected({
    required UsageProvider provider,
    required double previousPercent,
    required double currentPercent,
  }) =>
      UsageNotification._(
        provider: provider,
        kind: UsageNotificationKind.changeDetected,
        currentPercent: currentPercent,
        previousPercent: previousPercent,
      );

  factory UsageNotification.thresholdReached({
    required UsageProvider provider,
    required int thresholdPercent,
    required double currentPercent,
  }) =>
      UsageNotification._(
        provider: provider,
        kind: UsageNotificationKind.thresholdReached,
        currentPercent: currentPercent,
        thresholdPercent: thresholdPercent,
      );

  String get title => switch (kind) {
        UsageNotificationKind.changeDetected => '${provider.name} usage changed',
        UsageNotificationKind.thresholdReached =>
          '${provider.name} ${thresholdPercent}% reached',
      };

  String get body => switch (kind) {
        UsageNotificationKind.changeDetected =>
          '${previousPercent!.toStringAsFixed(0)}% → ${currentPercent.toStringAsFixed(0)}%',
        UsageNotificationKind.thresholdReached =>
          'Now at ${currentPercent.toStringAsFixed(0)}% usage',
      };
}

enum UsageNotificationKind { changeDetected, thresholdReached }
