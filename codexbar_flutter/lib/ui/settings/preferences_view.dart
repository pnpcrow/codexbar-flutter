import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../state/settings_store.dart';
import 'panes/general_pane.dart';
import 'panes/notifications_pane.dart';
import 'panes/menu_bar_pane.dart';
import 'panes/menu_pane.dart';
import 'panes/advanced_pane.dart';
import 'panes/about_pane.dart';

enum SettingsPane {
  general, notifications, menuBar, menu, advanced, about, debug, provider;

  String title(AppLocalizations l10n) {
    switch (this) {
      case SettingsPane.general: return l10n.tabGeneral;
      case SettingsPane.notifications: return l10n.tabNotifications;
      case SettingsPane.menuBar: return l10n.tabMenuBar;
      case SettingsPane.menu: return l10n.tabMenu;
      case SettingsPane.advanced: return l10n.tabAdvanced;
      case SettingsPane.about: return l10n.tabAbout;
      case SettingsPane.debug: return l10n.tabDebug;
      case SettingsPane.provider: return l10n.tabProviders;
    }
  }

  IconData get icon {
    switch (this) {
      case SettingsPane.general: return Icons.settings;
      case SettingsPane.notifications: return Icons.notifications;
      case SettingsPane.menuBar: return Icons.desktop_windows;
      case SettingsPane.menu: return Icons.menu;
      case SettingsPane.advanced: return Icons.tune;
      case SettingsPane.about: return Icons.info;
      case SettingsPane.debug: return Icons.bug_report;
      case SettingsPane.provider: return Icons.extension;
    }
  }
}

class PreferencesView extends ConsumerStatefulWidget {
  const PreferencesView({super.key});

  @override
  ConsumerState<PreferencesView> createState() => _PreferencesViewState();
}

class _PreferencesViewState extends ConsumerState<PreferencesView> {
  SettingsPane _selectedPane = SettingsPane.general;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: AppSizes.settingsSidebarWidth,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              border: Border(right: BorderSide(color: theme.dividerColor.withAlpha(80))),
            ),
            child: ListView(
              children: [
                _buildSidebarHeader(context),
                const Divider(height: 1),
                ...SettingsPane.values
                    .where((p) => p != SettingsPane.provider)
                    .map((pane) => _buildSidebarItem(context, pane, l10n)),
              ],
            ),
          ),
          Expanded(child: _buildDetailView(context)),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.speed, size: 24, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text('CodexBar', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, SettingsPane pane, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isSelected = _selectedPane == pane;
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(pane.icon, size: 20, color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant),
      title: Text(pane.title(l10n), style: TextStyle(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
      )),
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withAlpha(80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () => setState(() => _selectedPane = pane),
    );
  }

  Widget _buildDetailView(BuildContext context) {
    switch (_selectedPane) {
      case SettingsPane.general: return const GeneralPane();
      case SettingsPane.notifications: return const NotificationsPane();
      case SettingsPane.menuBar: return const MenuBarPane();
      case SettingsPane.menu: return const MenuPane();
      case SettingsPane.advanced: return const AdvancedPane();
      case SettingsPane.about: return const AboutPane();
      case SettingsPane.debug: return const DebugPane();
      case SettingsPane.provider: return const ProviderDetailPane();
    }
  }
}

class DebugPane extends ConsumerWidget {
  const DebugPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsStoreProvider);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n.tabDebug, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Debug menu'),
          subtitle: const Text('Show debug options in the menu'),
          value: settings.debugMenuEnabled,
          onChanged: (v) => settings.setDebugMenuEnabled(v),
        ),
      ],
    );
  }
}

class ProviderDetailPane extends StatelessWidget {
  const ProviderDetailPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.extension, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('Select a provider from the sidebar', style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          )),
        ],
      ),
    );
  }
}
