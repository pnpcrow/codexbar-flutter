import 'package:flutter/foundation.dart';

import '../models/usage_provider.dart';

/// Refresh cadence. Ported from `RefreshFrequency` in `SettingsStore.swift`.
enum RefreshFrequency {
  manual,
  minutes1,
  minutes2,
  minutes5,
  minutes15,
  minutes30,
  adaptive;

  String get displayName => switch (this) {
        RefreshFrequency.manual => 'Manual',
        RefreshFrequency.minutes1 => '1 minute',
        RefreshFrequency.minutes2 => '2 minutes',
        RefreshFrequency.minutes5 => '5 minutes',
        RefreshFrequency.minutes15 => '15 minutes',
        RefreshFrequency.minutes30 => '30 minutes',
        RefreshFrequency.adaptive => 'Adaptive',
      };

  /// Fixed interval in minutes, or `null` for manual/adaptive.
  int? get fixedMinutes => switch (this) {
        RefreshFrequency.manual => null,
        RefreshFrequency.minutes1 => 1,
        RefreshFrequency.minutes2 => 2,
        RefreshFrequency.minutes5 => 5,
        RefreshFrequency.minutes15 => 15,
        RefreshFrequency.minutes30 => 30,
        RefreshFrequency.adaptive => null,
      };

  static RefreshFrequency fromIndex(int index) {
    return RefreshFrequency.values[index.clamp(0, RefreshFrequency.values.length - 1)];
  }
}

/// What the menu bar icon shows for the percentage. Ported from
/// `MenuBarDisplayMode`.
enum MenuBarDisplayMode {
  percent,
  pace,
  resetTime,
  both;

  String get displayName => switch (this) {
        MenuBarDisplayMode.percent => 'Percent',
        MenuBarDisplayMode.pace => 'Pace',
        MenuBarDisplayMode.resetTime => 'Reset time',
        MenuBarDisplayMode.both => 'Both',
      };
}

/// Notification thresholds for usage warnings. The user-facing "change
/// detection + threshold" feature.
@immutable
class NotificationThresholds {
  const NotificationThresholds({
    this.sessionWarningPercent = 80,
    this.sessionCriticalPercent = 95,
  });

  /// Percent at which a warning notification fires (once per crossing).
  final int sessionWarningPercent;

  /// Percent at which a critical notification fires (once per crossing).
  final int sessionCriticalPercent;

  NotificationThresholds copyWith({int? sessionWarningPercent, int? sessionCriticalPercent}) {
    return NotificationThresholds(
      sessionWarningPercent: sessionWarningPercent ?? this.sessionWarningPercent,
      sessionCriticalPercent: sessionCriticalPercent ?? this.sessionCriticalPercent,
    );
  }

  List<int> get sortedPercents =>
      [sessionWarningPercent, sessionCriticalPercent]..sort();
}

/// The full user-facing settings state. A subset of Swift's `SettingsStore`
/// scalar preferences (see `loadDefaultsState`); keys not yet relevant to the
/// Flutter port are omitted and can be added incrementally.
@immutable
class SettingsState {
  const SettingsState({
    this.refreshFrequency = RefreshFrequency.minutes5,
    this.refreshAllProvidersOnMenuOpen = false,
    this.launchAtLogin = false,
    this.usageBarsShowUsed = false,
    this.resetTimesShowAbsolute = false,
    this.menuBarShowsBrandIconWithPercent = false,
    this.menuBarDisplayMode = MenuBarDisplayMode.percent,
    this.menuBarHidesCritters = false,
    this.mergeIcons = true,
    this.providersSortedAlphabetically = false,
    this.changeDetectionNotificationsEnabled = true,
    this.thresholdNotificationsEnabled = true,
    this.notificationSoundEnabled = true,
    this.thresholds = const NotificationThresholds(),
    this.enabledProviders = const {},
    this.providerOrder = const [],
    this.appLanguage = 'en',
  });

  /// Refresh cadence (manual / 1 / 2 / 5 / 15 / 30 / adaptive). Default 5 min.
  final RefreshFrequency refreshFrequency;

  /// Refresh all providers when the menu opens (opt-in).
  final bool refreshAllProvidersOnMenuOpen;

  /// Start at login. Platform integration is a follow-up.
  final bool launchAtLogin;

  /// Show % used (true) vs % left (false).
  final bool usageBarsShowUsed;

  /// Show absolute reset times rather than relative ("in 2h").
  final bool resetTimesShowAbsolute;

  /// Show the brand logo + percent text instead of the meter icon.
  final bool menuBarShowsBrandIconWithPercent;

  final MenuBarDisplayMode menuBarDisplayMode;

  /// Suppress the provider critter personality.
  final bool menuBarHidesCritters;

  /// Merge all providers into one status item (default true).
  final bool mergeIcons;

  /// Sort providers alphabetically instead of by usage relevance.
  final bool providersSortedAlphabetically;

  /// Notify when usage changes between refreshes (user-requested feature).
  final bool changeDetectionNotificationsEnabled;

  /// Notify when usage crosses a threshold percent.
  final bool thresholdNotificationsEnabled;

  /// Play a sound with notifications.
  final bool notificationSoundEnabled;

  final NotificationThresholds thresholds;

  /// Enabled providers (by raw name). Stored here rather than UserDefaults to
  /// mirror the Swift `CodexBarConfig` provider list.
  final Set<UsageProvider> enabledProviders;

  /// Provider display order; providers not listed sort to the end.
  final List<UsageProvider> providerOrder;

  /// App language code (e.g. `en`, `ko`).
  final String appLanguage;

  SettingsState copyWith({
    RefreshFrequency? refreshFrequency,
    bool? refreshAllProvidersOnMenuOpen,
    bool? launchAtLogin,
    bool? usageBarsShowUsed,
    bool? resetTimesShowAbsolute,
    bool? menuBarShowsBrandIconWithPercent,
    MenuBarDisplayMode? menuBarDisplayMode,
    bool? menuBarHidesCritters,
    bool? mergeIcons,
    bool? providersSortedAlphabetically,
    bool? changeDetectionNotificationsEnabled,
    bool? thresholdNotificationsEnabled,
    bool? notificationSoundEnabled,
    NotificationThresholds? thresholds,
    Set<UsageProvider>? enabledProviders,
    List<UsageProvider>? providerOrder,
    String? appLanguage,
  }) {
    return SettingsState(
      refreshFrequency: refreshFrequency ?? this.refreshFrequency,
      refreshAllProvidersOnMenuOpen:
          refreshAllProvidersOnMenuOpen ?? this.refreshAllProvidersOnMenuOpen,
      launchAtLogin: launchAtLogin ?? this.launchAtLogin,
      usageBarsShowUsed: usageBarsShowUsed ?? this.usageBarsShowUsed,
      resetTimesShowAbsolute: resetTimesShowAbsolute ?? this.resetTimesShowAbsolute,
      menuBarShowsBrandIconWithPercent:
          menuBarShowsBrandIconWithPercent ?? this.menuBarShowsBrandIconWithPercent,
      menuBarDisplayMode: menuBarDisplayMode ?? this.menuBarDisplayMode,
      menuBarHidesCritters: menuBarHidesCritters ?? this.menuBarHidesCritters,
      mergeIcons: mergeIcons ?? this.mergeIcons,
      providersSortedAlphabetically:
          providersSortedAlphabetically ?? this.providersSortedAlphabetically,
      changeDetectionNotificationsEnabled:
          changeDetectionNotificationsEnabled ?? this.changeDetectionNotificationsEnabled,
      thresholdNotificationsEnabled:
          thresholdNotificationsEnabled ?? this.thresholdNotificationsEnabled,
      notificationSoundEnabled: notificationSoundEnabled ?? this.notificationSoundEnabled,
      thresholds: thresholds ?? this.thresholds,
      enabledProviders: enabledProviders ?? this.enabledProviders,
      providerOrder: providerOrder ?? this.providerOrder,
      appLanguage: appLanguage ?? this.appLanguage,
    );
  }
}
