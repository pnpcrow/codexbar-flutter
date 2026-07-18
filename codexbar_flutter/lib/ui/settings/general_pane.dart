import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/settings_store.dart';

/// General settings pane.
/// Direct port of Swift PreferencesGeneralPane.
class GeneralPane extends ConsumerWidget {
  const GeneralPane({super.key});

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
        // Refresh Frequency
        _buildSection(context, 'Refresh', [
          _buildDropdown<RefreshFrequency>(
            context,
            label: 'Refresh Frequency',
            value: settings.refreshFrequency,
            items: RefreshFrequency.values,
            itemLabel: (f) => f.label,
            onChanged: (value) {
              settings.refreshFrequency = value;
            },
          ),
        ]),

        const SizedBox(height: 24),

        // System
        _buildSection(context, 'System', [
          _buildSwitch(
            context,
            label: 'Launch at Login',
            value: settings.launchAtLogin,
            onChanged: (value) {
              settings.launchAtLogin = value;
            },
          ),
        ]),

        const SizedBox(height: 24),

        // Menu Bar
        _buildSection(context, 'Menu Bar', [
          _buildSwitch(
            context,
            label: 'Show Menu Bar Icon',
            value: settings.showMenuBarIcon,
            onChanged: (value) {
              settings.showMenuBarIcon = value;
            },
          ),
          _buildSwitch(
            context,
            label: 'Show Usage Percentage',
            value: settings.showUsagePercentage,
            onChanged: (value) {
              settings.showUsagePercentage = value;
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
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdown<T>(
    BuildContext context, {
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        DropdownButton<T>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(itemLabel(item)),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
      ],
    );
  }
}
