import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../state/usage_store.dart';
import '../../state/settings_store.dart';
import '../popup/usage_menu_card.dart';

class PopupWindow extends ConsumerWidget {
  const PopupWindow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsStoreProvider);
    final usageStore = ref.watch(usageStoreProvider);

    final enabledProviders = settings.orderedProviders
        .where((p) => settings.isProviderEnabled(p))
        .toList();

    return Container(
      width: AppSizes.popupWidth,
      constraints: const BoxConstraints(
        maxHeight: AppSizes.popupMaxHeight,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, ref, l10n),
          const Divider(height: 1),
          Flexible(
            child: enabledProviders.isEmpty
                ? _buildEmptyState(context, l10n)
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: enabledProviders.length,
                    itemBuilder: (context, index) {
                      final provider = enabledProviders[index];
                      final state = usageStore.getState(provider);
                      return Column(
                        children: [
                          UsageMenuCardView(
                            provider: provider,
                            snapshot: state.snapshot,
                            error: state.error,
                            isRefreshing: state.isRefreshing,
                            width: AppSizes.popupWidth,
                          ),
                          if (index < enabledProviders.length - 1)
                            const Divider(height: 1),
                        ],
                      );
                    },
                  ),
          ),
          _buildFooter(context, ref, l10n),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.extension_off,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No providers enabled',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enable providers in Settings',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.speed, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            l10n.appTitle,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, size: 18),
            onPressed: () => ref.read(usageStoreProvider).refreshAll(),
            tooltip: l10n.refreshAll,
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 18),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: l10n.settings,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor.withAlpha(80))),
      ),
      child: Row(
        children: [
          Text(
            '${l10n.version} 0.1.0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => exit(0),
            child: Text(l10n.quit, style: TextStyle(color: theme.colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
