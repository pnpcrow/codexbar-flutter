import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/usage_provider.dart';

/// Stores provider credentials (API keys / tokens) securely.
///
/// Replaces the Swift per-provider keychain stores (`CopilotTokenStore`,
/// `KimiTokenStore`, …) with a single `flutter_secure_storage`-backed store.
/// On Linux this uses libsecret/Keyring, on macOS the Keychain, on Windows DPAPI.
class ProviderCredentialStore {
  ProviderCredentialStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              
            );

  final FlutterSecureStorage _storage;

  static const _keyPrefix = 'provider_credential_';

  /// Read the stored API key for [provider], or `null` if none.
  Future<String?> apiKey(UsageProvider provider) async {
    return _storage.read(key: _keyPrefix + provider.name);
  }

  /// Store (or replace) the API key for [provider].
  Future<void> setApiKey(UsageProvider provider, String? apiKey) async {
    final key = _keyPrefix + provider.name;
    if (apiKey == null || apiKey.isEmpty) {
      await _storage.delete(key: key);
    } else {
      await _storage.write(key: key, value: apiKey);
    }
  }

  /// Optional scope (e.g. OpenAI project ID) stored alongside the key.
  Future<String?> scope(UsageProvider provider) async {
    return _storage.read(key: _keyPrefix + provider.name + '_scope');
  }

  Future<void> setScope(UsageProvider provider, String? scope) async {
    final key = _keyPrefix + provider.name + '_scope';
    if (scope == null || scope.isEmpty) {
      await _storage.delete(key: key);
    } else {
      await _storage.write(key: key, value: scope);
    }
  }

  /// Detect which providers have credentials, mirroring Swift's
  /// `runInitialProviderDetectionIfNeeded`. Returns the set of providers that
  /// have an API key stored.
  Future<Set<UsageProvider>> detectConfiguredProviders() async {
    final entries = await _storage.readAll();
    final configured = <UsageProvider>{};
    for (final entry in entries.entries) {
      if (!entry.key.startsWith(_keyPrefix)) continue;
      if (entry.key.endsWith('_scope')) continue;
      final name = entry.key.substring(_keyPrefix.length);
      final provider = UsageProvider.fromString(name);
      if (provider != null && entry.value.isNotEmpty) {
        configured.add(provider);
      }
    }
    return configured;
  }
}
