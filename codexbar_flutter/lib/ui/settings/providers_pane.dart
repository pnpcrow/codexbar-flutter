import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/usage_provider.dart';
import '../../core/storage/settings_store.dart';

/// Providers settings pane.
/// Direct port of Swift PreferencesProvidersPane.
class ProvidersPane extends ConsumerWidget {
  const ProvidersPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsStoreProvider);

    return settingsAsync.when(
      data: (settings) => _buildContent(context, ref, settings),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, SettingsStore settings) {
    final enabledProviders = settings.enabledProviders;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Providers',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                '${enabledProviders.length} enabled',
                style: Theme.of(context).textTheme.bodySmall,
              ),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Provider list
        Expanded(
          child: ListView.builder(
            itemCount: UsageProvider.values.length,
            itemBuilder: (context, index) {
              final provider = UsageProvider.values[index];
              final isEnabled = enabledProviders.contains(provider);

              return _ProviderTile(
                provider: provider,
                isEnabled: isEnabled,
                onToggle: (value) {
                  settings.toggleProvider(provider);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProviderTile extends StatelessWidget {
  final UsageProvider provider;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const _ProviderTile({
    required this.provider,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isEnabled
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Icon(
          Icons.api,
          size: 18,
          color: isEnabled
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(provider.displayName),
      subtitle: Text(provider.cliName),
      trailing: Switch(
        value: isEnabled,
        onChanged: onToggle,
      ),
      onTap: () => onToggle(!isEnabled),
    );
  }
}
