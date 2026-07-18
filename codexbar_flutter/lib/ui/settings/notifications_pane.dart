import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/settings_store.dart';

/// Notifications settings pane.
/// Direct port of Swift PreferencesNotificationsPane.
class NotificationsPane extends ConsumerWidget {
  const NotificationsPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsStoreProvider);

    return settingsAsync.when(
      data: (settings) => _buildContent(context, settings),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildContent(BuildContext context, SettingsStore settings) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // General
        _buildSection(context, 'General', [
          _buildSwitch(
            context,
            label: 'Enable Notifications',
            value: settings.notificationsEnabled,
            onChanged: (value) {
              settings.notificationsEnabled = value;
            },
          ),
        ]),

        const SizedBox(height: 24),

        // Usage Notifications
        _buildSection(context, 'Usage Notifications', [
          _buildSwitch(
            context,
            label: 'Notify on Usage Change',
            subtitle: 'Get notified when provider usage changes',
            value: settings.notifyOnUsageChange,
            onChanged: (value) {
              settings.notifyOnUsageChange = value;
            },
          ),
          _buildSwitch(
            context,
            label: 'Notify on Limit Reset',
            subtitle: 'Get notified when session/weekly limits reset',
            value: settings.notifyOnLimitReset,
            onChanged: (value) {
              settings.notifyOnLimitReset = value;
            },
          ),
        ]),

        const SizedBox(height: 24),

        // Visual Effects
        _buildSection(context, 'Visual Effects', [
          _buildSwitch(
            context,
            label: 'Confetti on Session Reset',
            subtitle: 'Show confetti when session limits reset',
            value: settings.confettiOnSessionLimitResets,
            onChanged: (value) {
              settings.confettiOnSessionLimitResets = value;
            },
          ),
          _buildSwitch(
            context,
            label: 'Confetti on Weekly Reset',
            subtitle: 'Show confetti when weekly limits reset',
            value: settings.confettiOnWeeklyLimitResets,
            onChanged: (value) {
              settings.confettiOnWeeklyLimitResets = value;
            },
          ),
        ]),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildSwitch(
    BuildContext context, {
    required String label,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
