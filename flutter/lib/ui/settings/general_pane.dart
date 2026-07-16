import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/settings_state.dart';
import 'settings_view.dart';

/// General settings: refresh frequency, menu-open refresh, launch at login.
class GeneralPane extends ConsumerWidget {
  const GeneralPane({super.key, required this.state});

  final SettingsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('General', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        DropdownButtonFormField<RefreshFrequency>(
          decoration: const InputDecoration(
            labelText: 'Refresh frequency',
            border: OutlineInputBorder(),
          ),
          value: state.refreshFrequency,
          items: [
            for (final f in RefreshFrequency.values)
              DropdownMenuItem(value: f, child: Text(f.displayName)),
          ],
          onChanged: (f) {
            if (f != null) ref.mutateSettings((s) => s.copyWith(refreshFrequency: f));
          },
        ),
        SwitchListTile(
          title: const Text('Refresh all providers when menu opens'),
          value: state.refreshAllProvidersOnMenuOpen,
          onChanged: (v) =>
              ref.mutateSettings((s) => s.copyWith(refreshAllProvidersOnMenuOpen: v)),
        ),
        SwitchListTile(
          title: const Text('Launch at login'),
          subtitle: const Text('Platform integration is a follow-up.'),
          value: state.launchAtLogin,
          onChanged: (v) => ref.mutateSettings((s) => s.copyWith(launchAtLogin: v)),
        ),
      ],
    );
  }
}
