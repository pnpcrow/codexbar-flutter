import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/provider_cost.dart';
import '../../core/models/provider_identity.dart';
import '../../core/models/rate_window.dart';
import '../../core/models/usage_provider.dart';
import '../../core/storage/settings_state.dart';
import '../../state/settings_store.dart';
import '../../state/usage_store.dart';
import 'usage_progress_bar.dart';

/// The rich usage card shown in the tray popup, mirroring `MenuCardView`.
///
/// Shows the provider name, plan/identity, a metric row per rate window with
/// a [UsageProgressBar], reset countdown, and an actions row.
class MenuCardView extends ConsumerWidget {
  const MenuCardView({super.key, required this.provider, this.runtimeState});

  final UsageProvider provider;

  /// Optional runtime state injected by the caller (e.g. the tray popup).
  /// When `null`, the widget reads it from [usageStoreProvider].
  final ProviderRuntimeState? runtimeState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registry = ref.watch(usageStoreProvider);
    final settings = ref.watch(settingsStoreProvider).value ?? const SettingsState();
    final descriptor = _descriptor(provider);
    final state = runtimeState ?? registry[provider] ?? const ProviderRuntimeState();

    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(
            provider: provider,
            displayName: descriptor.displayName,
            identity: state.snapshot?.identity,
            lastUpdated: state.lastUpdated,
            refreshing: state.refreshing,
          ),
          const SizedBox(height: 12),
          _Body(
            state: state,
            settings: settings,
          ),
          if (state.error != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, size: 16,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          _Actions(
            provider: provider,
            dashboardURL: descriptor.dashboardURL,
          ),
        ],
      ),
    );
  }

  ({String displayName, String? dashboardURL}) _descriptor(UsageProvider provider) {
    final known = <UsageProvider, ({String displayName, String? dashboardURL})>{
      UsageProvider.openai: (displayName: 'OpenAI', dashboardURL: 'https://platform.openai.com/usage'),
      UsageProvider.claude: (displayName: 'Claude', dashboardURL: 'https://console.anthropic.com/settings/usage'),
      UsageProvider.openrouter: (displayName: 'OpenRouter', dashboardURL: 'https://openrouter.ai/credits'),
      UsageProvider.deepseek: (displayName: 'DeepSeek', dashboardURL: 'https://platform.deepseek.com/usage'),
    };
    return known[provider] ??
        (
          displayName: provider.name[0].toUpperCase() + provider.name.substring(1),
          dashboardURL: null,
        );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.provider,
    required this.displayName,
    required this.identity,
    required this.lastUpdated,
    required this.refreshing,
  });

  final UsageProvider provider;
  final String displayName;
  final ProviderIdentitySnapshot? identity;
  final DateTime? lastUpdated;
  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (identity?.accountEmail case final email?)
                Text(email, style: Theme.of(context).textTheme.bodySmall),
              if (identity?.loginMethod case final method? when identity?.accountEmail == null)
                Text(method, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        if (refreshing)
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.settings});

  final ProviderRuntimeState state;
  final SettingsState settings;

  @override
  Widget build(BuildContext context) {
    final snapshot = state.snapshot;
    if (snapshot == null) {
      return Text(
        state.error != null ? 'Failed to load usage.' : 'No data yet. Add an API key in Settings.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final rows = <Widget>[];
    if (snapshot.primary case final primary?) {
      rows.add(_MetricRow(
        label: 'Session',
        window: primary,
        showUsed: settings.usageBarsShowUsed,
        thresholds: settings.thresholds.sortedPercents,
      ));
    }
    if (snapshot.secondary case final secondary?) {
      rows.add(_MetricRow(
        label: 'Weekly',
        window: secondary,
        showUsed: settings.usageBarsShowUsed,
        thresholds: settings.thresholds.sortedPercents,
      ));
    }
    if (snapshot.providerCost case final cost?) {
      rows.add(_CostRow(cost: cost));
    }
    if (rows.isEmpty) {
      rows.add(Text(
        'Usage data available but no rate window reported.',
        style: Theme.of(context).textTheme.bodySmall,
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          rows[i],
        ],
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.window,
    required this.showUsed,
    required this.thresholds,
  });

  final String label;
  final RateWindow window;
  final bool showUsed;
  final List<int> thresholds;

  @override
  Widget build(BuildContext context) {
    final used = window.usedPercent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            Text(
              showUsed
                  ? '${used.toStringAsFixed(0)}% used'
                  : '${window.remainingPercent.toStringAsFixed(0)}% left',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 4),
        UsageProgressBar(
          percent: used,
          showUsed: showUsed,
          warningThresholds: thresholds,
        ),
        if (window.resetDescription case final desc? when desc.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(desc, style: Theme.of(context).textTheme.bodySmall),
          ),
      ],
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({required this.cost});

  final ProviderCostSnapshot cost;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(cost.period ?? 'Cost', style: Theme.of(context).textTheme.labelMedium),
        Text(
          '${cost.currencyCode} ${cost.used.toStringAsFixed(2)}'
          '${cost.limit > 0 ? ' / ${cost.limit.toStringAsFixed(2)}' : ''}',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({required this.provider, required this.dashboardURL});

  final UsageProvider provider;
  final String? dashboardURL;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.read(usageStoreProvider.notifier);
    // Card-level actions: refresh + dashboard. The Settings/Quit actions live
    // in the tray popup footer to avoid duplication.
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => usage.refreshProvider(provider),
          child: const Text('Refresh'),
        ),
        if (dashboardURL != null)
          TextButton(
            onPressed: () => _openUrl(dashboardURL!),
            child: const Text('Dashboard'),
          ),
      ],
    );
  }
}

Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }
}
