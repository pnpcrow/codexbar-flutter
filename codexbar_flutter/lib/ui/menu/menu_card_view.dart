import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/usage_provider.dart';
import '../../core/models/usage_snapshot.dart';
import '../../core/providers/provider_registry.dart';
import '../../core/storage/usage_store.dart';
import 'usage_progress_bar.dart';

/// Main menu card view showing provider usage.
/// Direct port of Swift MenuCardView.
class MenuCardView extends ConsumerWidget {
  final VoidCallback onOpenSettings;

  const MenuCardView({super.key, required this.onOpenSettings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageStoreAsync = ref.watch(usageStoreProvider);

    return Scaffold(
      body: Column(
        children: [
          // Title bar area (draggable)
          _buildTitleBar(context),

          // Provider list
          Expanded(
            child: usageStoreAsync.when(
              data: (store) => _buildProviderList(context, ref, store),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),

          // Bottom bar
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.monitor_heart, size: 20),
          const SizedBox(width: 8),
          Text(
            'CodexBar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings, size: 20),
            onPressed: onOpenSettings,
            tooltip: 'Preferences',
          ),
        ],
      ),
    );
  }

  Widget _buildProviderList(BuildContext context, WidgetRef ref, UsageStore store) {
    final enabledProviders = ref.watch(enabledProvidersProvider);

    if (enabledProviders.isEmpty) {
      return const Center(
        child: Text('No providers enabled.\nOpen Preferences to add providers.'),
      );
    }

    return ListView.builder(
      itemCount: enabledProviders.length,
      itemBuilder: (context, index) {
        final provider = enabledProviders.elementAt(index);
        return _ProviderCard(
          provider: provider,
          snapshot: store.snapshot(provider),
          error: store.error(provider),
          lastFetch: store.lastFetchTime(provider),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Text(
            'v0.43.1',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          TextButton.icon(
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Refresh All'),
            onPressed: () {
              // TODO: Trigger refresh
            },
          ),
        ],
      ),
    );
  }
}

/// Individual provider card.
class _ProviderCard extends StatelessWidget {
  final UsageProvider provider;
  final UsageSnapshot? snapshot;
  final String? error;
  final DateTime? lastFetch;

  const _ProviderCard({
    required this.provider,
    this.snapshot,
    this.error,
    this.lastFetch,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Provider name + status
            Row(
              children: [
                _buildProviderIcon(),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.displayName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (snapshot?.identity?.accountEmail != null)
                        Text(
                          snapshot!.identity!.accountEmail!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                _buildStatusBadge(context),
              ],
            ),

            if (snapshot != null) ...[
              const SizedBox(height: 12),
              _buildUsageSection(context),
            ],

            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProviderIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.api, size: 20),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    if (snapshot == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No data',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    final percent = snapshot!.primary?.usedPercent ?? 0;
    final color = percent > 90
        ? Colors.red
        : percent > 70
            ? Colors.orange
            : Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${percent.toStringAsFixed(0)}%',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildUsageSection(BuildContext context) {
    final primary = snapshot!.primary;
    if (primary == null) return const SizedBox.shrink();

    return Column(
      children: [
        UsageProgressBar(
          usedPercent: primary.usedPercent,
          label: 'Session',
        ),
        if (snapshot!.secondary != null) ...[
          const SizedBox(height: 8),
          UsageProgressBar(
            usedPercent: snapshot!.secondary!.usedPercent,
            label: 'Weekly',
          ),
        ],
        if (primary.resetsAt != null) ...[
          const SizedBox(height: 8),
          Text(
            'Resets: ${_formatResetTime(primary.resetsAt!)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  String _formatResetTime(DateTime resetsAt) {
    final now = DateTime.now();
    final diff = resetsAt.difference(now);
    if (diff.isNegative) return 'Reset available';
    if (diff.inHours > 0) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m';
    }
    return '${diff.inMinutes}m';
  }
}
