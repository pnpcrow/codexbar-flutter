import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/settings_store.dart';

class AdvancedPane extends ConsumerWidget {
  const AdvancedPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsStoreProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n.tabAdvanced, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        SwitchListTile(
          title: Text(l10n.hidePersonalInfo),
          subtitle: const Text('Redact emails and account details in the UI'),
          value: settings.hidePersonalInfo,
          onChanged: (v) => settings.setHidePersonalInfo(v),
        ),
        const Divider(),
        ListTile(
          title: Text(l10n.configFile),
          subtitle: const Text('~/.config/codexbar/config.json'),
          trailing: IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () {},
          ),
        ),
        ListTile(
          title: Text(l10n.clearAllSettings),
          subtitle: const Text('Reset all settings to defaults'),
          trailing: IconButton(
            icon: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
            onPressed: () => _showClearDialog(context, l10n),
          ),
        ),
      ],
    );
  }

  void _showClearDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text(l10n.clearAllSettings),
      content: const Text('This will reset all settings to their default values.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.ok)),
      ],
    ));
  }
}
