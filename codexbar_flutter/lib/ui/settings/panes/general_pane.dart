import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/settings_store.dart';

class GeneralPane extends ConsumerWidget {
  const GeneralPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsStoreProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n.tabGeneral, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 24),
        _buildSectionHeader(context, l10n.sectionSystem),
        SwitchListTile(
          title: Text(l10n.startAtLogin),
          subtitle: const Text('Launch CodexBar when you log in'),
          value: settings.launchAtLogin,
          onChanged: (v) => settings.setLaunchAtLogin(v),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(context, l10n.sectionRefreshing),
        ListTile(
          title: Text(l10n.refreshInterval),
          subtitle: Text(settings.refreshFrequency.label),
          trailing: DropdownButton<RefreshFrequency>(
            value: settings.refreshFrequency,
            onChanged: (v) { if (v != null) settings.setRefreshFrequency(v); },
            items: RefreshFrequency.values.map((f) => DropdownMenuItem(value: f, child: Text(f.label))).toList(),
          ),
        ),
        SwitchListTile(
          title: Text(l10n.refreshOnOpen),
          subtitle: const Text('Refresh all providers when opening the menu'),
          value: settings.refreshAllProvidersOnMenuOpen,
          onChanged: (v) => settings.setRefreshAllProvidersOnMenuOpen(v),
        ),
        SwitchListTile(
          title: Text(l10n.checkProviderStatus),
          subtitle: const Text('Poll provider status pages for incidents'),
          value: settings.statusChecksEnabled,
          onChanged: (v) => settings.setStatusChecksEnabled(v),
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: () => _showQuitDialog(context, l10n),
            icon: const Icon(Icons.exit_to_app),
            label: Text(l10n.quitApp),
            style: ElevatedButton.styleFrom(foregroundColor: theme.colorScheme.error),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600,
      )),
    );
  }

  void _showQuitDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text(l10n.quitApp),
      content: const Text('Are you sure you want to quit CodexBar?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        TextButton(onPressed: () { Navigator.pop(context); exit(0); }, child: Text(l10n.quit)),
      ],
    ));
  }
}
