import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/settings_state.dart';
import 'settings_view.dart';

/// Notifications settings: change detection (the user's core request),
/// threshold warnings, and sound. Mirrors `PreferencesNotificationsPane`.
class NotificationsPane extends ConsumerWidget {
  const NotificationsPane({super.key, required this.state});

  final SettingsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Notify when usage changes'),
          subtitle: const Text(
            'Post a system notification when the usage percent differs from the previous refresh.',
          ),
          value: state.changeDetectionNotificationsEnabled,
          onChanged: (v) => ref.mutateSettings(
            (s) => s.copyWith(changeDetectionNotificationsEnabled: v),
          ),
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('Threshold warnings'),
          subtitle: const Text('Notify when usage crosses a configured percent.'),
          value: state.thresholdNotificationsEnabled,
          onChanged: (v) => ref.mutateSettings(
            (s) => s.copyWith(thresholdNotificationsEnabled: v),
          ),
        ),
        if (state.thresholdNotificationsEnabled) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ThresholdField(
                  label: 'Warning %',
                  value: state.thresholds.sessionWarningPercent,
                  onChanged: (v) => ref.mutateSettings(
                    (s) => s.copyWith(
                      thresholds: s.thresholds.copyWith(sessionWarningPercent: v),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ThresholdField(
                  label: 'Critical %',
                  value: state.thresholds.sessionCriticalPercent,
                  onChanged: (v) => ref.mutateSettings(
                    (s) => s.copyWith(
                      thresholds: s.thresholds.copyWith(sessionCriticalPercent: v),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        const Divider(),
        SwitchListTile(
          title: const Text('Play sound'),
          value: state.notificationSoundEnabled,
          onChanged: (v) =>
              ref.mutateSettings((s) => s.copyWith(notificationSoundEnabled: v)),
        ),
      ],
    );
  }
}

class _ThresholdField extends StatelessWidget {
  const _ThresholdField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 50,
            max: 100,
            divisions: 50,
            label: '$value%',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(width: 40, child: Text('$value%')),
      ],
    );
  }
}
