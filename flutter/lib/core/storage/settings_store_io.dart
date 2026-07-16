import 'package:shared_preferences/shared_preferences.dart';

import '../models/usage_provider.dart';
import 'settings_state.dart';

/// Persists [SettingsState] to `shared_preferences`, mirroring the Swift
/// `UserDefaults` scalar preferences. Provider enablement/order are serialized
/// as JSON-encoded name lists.
class SettingsStoreIO {
  static const _kRefreshFrequency = 'refreshFrequency';
  static const _kRefreshAllProvidersOnMenuOpen = 'refreshAllProvidersOnMenuOpen';
  static const _kLaunchAtLogin = 'launchAtLogin';
  static const _kUsageBarsShowUsed = 'usageBarsShowUsed';
  static const _kResetTimesShowAbsolute = 'resetTimesShowAbsolute';
  static const _kMenuBarShowsBrandIconWithPercent = 'menuBarShowsBrandIconWithPercent';
  static const _kMenuBarDisplayMode = 'menuBarDisplayMode';
  static const _kMenuBarHidesCritters = 'menuBarHidesCritters';
  static const _kMergeIcons = 'mergeIcons';
  static const _kProvidersSortedAlphabetically = 'providersSortedAlphabetically';
  static const _kChangeDetectionNotificationsEnabled = 'changeDetectionNotificationsEnabled';
  static const _kThresholdNotificationsEnabled = 'thresholdNotificationsEnabled';
  static const _kNotificationSoundEnabled = 'notificationSoundEnabled';
  static const _kSessionWarningPercent = 'sessionWarningPercent';
  static const _kSessionCriticalPercent = 'sessionCriticalPercent';
  static const _kEnabledProviders = 'enabledProviders';
  static const _kProviderOrder = 'providerOrder';
  static const _kAppLanguage = 'appLanguage';

  Future<SettingsState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final enabledNames = prefs.getStringList(_kEnabledProviders) ?? const [];
    final orderNames = prefs.getStringList(_kProviderOrder) ?? const [];
    return SettingsState(
      refreshFrequency: RefreshFrequency.fromIndex(
        prefs.getInt(_kRefreshFrequency) ?? RefreshFrequency.minutes5.index,
      ),
      refreshAllProvidersOnMenuOpen: prefs.getBool(_kRefreshAllProvidersOnMenuOpen) ?? false,
      launchAtLogin: prefs.getBool(_kLaunchAtLogin) ?? false,
      usageBarsShowUsed: prefs.getBool(_kUsageBarsShowUsed) ?? false,
      resetTimesShowAbsolute: prefs.getBool(_kResetTimesShowAbsolute) ?? false,
      menuBarShowsBrandIconWithPercent:
          prefs.getBool(_kMenuBarShowsBrandIconWithPercent) ?? false,
      menuBarDisplayMode: MenuBarDisplayMode.values[
          (prefs.getInt(_kMenuBarDisplayMode) ?? MenuBarDisplayMode.percent.index)
              .clamp(0, MenuBarDisplayMode.values.length - 1)],
      menuBarHidesCritters: prefs.getBool(_kMenuBarHidesCritters) ?? false,
      mergeIcons: prefs.getBool(_kMergeIcons) ?? true,
      providersSortedAlphabetically: prefs.getBool(_kProvidersSortedAlphabetically) ?? false,
      changeDetectionNotificationsEnabled:
          prefs.getBool(_kChangeDetectionNotificationsEnabled) ?? true,
      thresholdNotificationsEnabled: prefs.getBool(_kThresholdNotificationsEnabled) ?? true,
      notificationSoundEnabled: prefs.getBool(_kNotificationSoundEnabled) ?? true,
      thresholds: NotificationThresholds(
        sessionWarningPercent: prefs.getInt(_kSessionWarningPercent) ?? 80,
        sessionCriticalPercent: prefs.getInt(_kSessionCriticalPercent) ?? 95,
      ),
      enabledProviders: enabledNames
          .map(UsageProvider.fromString)
          .whereType<UsageProvider>()
          .toSet(),
      providerOrder: orderNames
          .map(UsageProvider.fromString)
          .whereType<UsageProvider>()
          .toList(),
      appLanguage: prefs.getString(_kAppLanguage) ?? 'en',
    );
  }

  Future<void> save(SettingsState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kRefreshFrequency, state.refreshFrequency.index);
    await prefs.setBool(_kRefreshAllProvidersOnMenuOpen, state.refreshAllProvidersOnMenuOpen);
    await prefs.setBool(_kLaunchAtLogin, state.launchAtLogin);
    await prefs.setBool(_kUsageBarsShowUsed, state.usageBarsShowUsed);
    await prefs.setBool(_kResetTimesShowAbsolute, state.resetTimesShowAbsolute);
    await prefs.setBool(_kMenuBarShowsBrandIconWithPercent, state.menuBarShowsBrandIconWithPercent);
    await prefs.setInt(_kMenuBarDisplayMode, state.menuBarDisplayMode.index);
    await prefs.setBool(_kMenuBarHidesCritters, state.menuBarHidesCritters);
    await prefs.setBool(_kMergeIcons, state.mergeIcons);
    await prefs.setBool(_kProvidersSortedAlphabetically, state.providersSortedAlphabetically);
    await prefs.setBool(
        _kChangeDetectionNotificationsEnabled, state.changeDetectionNotificationsEnabled);
    await prefs.setBool(_kThresholdNotificationsEnabled, state.thresholdNotificationsEnabled);
    await prefs.setBool(_kNotificationSoundEnabled, state.notificationSoundEnabled);
    await prefs.setInt(_kSessionWarningPercent, state.thresholds.sessionWarningPercent);
    await prefs.setInt(_kSessionCriticalPercent, state.thresholds.sessionCriticalPercent);
    await prefs.setStringList(
        _kEnabledProviders, state.enabledProviders.map((p) => p.name).toList());
    await prefs.setStringList(
        _kProviderOrder, state.providerOrder.map((p) => p.name).toList());
    await prefs.setString(_kAppLanguage, state.appLanguage);
  }
}
