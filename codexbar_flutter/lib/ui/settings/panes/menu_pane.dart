import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/settings_store.dart';

class MenuPane extends ConsumerWidget {
  const MenuPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsStoreProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n.tabMenu, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        SwitchListTile(
          title: Text(l10n.showUsedPercentage),
          subtitle: const Text('Show used instead of remaining in usage bars'),
          value: settings.usageBarsShowUsed,
          onChanged: (v) => settings.setUsageBarsShowUsed(v),
        ),
        SwitchListTile(
          title: Text(l10n.absoluteResetTimes),
          subtitle: const Text('Show absolute time instead of relative countdown'),
          value: settings.resetTimesShowAbsolute,
          onChanged: (v) => settings.setResetTimesShowAbsolute(v),
        ),
      ],
    );
  }
}
