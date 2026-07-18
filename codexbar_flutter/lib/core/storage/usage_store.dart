import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usage_provider.dart';
import '../models/usage_snapshot.dart';
import '../providers/fetch_strategy.dart';
import '../providers/provider_registry.dart';
import 'settings_store.dart';

final _log = Logger('UsageStore');

/// Usage store - manages usage data for all providers.
class UsageStore {
  final ProviderRegistry _registry;
  final SettingsStore _settings;
  final SharedPreferences _prefs;

  final Map<UsageProvider, UsageSnapshot?> _snapshots = {};
  final Map<UsageProvider, String?> _errors = {};
  final Map<UsageProvider, DateTime?> _lastFetchTimes = {};
  final Map<UsageProvider, DateTime?> _lastSuccessTimes = {};

  final _updateController = StreamController<UsageProvider>.broadcast();

  Timer? _refreshTimer;
  bool _isRefreshing = false;

  UsageStore({
    required ProviderRegistry registry,
    required SettingsStore settings,
    required SharedPreferences prefs,
  })  : _registry = registry,
        _settings = settings,
        _prefs = prefs;

  /// Stream that fires when any provider's data changes.
  Stream<UsageProvider> get onUpdate => _updateController.stream;

  /// Get current snapshot for a provider.
  UsageSnapshot? snapshot(UsageProvider provider) => _snapshots[provider];

  /// Get current error for a provider.
  String? error(UsageProvider provider) => _errors[provider];

  /// Get last fetch time for a provider.
  DateTime? lastFetchTime(UsageProvider provider) => _lastFetchTimes[provider];

  /// Get last success time for a provider.
  DateTime? lastSuccessTime(UsageProvider provider) => _lastSuccessTimes[provider];

  /// Check if currently refreshing.
  bool get isRefreshing => _isRefreshing;

  /// Initialize the store.
  Future<void> initialize() async {
    _loadCachedSnapshots();
    _startRefreshTimer();
  }

  /// Load cached snapshots from SharedPreferences.
  void _loadCachedSnapshots() {
    for (final provider in UsageProvider.values) {
      final cached = _prefs.getString('usage_${provider.name}');
      if (cached != null) {
        try {
          final json = jsonDecode(cached) as Map<String, dynamic>;
          _snapshots[provider] = UsageSnapshot.fromJson(json);
        } catch (e) {
          _log.warning('Failed to load cached snapshot for ${provider.name}: $e');
        }
      }
    }
  }

  /// Save snapshot to cache.
  void _cacheSnapshot(UsageProvider provider, UsageSnapshot snapshot) {
    try {
      final json = jsonEncode(snapshot.toJson());
      _prefs.setString('usage_${provider.name}', json);
    } catch (e) {
      _log.warning('Failed to cache snapshot for ${provider.name}: $e');
    }
  }

  /// Start the refresh timer based on settings.
  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    final frequency = _settings.refreshFrequency;
    final duration = frequency.duration;
    if (duration == null) return;

    _refreshTimer = Timer.periodic(duration, (_) {
      refreshAll();
    });
  }

  /// Refresh all enabled providers.
  Future<void> refreshAll() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      final enabled = _settings.enabledProviders;
      final futures = enabled.map((p) => refreshProvider(p));
      await Future.wait(futures, eagerError: false);
    } finally {
      _isRefreshing = false;
    }
  }

  /// Refresh a single provider.
  Future<void> refreshProvider(UsageProvider provider) async {
    final descriptor = _registry.descriptorFor(provider);
    if (descriptor == null) {
      _log.warning('No descriptor for ${provider.name}');
      return;
    }

    _lastFetchTimes[provider] = DateTime.now();

    try {
      final context = ProviderFetchContext(
        sourceMode: _resolveSourceMode(provider),
        includeCredits: true,
        env: Map<String, String>.from(Platform.environment),
      );
      final outcome = await descriptor.fetchOutcome(context);

      if (outcome.isSuccess) {
        final result = outcome.result!;
        _snapshots[provider] = result.usage;
        _errors[provider] = null;
        _lastSuccessTimes[provider] = DateTime.now();
        _cacheSnapshot(provider, result.usage);
        _updateController.add(provider);
      } else {
        _errors[provider] = outcome.error.toString();
        _updateController.add(provider);
      }
    } catch (e) {
      _errors[provider] = e.toString();
      _updateController.add(provider);
      _log.severe('Failed to refresh ${provider.name}: $e');
    }
  }

  /// Resolve source mode for a provider from settings.
  ProviderSourceMode _resolveSourceMode(UsageProvider provider) {
    final mode = _settings.providerSourceMode(provider);
    if (mode == null) return ProviderSourceMode.auto;
    return ProviderSourceMode.values.byName(mode);
  }

  /// Dispose resources.
  void dispose() {
    _refreshTimer?.cancel();
    _updateController.close();
  }
}
