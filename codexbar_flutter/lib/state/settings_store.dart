import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

enum RefreshFrequency {
  manual,
  oneMinute,
  twoMinutes,
  fiveMinutes,
  fifteenMinutes,
  thirtyMinutes,
  adaptive;

  String get label {
    switch (this) {
      case RefreshFrequency.manual:
        return 'Manual';
      case RefreshFrequency.oneMinute:
        return '1 minute';
      case RefreshFrequency.twoMinutes:
        return '2 minutes';
      case RefreshFrequency.fiveMinutes:
        return '5 minutes';
      case RefreshFrequency.fifteenMinutes:
        return '15 minutes';
      case RefreshFrequency.thirtyMinutes:
        return '30 minutes';
      case RefreshFrequency.adaptive:
        return 'Adaptive';
    }
  }

  int? get seconds {
    switch (this) {
      case RefreshFrequency.manual:
        return null;
      case RefreshFrequency.oneMinute:
        return 60;
      case RefreshFrequency.twoMinutes:
        return 120;
      case RefreshFrequency.fiveMinutes:
        return 300;
      case RefreshFrequency.fifteenMinutes:
        return 900;
      case RefreshFrequency.thirtyMinutes:
        return 1800;
      case RefreshFrequency.adaptive:
        return null;
    }
  }
}

enum MenuBarDisplayMode {
  percent,
  resetTime,
  iconOnly;

  String get label {
    switch (this) {
      case MenuBarDisplayMode.percent:
        return 'Percent';
      case MenuBarDisplayMode.resetTime:
        return 'Reset time';
      case MenuBarDisplayMode.iconOnly:
        return 'Icon only';
    }
  }
}

class SettingsStore extends ChangeNotifier {
  late SharedPreferences _prefs;

  // General settings
  RefreshFrequency _refreshFrequency = RefreshFrequency.fiveMinutes;
  bool _refreshAllProvidersOnMenuOpen = false;
  bool _launchAtLogin = false;
  String _appLanguage = '';
  bool _statusChecksEnabled = true;

  // Menu bar settings
  bool _mergeIcons = true;
  MenuBarDisplayMode _menuBarDisplayMode = MenuBarDisplayMode.percent;
  bool _menuBarShowsHighestUsage = false;
  bool _menuBarShowsResetTimeWhenExhausted = false;
  bool _randomBlinkEnabled = false;
  bool _hideCritters = false;
  bool _usageBarsShowUsed = false;
  bool _resetTimesShowAbsolute = false;

  // Provider settings
  final Map<String, bool> _providerEnablement = {};
  List<String> _providerOrder = [];

  // Notification settings
  bool _sessionQuotaNotificationsEnabled = true;
  bool _confettiOnSessionLimitResetsEnabled = false;
  bool _confettiOnWeeklyLimitResetsEnabled = false;
  bool _quotaWarningNotificationsEnabled = false;

  // Privacy
  bool _hidePersonalInfo = false;

  // Debug
  bool _debugMenuEnabled = false;
  bool _debugFileLoggingEnabled = false;

  // Getters
  RefreshFrequency get refreshFrequency => _refreshFrequency;
  bool get refreshAllProvidersOnMenuOpen => _refreshAllProvidersOnMenuOpen;
  bool get launchAtLogin => _launchAtLogin;
  String get appLanguage => _appLanguage;
  bool get statusChecksEnabled => _statusChecksEnabled;
  bool get mergeIcons => _mergeIcons;
  MenuBarDisplayMode get menuBarDisplayMode => _menuBarDisplayMode;
  bool get menuBarShowsHighestUsage => _menuBarShowsHighestUsage;
  bool get menuBarShowsResetTimeWhenExhausted => _menuBarShowsResetTimeWhenExhausted;
  bool get randomBlinkEnabled => _randomBlinkEnabled;
  bool get hideCritters => _hideCritters;
  bool get usageBarsShowUsed => _usageBarsShowUsed;
  bool get resetTimesShowAbsolute => _resetTimesShowAbsolute;
  bool get sessionQuotaNotificationsEnabled => _sessionQuotaNotificationsEnabled;
  bool get confettiOnSessionLimitResetsEnabled => _confettiOnSessionLimitResetsEnabled;
  bool get confettiOnWeeklyLimitResetsEnabled => _confettiOnWeeklyLimitResetsEnabled;
  bool get quotaWarningNotificationsEnabled => _quotaWarningNotificationsEnabled;
  bool get hidePersonalInfo => _hidePersonalInfo;
  bool get debugMenuEnabled => _debugMenuEnabled;
  bool get debugFileLoggingEnabled => _debugFileLoggingEnabled;

  bool isProviderEnabled(UsageProvider provider) {
    return _providerEnablement[provider.name] ?? _defaultEnabled(provider);
  }

  bool _defaultEnabled(UsageProvider provider) {
    switch (provider) {
      case UsageProvider.codex:
      case UsageProvider.claude:
      case UsageProvider.cursor:
      case UsageProvider.gemini:
      case UsageProvider.openai:
        return true;
      default:
        return false;
    }
  }

  List<UsageProvider> get orderedProviders {
    if (_providerOrder.isEmpty) return UsageProvider.values;
    final seen = <UsageProvider>{};
    final ordered = <UsageProvider>[];
    for (final name in _providerOrder) {
      final provider = UsageProvider.values.where((p) => p.name == name).firstOrNull;
      if (provider != null && !seen.contains(provider)) {
        seen.add(provider);
        ordered.add(provider);
      }
    }
    for (final provider in UsageProvider.values) {
      if (!seen.contains(provider)) {
        ordered.add(provider);
      }
    }
    return ordered;
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  void _loadSettings() {
    _refreshFrequency = RefreshFrequency.values.firstWhere(
      (f) => f.name == _prefs.getString('refreshFrequency'),
      orElse: () => RefreshFrequency.fiveMinutes,
    );
    _refreshAllProvidersOnMenuOpen = _prefs.getBool('refreshAllProvidersOnMenuOpen') ?? false;
    _launchAtLogin = _prefs.getBool('launchAtLogin') ?? false;
    _appLanguage = _prefs.getString('appLanguage') ?? '';
    _statusChecksEnabled = _prefs.getBool('statusChecksEnabled') ?? true;
    _mergeIcons = _prefs.getBool('mergeIcons') ?? true;
    _menuBarDisplayMode = MenuBarDisplayMode.values.firstWhere(
      (m) => m.name == _prefs.getString('menuBarDisplayMode'),
      orElse: () => MenuBarDisplayMode.percent,
    );
    _menuBarShowsHighestUsage = _prefs.getBool('menuBarShowsHighestUsage') ?? false;
    _menuBarShowsResetTimeWhenExhausted = _prefs.getBool('menuBarShowsResetTimeWhenExhausted') ?? false;
    _randomBlinkEnabled = _prefs.getBool('randomBlinkEnabled') ?? false;
    _hideCritters = _prefs.getBool('menuBarHidesCritters') ?? false;
    _usageBarsShowUsed = _prefs.getBool('usageBarsShowUsed') ?? false;
    _resetTimesShowAbsolute = _prefs.getBool('resetTimesShowAbsolute') ?? false;
    _sessionQuotaNotificationsEnabled = _prefs.getBool('sessionQuotaNotificationsEnabled') ?? true;
    _confettiOnSessionLimitResetsEnabled = _prefs.getBool('confettiOnSessionLimitResetsEnabled') ?? false;
    _confettiOnWeeklyLimitResetsEnabled = _prefs.getBool('confettiOnWeeklyLimitResetsEnabled') ?? false;
    _quotaWarningNotificationsEnabled = _prefs.getBool('quotaWarningNotificationsEnabled') ?? false;
    _hidePersonalInfo = _prefs.getBool('hidePersonalInfo') ?? false;
    _debugMenuEnabled = _prefs.getBool('debugMenuEnabled') ?? false;
    _debugFileLoggingEnabled = _prefs.getBool('debugFileLoggingEnabled') ?? false;
    _providerOrder = _prefs.getStringList('providerOrder') ?? [];
    _loadProviderEnablement();
  }

  void _loadProviderEnablement() {
    final stored = _prefs.getStringList('providerEnablement') ?? [];
    for (final entry in stored) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        _providerEnablement[parts[0]] = parts[1] == 'true';
      }
    }
  }

  Future<void> _saveProviderEnablement() async {
    final entries = _providerEnablement.entries
        .map((e) => '${e.key}:${e.value}')
        .toList();
    await _prefs.setStringList('providerEnablement', entries);
  }

  // Setters
  Future<void> setRefreshFrequency(RefreshFrequency value) async {
    _refreshFrequency = value;
    await _prefs.setString('refreshFrequency', value.name);
    notifyListeners();
  }

  Future<void> setLaunchAtLogin(bool value) async {
    _launchAtLogin = value;
    await _prefs.setBool('launchAtLogin', value);
    notifyListeners();
  }

  Future<void> setMergeIcons(bool value) async {
    _mergeIcons = value;
    await _prefs.setBool('mergeIcons', value);
    notifyListeners();
  }

  Future<void> setMenuBarDisplayMode(MenuBarDisplayMode value) async {
    _menuBarDisplayMode = value;
    await _prefs.setString('menuBarDisplayMode', value.name);
    notifyListeners();
  }

  Future<void> setProviderEnabled(UsageProvider provider, bool enabled) async {
    _providerEnablement[provider.name] = enabled;
    await _saveProviderEnablement();
    notifyListeners();
  }

  Future<void> setHidePersonalInfo(bool value) async {
    _hidePersonalInfo = value;
    await _prefs.setBool('hidePersonalInfo', value);
    notifyListeners();
  }

  Future<void> setStatusChecksEnabled(bool value) async {
    _statusChecksEnabled = value;
    await _prefs.setBool('statusChecksEnabled', value);
    notifyListeners();
  }

  Future<void> setSessionQuotaNotificationsEnabled(bool value) async {
    _sessionQuotaNotificationsEnabled = value;
    await _prefs.setBool('sessionQuotaNotificationsEnabled', value);
    notifyListeners();
  }

  Future<void> setConfettiOnSessionLimitResetsEnabled(bool value) async {
    _confettiOnSessionLimitResetsEnabled = value;
    await _prefs.setBool('confettiOnSessionLimitResetsEnabled', value);
    notifyListeners();
  }

  Future<void> setConfettiOnWeeklyLimitResetsEnabled(bool value) async {
    _confettiOnWeeklyLimitResetsEnabled = value;
    await _prefs.setBool('confettiOnWeeklyLimitResetsEnabled', value);
    notifyListeners();
  }

  Future<void> setRandomBlinkEnabled(bool value) async {
    _randomBlinkEnabled = value;
    await _prefs.setBool('randomBlinkEnabled', value);
    notifyListeners();
  }

  Future<void> setHideCritters(bool value) async {
    _hideCritters = value;
    await _prefs.setBool('menuBarHidesCritters', value);
    notifyListeners();
  }

  Future<void> setUsageBarsShowUsed(bool value) async {
    _usageBarsShowUsed = value;
    await _prefs.setBool('usageBarsShowUsed', value);
    notifyListeners();
  }

  Future<void> setResetTimesShowAbsolute(bool value) async {
    _resetTimesShowAbsolute = value;
    await _prefs.setBool('resetTimesShowAbsolute', value);
    notifyListeners();
  }

  Future<void> setMenuBarShowsHighestUsage(bool value) async {
    _menuBarShowsHighestUsage = value;
    await _prefs.setBool('menuBarShowsHighestUsage', value);
    notifyListeners();
  }

  Future<void> setMenuBarShowsResetTimeWhenExhausted(bool value) async {
    _menuBarShowsResetTimeWhenExhausted = value;
    await _prefs.setBool('menuBarShowsResetTimeWhenExhausted', value);
    notifyListeners();
  }

  Future<void> setDebugMenuEnabled(bool value) async {
    _debugMenuEnabled = value;
    await _prefs.setBool('debugMenuEnabled', value);
    notifyListeners();
  }

  Future<void> setRefreshAllProvidersOnMenuOpen(bool value) async {
    _refreshAllProvidersOnMenuOpen = value;
    await _prefs.setBool('refreshAllProvidersOnMenuOpen', value);
    notifyListeners();
  }

  Future<void> setQuotaWarningNotificationsEnabled(bool value) async {
    _quotaWarningNotificationsEnabled = value;
    await _prefs.setBool('quotaWarningNotificationsEnabled', value);
    notifyListeners();
  }
}

final settingsStoreProvider = ChangeNotifierProvider<SettingsStore>((ref) {
  final store = SettingsStore();
  store.initialize();
  return store;
});
