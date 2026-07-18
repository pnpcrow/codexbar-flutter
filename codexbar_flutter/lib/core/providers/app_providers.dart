import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usage_provider.dart';
import '../models/usage_snapshot.dart';
import '../storage/settings_store.dart';
import '../storage/usage_store.dart';
import 'provider_registry.dart';

/// Reactive enabled providers — single source of truth.
final enabledProvidersProvider = FutureProvider<Set<UsageProvider>>((ref) async {
  final settings = await ref.watch(settingsStoreProvider.future);
  return settings.enabledProviders;
});

/// Provider registry.
final providerRegistryProvider = Provider<ProviderRegistry>((ref) {
  return ProviderRegistry();
});

/// Settings store.
final settingsStoreProvider = FutureProvider<SettingsStore>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return SettingsStore(prefs);
});

/// Usage store.
final usageStoreProvider = FutureProvider<UsageStore>((ref) async {
  final registry = ref.watch(providerRegistryProvider);
  final settings = await ref.watch(settingsStoreProvider.future);
  final prefs = await SharedPreferences.getInstance();

  final store = UsageStore(
    registry: registry,
    settings: settings,
    prefs: prefs,
  );
  await store.initialize();
  // Trigger initial refresh
  await store.refreshAll();

  ref.onDispose(() => store.dispose());
  return store;
});

/// Snapshot for a single provider — reactive.
final providerSnapshotProvider = Provider.family<UsageSnapshot?, UsageProvider>((ref, provider) {
  final storeAsync = ref.watch(usageStoreProvider);
  return storeAsync.whenOrNull(data: (store) => store.snapshot(provider));
});

/// Error for a single provider — reactive.
final providerErrorProvider = Provider.family<String?, UsageProvider>((ref, provider) {
  final storeAsync = ref.watch(usageStoreProvider);
  return storeAsync.whenOrNull(data: (store) => store.error(provider));
});

/// Environment variables provider.
final environmentProvider = Provider<Map<String, String>>((ref) {
  return Map<String, String>.from(Platform.environment);
});
