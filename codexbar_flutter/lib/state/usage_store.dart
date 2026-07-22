import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/models/usage_snapshot.dart';
import '../core/models/credits_models.dart';
import '../core/providers/shared/provider_registry.dart';
import '../core/providers/shared/provider_implementation.dart';
import 'settings_store.dart';

class ProviderState {
  final UsageSnapshot? snapshot;
  final CreditsSnapshot? credits;
  final String? error;
  final bool isRefreshing;
  final DateTime? lastRefreshAt;

  const ProviderState({
    this.snapshot,
    this.credits,
    this.error,
    this.isRefreshing = false,
    this.lastRefreshAt,
  });

  ProviderState copyWith({
    UsageSnapshot? snapshot,
    CreditsSnapshot? credits,
    String? error,
    bool? isRefreshing,
    DateTime? lastRefreshAt,
  }) {
    return ProviderState(
      snapshot: snapshot ?? this.snapshot,
      credits: credits ?? this.credits,
      error: error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      lastRefreshAt: lastRefreshAt ?? this.lastRefreshAt,
    );
  }
}

class UsageStore extends ChangeNotifier {
  final SettingsStore _settings;
  final Map<UsageProvider, ProviderState> _states = {};
  Timer? _refreshTimer;

  UsageStore(this._settings);

  ProviderState getState(UsageProvider provider) {
    return _states[provider] ?? const ProviderState();
  }

  void initialize() {
    _settings.addListener(_onSettingsChanged);
    _scheduleRefresh();
    refreshAll();
  }

  void _onSettingsChanged() {
    _scheduleRefresh();
  }

  void _scheduleRefresh() {
    _refreshTimer?.cancel();
    final seconds = _settings.refreshFrequency.seconds;
    if (seconds == null) return;
    _refreshTimer = Timer.periodic(
      Duration(seconds: seconds),
      (_) => refreshAll(),
    );
  }

  Future<void> refreshAll() async {
    final enabledProviders = UsageProvider.values
        .where((p) => _settings.isProviderEnabled(p))
        .toList();

    // Refresh in parallel with limit
    final futures = enabledProviders.map((p) => _refreshProvider(p));
    await Future.wait(futures, eagerError: false);
  }

  Future<void> refreshProvider(UsageProvider provider) async {
    await _refreshProvider(provider);
  }

  Future<void> _refreshProvider(UsageProvider provider) async {
    _states[provider] = getState(provider).copyWith(isRefreshing: true);
    notifyListeners();

    try {
      final descriptor = ProviderDescriptorRegistry.descriptorFor(provider);
      final implementation = descriptor.implementation;

      if (implementation != null) {
        final context = ProviderFetchContext();
        final snapshot = await implementation.fetchUsage(context);

        if (snapshot != null) {
          _states[provider] = ProviderState(
            snapshot: snapshot,
            isRefreshing: false,
            lastRefreshAt: DateTime.now(),
          );
        } else {
          _states[provider] = getState(provider).copyWith(
            isRefreshing: false,
            error: 'No data available',
          );
        }
      } else {
        _states[provider] = getState(provider).copyWith(
          isRefreshing: false,
          error: 'Provider not implemented',
        );
      }
    } catch (e) {
      _states[provider] = getState(provider).copyWith(
        isRefreshing: false,
        error: e.toString(),
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }
}

final usageStoreProvider = ChangeNotifierProvider<UsageStore>((ref) {
  final settings = ref.watch(settingsStoreProvider);
  final store = UsageStore(settings);
  store.initialize();
  return store;
});
