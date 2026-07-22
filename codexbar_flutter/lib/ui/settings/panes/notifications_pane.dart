import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/settings_store.dart';

class NotificationsPane extends ConsumerWidget {
  const NotificationsPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsStoreProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n.tabNotifications, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        SwitchListTile(
          title: Text(l10n.sessionQuotaNotifications),
          subtitle: const Text('Notify when session quota is running low'),
          value: settings.sessionQuotaNotificationsEnabled,
          onChanged: (v) => settings.setSessionQuotaNotificationsEnabled(v),
        ),
        SwitchListTile(
          title: Text(l10n.confettiOnSessionReset),
          subtitle: const Text('Show confetti animation when session limit resets'),
          value: settings.confettiOnSessionLimitResetsEnabled,
          onChanged: (v) => settings.setConfettiOnSessionLimitResetsEnabled(v),
        ),
        SwitchListTile(
          title: Text(l10n.confettiOnWeeklyReset),
          subtitle: const Text('Show confetti animation when weekly limit resets'),
          value: settings.confettiOnWeeklyLimitResetsEnabled,
          onChanged: (v) => settings.setConfettiOnWeeklyLimitResetsEnabled(v),
        ),
        const Divider(),
        SwitchListTile(
          title: Text(l10n.quotaWarnings),
          subtitle: const Text('Show warnings when approaching quota limits'),
          value: settings.quotaWarningNotificationsEnabled,
          onChanged: (v) => settings.setQuotaWarningNotificationsEnabled(v),
        ),
      ],
    );
  }
}
