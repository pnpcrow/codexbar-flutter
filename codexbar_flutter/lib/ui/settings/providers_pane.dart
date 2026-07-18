import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/usage_provider.dart';
import '../../core/providers/app_providers.dart';
import '../../core/storage/settings_store.dart';
import 'provider_detail_view.dart';

/// Providers settings pane with list and detail view.
class ProvidersPane extends ConsumerStatefulWidget {
  const ProvidersPane({super.key});

  @override
  ConsumerState<ProvidersPane> createState() => _ProvidersPaneState();
}

class _ProvidersPaneState extends ConsumerState<ProvidersPane> {
  String _searchQuery = '';
  UsageProvider? _selectedProvider;

  @override
  Widget build(BuildContext context) {
    // If a provider is selected, show detail view
    if (_selectedProvider != null) {
      return ProviderDetailView(
        provider: _selectedProvider!,
        onBack: () => setState(() => _selectedProvider = null),
      );
    }

    final settingsAsync = ref.watch(settingsStoreProvider);
    final enabledAsync = ref.watch(enabledProvidersProvider);

    return settingsAsync.when(
      data: (settings) {
        return enabledAsync.when(
          data: (enabled) => _buildList(context, settings, enabled),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildList(
    BuildContext context,
    SettingsStore settings,
    Set<UsageProvider> enabled,
  ) {
    final filtered = UsageProvider.values.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text('Providers', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text('${enabled.length} enabled', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),

        // Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search providers...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),

        const SizedBox(height: 8),

        // Provider list
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final provider = filtered[index];
              final isEnabled = enabled.contains(provider);

              return ListTile(
                dense: true,
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: isEnabled
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: Text(
                      provider.displayName[0],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isEnabled
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                title: Text(provider.displayName),
                subtitle: Text(provider.cliName, style: const TextStyle(fontSize: 12)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: isEnabled,
                      onChanged: (value) {
                        settings.toggleProvider(provider);
                        ref.invalidate(enabledProvidersProvider);
                      },
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 20),
                  ],
                ),
                onTap: () {
                  setState(() => _selectedProvider = provider);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
