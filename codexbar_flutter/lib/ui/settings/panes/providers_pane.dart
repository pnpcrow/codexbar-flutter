import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../state/settings_store.dart';

class ProvidersPane extends ConsumerWidget {
  const ProvidersPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);
    final providers = settings.orderedProviders;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Text(
                'Providers',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              Text(
                '${providers.where((p) => settings.isProviderEnabled(p)).length} enabled',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search providers...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Provider list
        Expanded(
          child: ListView.builder(
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final provider = providers[index];
              final isEnabled = settings.isProviderEnabled(provider);

              return ListTile(
                leading: Icon(
                  _providerIcon(provider),
                  color: isEnabled
                      ? AppColors.progressColor(provider)
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                title: Text(provider.displayName),
                subtitle: Text(
                  isEnabled ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    color: isEnabled
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Switch(
                  value: isEnabled,
                  onChanged: (v) => settings.setProviderEnabled(provider, v),
                ),
                onTap: () {
                  // Navigate to provider detail
                },
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _providerIcon(UsageProvider provider) {
    switch (provider) {
      case UsageProvider.claude:
        return Icons.psychology;
      case UsageProvider.codex:
        return Icons.code;
      case UsageProvider.gemini:
        return Icons.auto_awesome;
      case UsageProvider.cursor:
        return Icons.edit;
      case UsageProvider.openai:
        return Icons.smart_toy;
      default:
        return Icons.extension;
    }
  }
}
