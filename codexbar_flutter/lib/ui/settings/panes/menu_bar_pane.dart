import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/settings_store.dart';

class MenuBarPane extends ConsumerWidget {
  const MenuBarPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsStoreProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n.tabMenuBar, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        _buildSectionHeader(context, l10n.sectionIcon),
        SwitchListTile(
          title: Text(l10n.mergeIcons),
          subtitle: const Text('Combine all providers into one status icon'),
          value: settings.mergeIcons,
          onChanged: (v) => settings.setMergeIcons(v),
        ),
        ListTile(
          title: Text(l10n.displayMode),
          subtitle: Text(settings.menuBarDisplayMode.label),
          trailing: DropdownButton<MenuBarDisplayMode>(
            value: settings.menuBarDisplayMode,
            onChanged: (v) { if (v != null) settings.setMenuBarDisplayMode(v); },
            items: MenuBarDisplayMode.values.map((m) => DropdownMenuItem(value: m, child: Text(m.label))).toList(),
          ),
        ),
        SwitchListTile(
          title: const Text('Show reset time when exhausted'),
          subtitle: const Text('Show reset countdown when usage is at 100%'),
          value: settings.menuBarShowsResetTimeWhenExhausted,
          onChanged: (v) => settings.setMenuBarShowsResetTimeWhenExhausted(v),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(context, l10n.sectionCombinedIcon),
        SwitchListTile(
          title: Text(l10n.showHighestUsage),
          subtitle: const Text('Auto-select provider with highest usage'),
          value: settings.menuBarShowsHighestUsage,
          onChanged: (v) => settings.setMenuBarShowsHighestUsage(v),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(context, l10n.sectionAnimation),
        SwitchListTile(
          title: Text(l10n.randomBlink),
          subtitle: const Text('Occasional random eye blink animation'),
          value: settings.randomBlinkEnabled,
          onChanged: (v) => settings.setRandomBlinkEnabled(v),
        ),
        SwitchListTile(
          title: Text(l10n.hideCritters),
          subtitle: const Text('Show plain meter bars without face decorations'),
          value: settings.hideCritters,
          onChanged: (v) => settings.setHideCritters(v),
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
}
