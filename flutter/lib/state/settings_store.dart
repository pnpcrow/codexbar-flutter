import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/usage_provider.dart';
import '../core/notifications/app_notifications.dart';
import '../core/storage/secure_storage.dart';
import '../core/storage/settings_state.dart';
import '../core/storage/settings_store_io.dart';

/// Async-loading settings notifier backed by [SettingsStoreIO].
class SettingsStore extends AsyncNotifier<SettingsState> {
  final SettingsStoreIO _io = SettingsStoreIO();
  SettingsState? _cached;

  @override
  Future<SettingsState> build() async {
    final loaded = await _io.load();
    _cached = loaded;
    return loaded;
  }

  /// Update a slice of the settings state and persist.
  Future<void> mutate(SettingsState Function(SettingsState) updater) async {
    final current = _cached ?? state.value ?? const SettingsState();
    final next = updater(current);
    _cached = next;
    state = AsyncData(next);
    await _io.save(next);
  }

  Future<void> toggleProviderEnabled(UsageProvider provider, bool enabled) async {
    await mutate((s) {
      final set = Set<UsageProvider>.of(s.enabledProviders);
      if (enabled) {
        set.add(provider);
      } else {
        set.remove(provider);
      }
      return s.copyWith(enabledProviders: set);
    });
  }
}

final settingsStoreProvider =
    AsyncNotifierProvider<SettingsStore, SettingsState>(SettingsStore.new);

/// Credentials store (API keys) — synchronous once initialized.
final credentialStoreProvider = Provider<ProviderCredentialStore>((ref) {
  return ProviderCredentialStore();
});

/// Notifications plugin singleton.
final appNotificationsProvider = Provider<AppNotifications>((ref) {
  return AppNotifications();
});
