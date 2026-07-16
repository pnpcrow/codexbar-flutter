import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/usage_provider.dart';
import '../core/models/usage_snapshot.dart';
import '../core/notifications/app_notifications.dart';
import '../core/notifications/usage_change_detector.dart';
import '../core/providers/provider_descriptor_registry.dart';
import '../core/providers/provider_fetch_strategy.dart';
import '../core/refresh/adaptive_refresh_policy.dart';
import '../core/storage/secure_storage.dart';
import '../core/storage/settings_state.dart';
import 'default_providers.dart';
import 'settings_store.dart';

/// Per-provider runtime state surfaced to the UI.
@immutable
class ProviderRuntimeState {
  const ProviderRuntimeState({
    this.snapshot,
    this.error,
    this.refreshing = false,
    this.lastUpdated,
  });

  final UsageSnapshot? snapshot;
  final String? error;
  final bool refreshing;
  final DateTime? lastUpdated;

  /// Whether this provider has no data and no recent error (initial state).
  bool get isStale => snapshot == null && error == null;

  ProviderRuntimeState copyWith({
    UsageSnapshot? snapshot,
    String? error,
    bool? refreshing,
    DateTime? lastUpdated,
    bool clearError = false,
    bool clearSnapshot = false,
  }) {
    return ProviderRuntimeState(
      snapshot: clearSnapshot ? null : (snapshot ?? this.snapshot),
      error: clearError ? null : (error ?? this.error),
      refreshing: refreshing ?? this.refreshing,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// The central runtime store: snapshots, errors, refresh flags, and the
/// refresh timer. Mirrors `Sources/CodexBar/UsageStore.swift` at a reduced
/// scope (per-provider generation-guarded fetch + adaptive cadence + change
/// detection + prior-snapshot preservation on transient errors).
class UsageStore extends Notifier<Map<UsageProvider, ProviderRuntimeState>> {
  UsageStore();

  Timer? _timer;
  DateTime? _lastMenuOpenAt;
  final _changeDetector = UsageChangeDetector();
  final _inFlight = <UsageProvider, Future<void>>{};
  ProviderDescriptorRegistry? _registry;
  ProviderCredentialStore? _credentials;
  AppNotifications? _notifications;
  SettingsState? _settings;
  final _policy = const AdaptiveRefreshPolicyCore();

  @override
  Map<UsageProvider, ProviderRuntimeState> build() {
    // Wire settings + registry once available; refresh loop starts on demand.
    Future.microtask(() => _bootstrap());
    ref.onDispose(() {
      _timer?.cancel();
    });
    return {};
  }

  void _bootstrap() {
    _settings = ref.read(settingsStoreProvider).value;
    _credentials = ref.read(credentialStoreProvider);
    _notifications = ref.read(appNotificationsProvider);
    _registry = ref.read(providerRegistryProvider);
    // Seed runtime entries for every enabled, implemented provider so cards
    // appear immediately (before any fetch completes). Mirrors how the Swift
    // app pre-populates provider rows on launch.
    _seedEnabledProviders();
    // Start the refresh loop now that settings are available.
    _scheduleNext();
  }

  void _seedEnabledProviders() {
    final registry = _registry;
    final settings = _settings;
    if (registry == null || settings == null) return;
    final implemented = registry.implemented.map((r) => r.descriptor.id).toSet();
    final enabled = settings.enabledProviders.isEmpty
        ? const <UsageProvider>{}
        : settings.enabledProviders;
    final targets = enabled.isEmpty ? const <UsageProvider>[] : enabled.where(implemented.contains).toList();
    if (targets.isEmpty) return;
    final next = Map<UsageProvider, ProviderRuntimeState>.from(state);
    for (final p in targets) {
      next.putIfAbsent(p, () => const ProviderRuntimeState());
    }
    state = next;
  }

  /// Seed a runtime entry for [provider] if it has none (so its card appears
  /// immediately when enabled from settings), then kick off a refresh.
  void ensureProvider(UsageProvider provider) {
    if (!state.containsKey(provider)) {
      final next = Map<UsageProvider, ProviderRuntimeState>.from(state);
      next[provider] = const ProviderRuntimeState();
      state = next;
    }
    refreshProvider(provider);
  }

  /// Drop a provider from the runtime state (when disabled in settings).
  void removeProvider(UsageProvider provider) {
    if (state.containsKey(provider)) {
      final next = Map<UsageProvider, ProviderRuntimeState>.from(state);
      next.remove(provider);
      state = next;
    }
    _changeDetector.reset(provider);
  }

  /// Called by the tray/menu layer when the menu opens. Records the timestamp
  /// for the adaptive policy and triggers an opt-in refresh.
  void noteMenuOpened() {
    _lastMenuOpenAt = DateTime.now();
    if (_settings?.refreshAllProvidersOnMenuOpen ?? false) {
      refreshAll();
    }
  }

  /// Refresh every enabled, implemented provider.
  Future<void> refreshAll() async {
    final registry = _registry;
    if (registry == null) return;
    final settings = ref.read(settingsStoreProvider).value ?? const SettingsState();
    final enabled = settings.enabledProviders.isEmpty
        ? <UsageProvider>{}
        : settings.enabledProviders;
    final targets = registry.implemented
        .map((r) => r.descriptor.id)
        .where((p) => enabled.isEmpty || enabled.contains(p))
        .toList();
    await Future.wait(targets.map(refreshProvider));
  }

  /// Refresh a single provider, guarding against re-entry and preserving the
  /// prior snapshot on transient network errors.
  Future<void> refreshProvider(UsageProvider provider) async {
    if (_inFlight.containsKey(provider)) return _inFlight[provider]!;
    final registry = _registry;
    final credentials = _credentials;
    if (registry == null || credentials == null) return;

    final completer = Completer<void>();
    _inFlight[provider] = completer.future;

    _setProvider(provider, (s) => s.copyWith(refreshing: true));

    try {
      final apiKey = await credentials.apiKey(provider);
      final scope = await credentials.scope(provider);
      final context = ProviderFetchContext(
        provider: provider,
        apiKey: apiKey,
        projectID: scope,
      );
      final pipeline = registry.pipelineFor(provider);
      final attempt = await pipeline.fetch(context);
      if (attempt is ProviderFetchSuccess) {
        final snapshot = UsageSnapshot.fromJson(attempt.snapshotJson);
        _setProvider(provider, (s) => s.copyWith(
              snapshot: snapshot,
              clearError: true,
              refreshing: false,
              lastUpdated: DateTime.now(),
            ));
        _emitNotifications(provider, snapshot);
      } else if (attempt is ProviderFetchFailure) {
        // Preserve prior snapshot on transient network errors.
        final isTransient = attempt.error is NetworkError;
        _setProvider(provider, (s) => s.copyWith(
              error: attempt.error.message,
              clearSnapshot: !isTransient,
              refreshing: false,
              lastUpdated: DateTime.now(),
            ));
      }
    } on Object catch (e) {
      _setProvider(provider, (s) => s.copyWith(
            error: e.toString(),
            refreshing: false,
            lastUpdated: DateTime.now(),
          ));
    } finally {
      _inFlight.remove(provider);
      completer.complete();
    }
  }

  void _emitNotifications(UsageProvider provider, UsageSnapshot snapshot) {
    final settings = ref.read(settingsStoreProvider).value ?? const SettingsState();
    final notifications = _changeDetector.process(
      provider: provider,
      newSnapshot: snapshot,
      settings: settings,
    );
    final notifier = _notifications;
    if (notifier == null) return;
    final sound = settings.notificationSoundEnabled;
    for (final n in notifications) {
      // Fire-and-forget; errors are swallowed by the notifier.
      unawaited(notifier.post(n, soundEnabled: sound));
    }
  }

  void _setProvider(
    UsageProvider provider,
    ProviderRuntimeState Function(ProviderRuntimeState) updater,
  ) {
    final current = Map<UsageProvider, ProviderRuntimeState>.from(state);
    final prior = current[provider] ?? const ProviderRuntimeState();
    current[provider] = updater(prior);
    state = current;
  }

  void _scheduleNext() {
    _timer?.cancel();
    final settings = ref.read(settingsStoreProvider).value ?? const SettingsState();
    final freq = settings.refreshFrequency;
    if (freq == RefreshFrequency.manual) return;

    final Duration delay;
    if (freq == RefreshFrequency.adaptive) {
      delay = _policy.nextDelay(AdaptiveRefreshInput(
        now: DateTime.now(),
        lastMenuOpenAt: _lastMenuOpenAt,
        lowPowerModeEnabled: false, // Linux power/thermal not yet wired.
        thermalPressure: ThermalPressure.nominal,
      )).delay;
    } else {
      delay = Duration(minutes: freq.fixedMinutes ?? 5);
    }
    _timer = Timer(delay, () {
      unawaited(refreshAll());
      _scheduleNext();
    });
  }

  /// Restart the refresh loop after settings change (call from settings store).
  void restartTimer() => _scheduleNext();
}

final usageStoreProvider =
    NotifierProvider<UsageStore, Map<UsageProvider, ProviderRuntimeState>>(
        UsageStore.new);
