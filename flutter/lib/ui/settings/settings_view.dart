import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/settings_state.dart';
import '../../state/settings_store.dart';
import 'general_pane.dart';
import 'menu_bar_pane.dart';
import 'notifications_pane.dart';
import 'providers_pane.dart';

/// The settings window: sidebar + detail pane. Mirrors `PreferencesView`.
class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

enum _Pane { general, notifications, menuBar, providers }

class _SettingsViewState extends ConsumerState<SettingsView> {
  _Pane _selected = _Pane.general;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsStoreProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('CodexBar Settings')),
      body: Row(
        children: [
          SizedBox(
            width: 220,
            child: _Sidebar(
              selected: _selected,
              onSelect: (p) => setState(() => _selected = p),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: settings.when(
              data: (state) => _detail(state),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load settings: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail(SettingsState state) {
    return switch (_selected) {
      _Pane.general => GeneralPane(state: state),
      _Pane.notifications => NotificationsPane(state: state),
      _Pane.menuBar => MenuBarPane(state: state),
      _Pane.providers => const ProvidersPane(),
    };
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selected, required this.onSelect});

  final _Pane selected;
  final ValueChanged<_Pane> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = <(_Pane, IconData, String)>[
      (_Pane.general, Icons.settings_outlined, 'General'),
      (_Pane.notifications, Icons.notifications_outlined, 'Notifications'),
      (_Pane.menuBar, Icons.bar_chart, 'Menu Bar'),
      (_Pane.providers, Icons.cloud_outlined, 'Providers'),
    ];
    return ListView(
      children: [
        for (final (pane, icon, label) in items)
          ListTile(
            leading: Icon(icon),
            title: Text(label),
            selected: pane == selected,
            onTap: () => onSelect(pane),
          ),
      ],
    );
  }
}

/// Shared helpers for the panes.
extension SettingsMutation on WidgetRef {
  Future<void> mutateSettings(SettingsState Function(SettingsState) updater) {
    return read(settingsStoreProvider.notifier).mutate(updater);
  }
}
