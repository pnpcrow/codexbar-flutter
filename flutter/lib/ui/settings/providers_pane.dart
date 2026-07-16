import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/usage_provider.dart';
import '../../core/providers/provider_descriptor_registry.dart';
import '../../state/default_providers.dart';
import '../../state/settings_store.dart';
import '../../state/usage_store.dart';
import 'settings_view.dart';

/// Providers settings: list of implemented providers, each with an API key
/// field, enable toggle, and a test/refresh action. Mirrors
/// `PreferencesProvidersPane` + `PreferencesProviderDetailView`.
class ProvidersPane extends ConsumerWidget {
  const ProvidersPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider).value;
    final registry = ref.watch(providerRegistryProvider);
    final implemented = registry.implemented
      ..sort((a, b) => a.descriptor.metadata.displayName.compareTo(b.descriptor.metadata.displayName));
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Providers', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Enter an API key for each provider you want to track. Keys are stored '
          'in the system secure store (Keyring/Keychain).',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        for (final reg in implemented)
          _ProviderCard(
            provider: reg.descriptor.id,
            displayName: reg.descriptor.metadata.displayName,
            dashboardURL: reg.descriptor.metadata.dashboardURL,
            enabled: settings?.enabledProviders.contains(reg.descriptor.id) ?? false,
          ),
        const Divider(),
        ExpansionTile(
          title: const Text('Not yet available'),
          subtitle: const Text('Providers awaiting port (OAuth/cookie/CLI auth).'),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final p in UsageProvider.all)
                    if (!registry.implemented.any((r) => r.descriptor.id == p))
                      Chip(label: Text(p.name)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProviderCard extends ConsumerStatefulWidget {
  const _ProviderCard({
    required this.provider,
    required this.displayName,
    required this.dashboardURL,
    required this.enabled,
  });

  final UsageProvider provider;
  final String displayName;
  final String? dashboardURL;
  final bool enabled;

  @override
  ConsumerState<_ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends ConsumerState<_ProviderCard> {
  final _controller = TextEditingController();
  bool _loading = true;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final store = ref.read(credentialStoreProvider);
    final key = await store.apiKey(widget.provider);
    _controller.text = key ?? '';
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(widget.displayName,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Switch(
                  value: widget.enabled,
                  onChanged: (v) async {
                    await ref.mutateSettings(
                      (s) => s.copyWith(
                        enabledProviders: v
                            ? ({...s.enabledProviders, widget.provider})
                            : (s.enabledProviders..remove(widget.provider)),
                      ),
                    );
                    final usage = ref.read(usageStoreProvider.notifier);
                    if (v) {
                      usage.ensureProvider(widget.provider);
                    } else {
                      usage.removeProvider(widget.provider);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_loading)
              const LinearProgressIndicator()
            else
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'API key',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => ref.read(usageStoreProvider.notifier)
                        .refreshProvider(widget.provider),
                    child: const Text('Test'),
                  ),
                ],
              ),
            if (widget.dashboardURL != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Get API key'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final store = ref.read(credentialStoreProvider);
    await store.setApiKey(widget.provider, _controller.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.displayName} key saved.')),
    );
    // Auto-enable the provider on first key entry, seed its card, and refresh.
    if (!widget.enabled && _controller.text.trim().isNotEmpty) {
      await ref.mutateSettings(
        (s) => s.copyWith(
          enabledProviders: {...s.enabledProviders, widget.provider},
        ),
      );
    }
    ref.read(usageStoreProvider.notifier).ensureProvider(widget.provider);
  }
}
