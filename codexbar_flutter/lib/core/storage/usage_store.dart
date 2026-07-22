import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../debug/debug_logger.dart';
import '../models/usage_provider.dart';
import '../models/usage_snapshot.dart';
import '../providers/fetch_strategy.dart';
import '../providers/provider_registry.dart';
import 'settings_store.dart';

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
          DebugLogger.error('UsageStore', 'Failed to load cached snapshot for ${provider.name}', e);
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
      DebugLogger.error('UsageStore', 'Failed to cache snapshot for ${provider.name}', e);
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
      DebugLogger.error('UsageStore', 'No descriptor for ${provider.name}');
      return;
    }

    DebugLogger.log('UsageStore', 'Refreshing ${provider.displayName}...');
    _lastFetchTimes[provider] = DateTime.now();

    try {
      final env = Map<String, String>.from(Platform.environment);

      // Inject saved API key from settings into env
      final savedKey = _settings.providerAPIKey(provider);
      if (savedKey != null && savedKey.isNotEmpty) {
        _injectApiKey(env, provider, savedKey);
        DebugLogger.log('UsageStore', '  Injected saved API key for ${provider.name}');
      }

      // Inject saved cookie from settings into env
      final savedCookie = _settings.providerManualCookieHeader(provider);
      if (savedCookie != null && savedCookie.isNotEmpty) {
        env['${provider.name.toUpperCase()}_COOKIE'] = savedCookie;
        DebugLogger.log('UsageStore', '  Injected saved cookie for ${provider.name}');
      }

      final context = ProviderFetchContext(
        sourceMode: _resolveSourceMode(provider),
        includeCredits: true,
        env: env,
      );
      DebugLogger.log('UsageStore', '  Source mode: ${context.sourceMode}');

      final outcome = await descriptor.fetchOutcome(context);

      if (outcome.isSuccess) {
        final result = outcome.result!;
        _snapshots[provider] = result.usage;
        _errors[provider] = null;
        _lastSuccessTimes[provider] = DateTime.now();
        _cacheSnapshot(provider, result.usage);
        _updateController.add(provider);

        DebugLogger.log('UsageStore', '  ${provider.displayName} SUCCESS (${result.sourceLabel})');
        if (result.usage.primary != null) {
          DebugLogger.log('UsageStore', '    Session: ${result.usage.primary!.usedPercent.toStringAsFixed(1)}%');
        }
        if (result.usage.secondary != null) {
          DebugLogger.log('UsageStore', '    Weekly: ${result.usage.secondary!.usedPercent.toStringAsFixed(1)}%');
        }
        if (result.usage.identity?.accountEmail != null) {
          DebugLogger.log('UsageStore', '    Email: ${result.usage.identity!.accountEmail}');
        }
      } else {
        _errors[provider] = outcome.error.toString();
        _updateController.add(provider);
        DebugLogger.error('UsageStore', '${provider.displayName} FAILED: ${outcome.error}');
      }
    } catch (e) {
      _errors[provider] = e.toString();
      _updateController.add(provider);
      DebugLogger.error('UsageStore', '${provider.displayName} EXCEPTION', e);
    }
  }

  /// Resolve source mode for a provider from settings.
  ProviderSourceMode _resolveSourceMode(UsageProvider provider) {
    final mode = _settings.providerSourceMode(provider);
    if (mode == null) return ProviderSourceMode.auto;
    return ProviderSourceMode.values.byName(mode);
  }

  /// Inject API key into environment map with correct env var name.
  void _injectApiKey(Map<String, String> env, UsageProvider provider, String key) {
    switch (provider) {
      case UsageProvider.zai:
        env['Z_AI_API_KEY'] = key;
        break;
      case UsageProvider.minimax:
        env['MINIMAX_API_TOKEN'] = key;
        break;
      case UsageProvider.claude:
        env['ANTHROPIC_API_KEY'] = key;
        break;
      case UsageProvider.openai:
        env['OPENAI_API_KEY'] = key;
        break;
      case UsageProvider.deepseek:
        env['DEEPSEEK_API_KEY'] = key;
        break;
      case UsageProvider.moonshot:
        env['MOONSHOT_API_KEY'] = key;
        break;
      case UsageProvider.kimi:
        env['KIMI_AUTH_TOKEN'] = key;
        break;
      case UsageProvider.kimik2:
        env['KIMI_K2_API_KEY'] = key;
        break;
      case UsageProvider.copilot:
        env['COPILOT_API_TOKEN'] = key;
        break;
      case UsageProvider.openrouter:
        env['OPENROUTER_API_KEY'] = key;
        break;
      case UsageProvider.elevenlabs:
        env['ELEVENLABS_API_KEY'] = key;
        break;
      case UsageProvider.groq:
        env['GROQ_API_KEY'] = key;
        break;
      case UsageProvider.warp:
        env['WARP_API_KEY'] = key;
        break;
      case UsageProvider.venice:
        env['VENICE_API_KEY'] = key;
        break;
      case UsageProvider.poe:
        env['POE_API_KEY'] = key;
        break;
      case UsageProvider.stepfun:
        env['STEPFUN_TOKEN'] = key;
        break;
      case UsageProvider.doubao:
        env['DOUBAO_API_KEY'] = key;
        break;
      case UsageProvider.amp:
        env['AMP_API_TOKEN'] = key;
        break;
      case UsageProvider.alibaba:
        env['ALIBABA_API_TOKEN'] = key;
        break;
      case UsageProvider.deepgram:
        env['DEEPGRAM_API_KEY'] = key;
        break;
      case UsageProvider.perplexity:
        env['PERPLEXITY_SESSION_TOKEN'] = key;
        break;
      default:
        env['${provider.name.toUpperCase()}_API_KEY'] = key;
        env['${provider.name.toUpperCase()}_API_TOKEN'] = key;
    }
  }

  /// Dispose resources.
  void dispose() {
    _refreshTimer?.cancel();
    _updateController.close();
  }
}
