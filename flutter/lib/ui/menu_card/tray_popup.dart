import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/usage_provider.dart';
import '../../state/default_providers.dart';
import '../../state/settings_store.dart';
import '../../state/usage_store.dart';
import 'menu_card_view.dart';

/// The popup shown when the tray icon is clicked. Mirrors the merged menu:
/// a provider switcher on top, the selected provider's [MenuCardView] below,
/// and an actions row (Open Settings / Quit).
///
/// Unlike an empty-data view, this always lists every implemented provider
/// (matching CodexBar, which shows all providers' rows on launch) so the user
/// can pick one and configure it.
class TrayPopup extends ConsumerStatefulWidget {
  const TrayPopup({super.key});

  @override
  ConsumerState<TrayPopup> createState() => _TrayPopupState();
}

class _TrayPopupState extends ConsumerState<TrayPopup> {
  UsageProvider? _selected;

  @override
  Widget build(BuildContext context) {
    final registry = ref.watch(providerRegistryProvider);
    final settings = ref.watch(settingsStoreProvider).value;
    final usageState = ref.watch(usageStoreProvider);

    // Show every implemented provider, enabled-first then alphabetical. This
    // mirrors CodexBar's provider switcher, which always lists all known
    // providers (configuring one is how you start using it).
    final implemented = registry.implemented.map((r) => r.descriptor.id).toList();
    final enabled = settings?.enabledProviders ?? const {};
    implemented.sort((a, b) {
      final ae = enabled.contains(a);
      final be = enabled.contains(b);
      if (ae != be) return ae ? -1 : 1;
      return _displayName(a).compareTo(_displayName(b));
    });

    final selected = _selected ?? (implemented.isNotEmpty ? implemented.first : null);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (implemented.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Wrap(
                  spacing: 6,
                  children: [
                    for (final p in implemented)
                      ChoiceChip(
                        label: Text(_displayName(p)),
                        selected: p == selected,
                        onSelected: (_) => setState(() => _selected = p),
                      ),
                  ],
                ),
              ),
            if (implemented.length > 1) const Divider(),
            if (selected != null)
              MenuCardView(provider: selected, runtimeState: usageState[selected])
            else
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No providers available.'),
              ),
            const Divider(),
            _Actions(
              onOpenSettings: () => _openSettings(context),
              onRefresh: selected == null
                  ? null
                  : () => ref.read(usageStoreProvider.notifier).refreshProvider(selected),
              onQuit: () => _quit(context),
            ),
          ],
        ),
      ),
    );
  }

  String _displayName(UsageProvider p) {
    final registry = ref.read(providerRegistryProvider);
    return registry.descriptorFor(p).metadata.displayName;
  }

  void _openSettings(BuildContext context) {
    // Open the settings route in the host MaterialApp.
    Navigator.of(context, rootNavigator: true).pushNamed('/settings');
  }

  void _quit(BuildContext context) {
    Navigator.of(context).maybePop();
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.onOpenSettings,
    required this.onRefresh,
    required this.onQuit,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback? onRefresh;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: onOpenSettings,
          icon: const Icon(Icons.settings_outlined, size: 18),
          label: const Text('Settings'),
        ),
        Row(
          children: [
            if (onRefresh != null)
              TextButton(onPressed: onRefresh, child: const Text('Refresh')),
            TextButton(onPressed: onQuit, child: const Text('Quit')),
          ],
        ),
      ],
    );
  }
}
