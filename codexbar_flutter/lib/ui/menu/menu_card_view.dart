import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/models/usage_provider.dart';
import '../../core/models/usage_snapshot.dart';
import '../../core/providers/app_providers.dart';
import '../../core/storage/usage_store.dart';
import 'usage_progress_bar.dart';

/// Main menu card view showing provider usage.
class MenuCardView extends ConsumerStatefulWidget {
  final VoidCallback onOpenSettings;

  const MenuCardView({super.key, required this.onOpenSettings});

  @override
  ConsumerState<MenuCardView> createState() => _MenuCardViewState();
}

class _MenuCardViewState extends ConsumerState<MenuCardView> {
  @override
  Widget build(BuildContext context) {
    final storeAsync = ref.watch(usageStoreProvider);
    final enabledAsync = ref.watch(enabledProvidersProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Draggable title bar
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (_) => windowManager.startDragging(),
            child: _buildTitleBar(context),
          ),

          // Provider list
          Expanded(
            child: storeAsync.when(
              data: (store) {
                return enabledAsync.when(
                  data: (enabled) => _buildProviderList(context, ref, store, enabled),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Settings error: $e')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Failed to load', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('$e', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => ref.invalidate(usageStoreProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom bar
          _buildBottomBar(context, ref),
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
          Icon(Icons.monitor_heart, size: 20, color: Theme.of(context).colorScheme.primary),
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
            onPressed: widget.onOpenSettings,
            tooltip: 'Preferences',
          ),
        ],
      ),
    );
  }

  Widget _buildProviderList(
    BuildContext context,
    WidgetRef ref,
    UsageStore store,
    Set<UsageProvider> enabled,
  ) {
    if (enabled.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.toggle_off, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            const Text('No providers enabled'),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: widget.onOpenSettings,
              icon: const Icon(Icons.settings),
              label: const Text('Open Preferences'),
            ),
          ],
        ),
      );
    }

    // Sort: providers with data first, then by display name
    final sorted = enabled.toList()..sort((a, b) {
      final aHas = store.snapshot(a) != null;
      final bHas = store.snapshot(b) != null;
      if (aHas != bHas) return aHas ? -1 : 1;
      return a.displayName.compareTo(b.displayName);
    });

    return RefreshIndicator(
      onRefresh: () => store.refreshAll(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemCount: sorted.length,
        itemBuilder: (context, index) {
          final provider = sorted[index];
          return _ProviderCard(
            provider: provider,
            snapshot: store.snapshot(provider),
            error: store.error(provider),
            lastFetch: store.lastFetchTime(provider),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(usageStoreProvider);
    final isRefreshing = storeAsync.whenOrNull(data: (s) => s.isRefreshing) ?? false;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Text('v0.43.1', style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          SizedBox(
            height: 32,
            child: TextButton.icon(
              icon: isRefreshing
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
              onPressed: isRefreshing
                  ? null
                  : () async {
                      final store = storeAsync.valueOrNull;
                      await store?.refreshAll();
                      if (context.mounted) setState(() {});
                    },
            ),
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
    final hasData = snapshot != null && snapshot!.primary != null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Provider icon placeholder
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      provider.displayName[0],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Name + email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.displayName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (snapshot?.identity?.accountEmail != null)
                        Text(
                          snapshot!.identity!.accountEmail!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Status badge
                _buildStatusBadge(context),
              ],
            ),

            // Usage section
            if (hasData) ...[
              const SizedBox(height: 10),
              _buildUsageSection(context),
            ],

            // Error
            if (error != null && !hasData) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      error!.length > 100 ? '${error!.substring(0, 100)}...' : error!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ),
                ],
              ),
            ],

            // Last fetch time
            if (lastFetch != null) ...[
              const SizedBox(height: 6),
              Text(
                'Updated: ${_formatTime(lastFetch!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 10,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    if (snapshot == null || snapshot!.primary == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('No data', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
      );
    }

    final percent = snapshot!.primary!.usedPercent;
    final color = percent > 90
        ? Colors.red
        : percent > 70
            ? Colors.orange
            : Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '${percent.toStringAsFixed(0)}%',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
      ),
    );
  }

  Widget _buildUsageSection(BuildContext context) {
    final primary = snapshot!.primary!;

    return Column(
      children: [
        UsageProgressBar(
          usedPercent: primary.usedPercent,
          label: snapshot!.secondary != null ? 'Session' : null,
        ),
        if (snapshot!.secondary != null) ...[
          const SizedBox(height: 6),
          UsageProgressBar(
            usedPercent: snapshot!.secondary!.usedPercent,
            label: 'Weekly',
          ),
        ],
        if (primary.resetsAt != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.schedule, size: 12, color: Theme.of(context).colorScheme.outline),
              const SizedBox(width: 4),
              Text(
                'Resets in ${_formatResetTime(primary.resetsAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatResetTime(DateTime resetsAt) {
    final diff = resetsAt.difference(DateTime.now());
    if (diff.isNegative) return 'now';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m';
    return '${diff.inMinutes}m';
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
