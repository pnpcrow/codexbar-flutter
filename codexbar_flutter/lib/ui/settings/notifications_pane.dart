import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/storage/settings_store.dart';

/// Notifications settings pane.
class NotificationsPane extends ConsumerStatefulWidget {
  const NotificationsPane({super.key});

  @override
  ConsumerState<NotificationsPane> createState() => _NotificationsPaneState();
}

class _NotificationsPaneState extends ConsumerState<NotificationsPane> {
  @override
  Widget build(BuildContext context) {
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
        _buildSection(context, 'General', [
          _buildSwitch(
            context,
            label: 'Enable Notifications',
            value: settings.notificationsEnabled,
            onChanged: (value) {
              setState(() => settings.notificationsEnabled = value);
            },
          ),
        ]),
        const SizedBox(height: 24),
        _buildSection(context, 'Usage Notifications', [
          _buildSwitch(
            context,
            label: 'Notify on Usage Change',
            subtitle: 'Get notified when provider usage changes',
            value: settings.notifyOnUsageChange,
            onChanged: (value) {
              setState(() => settings.notifyOnUsageChange = value);
            },
          ),
          _buildSwitch(
            context,
            label: 'Notify on Limit Reset',
            subtitle: 'Get notified when session/weekly limits reset',
            value: settings.notifyOnLimitReset,
            onChanged: (value) {
              setState(() => settings.notifyOnLimitReset = value);
            },
          ),
        ]),
        const SizedBox(height: 24),
        _buildSection(context, 'Visual Effects', [
          _buildSwitch(
            context,
            label: 'Confetti on Session Reset',
            value: settings.confettiOnSessionLimitResets,
            onChanged: (value) {
              setState(() => settings.confettiOnSessionLimitResets = value);
            },
          ),
          _buildSwitch(
            context,
            label: 'Confetti on Weekly Reset',
            value: settings.confettiOnWeeklyLimitResets,
            onChanged: (value) {
              setState(() => settings.confettiOnWeeklyLimitResets = value);
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
                fontWeight: FontWeight.w600,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
