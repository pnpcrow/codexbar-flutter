import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/settings_state.dart';
import 'settings_view.dart';

/// Menu bar settings: icon display mode, percent direction, critters.
/// Mirrors `PreferencesMenuBarPane`.
class MenuBarPane extends ConsumerWidget {
  const MenuBarPane({super.key, required this.state});

  final SettingsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Menu Bar', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        DropdownButtonFormField<MenuBarDisplayMode>(
          decoration: const InputDecoration(
            labelText: 'Icon display',
            border: OutlineInputBorder(),
          ),
          value: state.menuBarDisplayMode,
          items: [
            for (final m in MenuBarDisplayMode.values)
              DropdownMenuItem(value: m, child: Text(m.displayName)),
          ],
          onChanged: (m) {
            if (m != null) ref.mutateSettings((s) => s.copyWith(menuBarDisplayMode: m));
          },
        ),
        SwitchListTile(
          title: const Text('Show brand icon with percent'),
          value: state.menuBarShowsBrandIconWithPercent,
          onChanged: (v) => ref.mutateSettings(
            (s) => s.copyWith(menuBarShowsBrandIconWithPercent: v),
          ),
        ),
        SwitchListTile(
          title: const Text('Show % used (vs % left)'),
          value: state.usageBarsShowUsed,
          onChanged: (v) =>
              ref.mutateSettings((s) => s.copyWith(usageBarsShowUsed: v)),
        ),
        SwitchListTile(
          title: const Text('Show absolute reset times'),
          value: state.resetTimesShowAbsolute,
          onChanged: (v) => ref.mutateSettings(
            (s) => s.copyWith(resetTimesShowAbsolute: v),
          ),
        ),
        SwitchListTile(
          title: const Text('Hide provider critters'),
          subtitle: const Text('Render plain meter bars without the per-provider personality.'),
          value: state.menuBarHidesCritters,
          onChanged: (v) =>
              ref.mutateSettings((s) => s.copyWith(menuBarHidesCritters: v)),
        ),
        SwitchListTile(
          title: const Text('Merge providers into one icon'),
          value: state.mergeIcons,
          onChanged: (v) => ref.mutateSettings((s) => s.copyWith(mergeIcons: v)),
        ),
      ],
    );
  }
}
