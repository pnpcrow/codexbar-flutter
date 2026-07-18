import 'package:shared_preferences/shared_preferences.dart';

import '../models/usage_provider.dart';

/// Refresh frequency options.
/// Direct port of Swift RefreshFrequency.
enum RefreshFrequency {
  manual,
  oneMinute,
  twoMinutes,
  fiveMinutes,
  fifteenMinutes,
  thirtyMinutes,
  adaptive;

  Duration? get duration {
    switch (this) {
      case RefreshFrequency.manual:
        return null;
      case RefreshFrequency.oneMinute:
        return const Duration(minutes: 1);
      case RefreshFrequency.twoMinutes:
        return const Duration(minutes: 2);
      case RefreshFrequency.fiveMinutes:
        return const Duration(minutes: 5);
      case RefreshFrequency.fifteenMinutes:
        return const Duration(minutes: 15);
      case RefreshFrequency.thirtyMinutes:
        return const Duration(minutes: 30);
      case RefreshFrequency.adaptive:
        return null; // Computed per tick
    }
  }

  String get label {
    switch (this) {
      case RefreshFrequency.manual:
        return 'Manual';
      case RefreshFrequency.oneMinute:
        return '1 min';
      case RefreshFrequency.twoMinutes:
        return '2 min';
      case RefreshFrequency.fiveMinutes:
        return '5 min';
      case RefreshFrequency.fifteenMinutes:
        return '15 min';
      case RefreshFrequency.thirtyMinutes:
        return '30 min';
      case RefreshFrequency.adaptive:
        return 'Adaptive';
    }
  }
}

/// Menu bar metric preference.
enum MenuBarMetricPreference {
  automatic,
  primary,
  secondary,
  primaryAndSecondary,
  tertiary,
  extraUsage,
  average,
  monthlyPlan;
}

/// Settings store - manages all user preferences.
/// Direct port of Swift SettingsStore.
class SettingsStore {
  final SharedPreferences _prefs;

  SettingsStore(this._prefs);

  // --- General ---
  RefreshFrequency get refreshFrequency {
    final index = _prefs.getInt('refreshFrequency') ?? 0;
    return RefreshFrequency.values[index.clamp(0, RefreshFrequency.values.length - 1)];
  }

  set refreshFrequency(RefreshFrequency value) {
    _prefs.setInt('refreshFrequency', value.index);
  }

  bool get launchAtLogin => _prefs.getBool('launchAtLogin') ?? false;
  set launchAtLogin(bool value) => _prefs.setBool('launchAtLogin', value);

  // --- Providers ---
  Set<UsageProvider> get enabledProviders {
    final stored = _prefs.getStringList('enabledProviders');
    if (stored == null) {
      return {
        UsageProvider.codex,
        UsageProvider.claude,
        UsageProvider.openai,
      };
    }
    return stored.map((name) {
      try {
        return UsageProvider.values.byName(name);
      } catch (_) {
        return null;
      }
    }).whereType<UsageProvider>().toSet();
  }

  set enabledProviders(Set<UsageProvider> value) {
    _prefs.setStringList('enabledProviders', value.map((p) => p.name).toList());
  }

  void toggleProvider(UsageProvider provider) {
    final current = enabledProviders;
    if (current.contains(provider)) {
      current.remove(provider);
    } else {
      current.add(provider);
    }
    enabledProviders = current;
  }

  // --- Menu Bar ---
  MenuBarMetricPreference get menuBarMetricPreference {
    final index = _prefs.getInt('menuBarMetricPreference') ?? 0;
    return MenuBarMetricPreference.values[index.clamp(0, MenuBarMetricPreference.values.length - 1)];
  }

  set menuBarMetricPreference(MenuBarMetricPreference value) {
    _prefs.setInt('menuBarMetricPreference', value.index);
  }

  bool get showMenuBarIcon => _prefs.getBool('showMenuBarIcon') ?? true;
  set showMenuBarIcon(bool value) => _prefs.setBool('showMenuBarIcon', value);

  bool get showUsagePercentage => _prefs.getBool('showUsagePercentage') ?? true;
  set showUsagePercentage(bool value) => _prefs.setBool('showUsagePercentage', value);

  // --- Notifications ---
  bool get notificationsEnabled => _prefs.getBool('notificationsEnabled') ?? true;
  set notificationsEnabled(bool value) => _prefs.setBool('notificationsEnabled', value);

  bool get notifyOnUsageChange => _prefs.getBool('notifyOnUsageChange') ?? false;
  set notifyOnUsageChange(bool value) => _prefs.setBool('notifyOnUsageChange', value);

  bool get notifyOnLimitReset => _prefs.getBool('notifyOnLimitReset') ?? true;
  set notifyOnLimitReset(bool value) => _prefs.setBool('notifyOnLimitReset', value);

  bool get confettiOnSessionLimitResets =>
      _prefs.getBool('confettiOnSessionLimitResets') ?? false;
  set confettiOnSessionLimitResets(bool value) =>
      _prefs.setBool('confettiOnSessionLimitResets', value);

  bool get confettiOnWeeklyLimitResets =>
      _prefs.getBool('confettiOnWeeklyLimitResets') ?? false;
  set confettiOnWeeklyLimitResets(bool value) =>
      _prefs.setBool('confettiOnWeeklyLimitResets', value);

  // --- Debug ---
  String? get debugLogLevel => _prefs.getString('debugLogLevel');
  set debugLogLevel(String? value) {
    if (value == null) {
      _prefs.remove('debugLogLevel');
    } else {
      _prefs.setString('debugLogLevel', value);
    }
  }

  // --- Provider-specific settings ---
  String? providerSourceMode(UsageProvider provider) =>
      _prefs.getString('providerSourceMode_${provider.name}');

  void setProviderSourceMode(UsageProvider provider, String? mode) {
    if (mode == null) {
      _prefs.remove('providerSourceMode_${provider.name}');
    } else {
      _prefs.setString('providerSourceMode_${provider.name}', mode);
    }
  }

  String? providerCookieSource(UsageProvider provider) =>
      _prefs.getString('providerCookieSource_${provider.name}');

  void setProviderCookieSource(UsageProvider provider, String? source) {
    if (source == null) {
      _prefs.remove('providerCookieSource_${provider.name}');
    } else {
      _prefs.setString('providerCookieSource_${provider.name}', source);
    }
  }

  String? providerManualCookieHeader(UsageProvider provider) =>
      _prefs.getString('providerManualCookieHeader_${provider.name}');

  void setProviderManualCookieHeader(UsageProvider provider, String? header) {
    if (header == null) {
      _prefs.remove('providerManualCookieHeader_${provider.name}');
    } else {
      _prefs.setString('providerManualCookieHeader_${provider.name}', header);
    }
  }

  String? providerAPIKey(UsageProvider provider) =>
      _prefs.getString('providerAPIKey_${provider.name}');

  void setProviderAPIKey(UsageProvider provider, String? key) {
    if (key == null) {
      _prefs.remove('providerAPIKey_${provider.name}');
    } else {
      _prefs.setString('providerAPIKey_${provider.name}', key);
    }
  }
}
